/*
 * spi-rt2880.c -- Ralink RT288x/RT305x SPI controller driver
 *
 * Copyright (C) 2011 Sergiy <piratfm@gmail.com>
 * Copyright (C) 2011-2013 Gabor Juhos <juhosg@openwrt.org>
 *
 * Some parts are based on spi-orion.c:
 *   Author: Shadi Ammouri <shadi@marvell.com>
 *   Copyright (C) 2007-2008 Marvell Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/clk.h>
#include <linux/err.h>
#include <linux/delay.h>
#include <linux/io.h>
#include <linux/reset.h>
#include <linux/spi/spi.h>
#include <linux/of_device.h>
#include <linux/platform_device.h>

#include <ralink_regs.h>

#define SPI_BPW_MASK(bits) BIT((bits) - 1)

#define DRIVER_NAME			"spi-rt2880"
/* Manfeel: mod to support two slaves */
#define RALINK_NUM_CHIPSELECTS		2
/* in usec */
#define RALINK_SPI_WAIT_MAX_LOOP	2000

#define RAMIPS_SPI_STAT			0x00
#define RAMIPS_SPI_CFG			0x10
#define RAMIPS_SPI_CTL			0x14
#define RAMIPS_SPI_DATA			0x20
#define RAMIPS_SPI_FIFO_STAT		0x38

/* Manfeel: SPI_GPIO_MODE */
#define RAMIPS_SPI_GPIO     0x60
#define RAMIPS_SPI_ARB      0xf0

/* SPISTAT register bit field */
#define SPISTAT_BUSY			BIT(0)

/* SPICFG register bit field */
#define SPICFG_LSBFIRST			0
#define SPICFG_MSBFIRST			BIT(8)
#define SPICFG_SPICLKPOL		BIT(6)
#define SPICFG_RXCLKEDGE_FALLING	BIT(5)
#define SPICFG_TXCLKEDGE_FALLING	BIT(4)
#define SPICFG_SPICLK_PRESCALE_MASK	0x7
#define SPICFG_SPICLK_DIV2		0
#define SPICFG_SPICLK_DIV4		1
#define SPICFG_SPICLK_DIV8		2
#define SPICFG_SPICLK_DIV16		3
#define SPICFG_SPICLK_DIV32		4
#define SPICFG_SPICLK_DIV64		5
#define SPICFG_SPICLK_DIV128		6
#define SPICFG_SPICLK_DISABLE		7

/* SPICTL register bit field */
#define SPICTL_HIZSDO			BIT(3)
#define SPICTL_STARTWR			BIT(2)
#define SPICTL_STARTRD			BIT(1)
#define SPICTL_SPIENA			BIT(0)

/* SPIFIFOSTAT register bit field */
#define SPIFIFOSTAT_TXFULL		BIT(17)

#define MT7621_SPI_TRANS	0x00
#define SPITRANS_BUSY		BIT(16)
#define MT7621_SPI_OPCODE	0x04
#define MT7621_SPI_DATA0	0x08
#define SPI_CTL_TX_RX_CNT_MASK	0xff
#define SPI_CTL_START		BIT(8)
#define MT7621_SPI_POLAR	0x38
#define MT7621_SPI_MASTER	0x28
#define MT7621_SPI_SPACE	0x3c

struct rt2880_spi;

struct rt2880_spi_ops {
	void (*init_hw)(struct rt2880_spi *rs);
	void (*set_cs)(struct rt2880_spi *rs, int enable);
	int (*baudrate_set)(struct spi_device *spi, unsigned int speed);
	unsigned int (*write_read)(struct spi_device *spi, struct list_head *list, struct spi_transfer *xfer);
};

struct rt2880_spi {
	struct spi_master	*master;
	void __iomem		*base;
	unsigned int		sys_freq;
	unsigned int		speed;
	struct clk		*clk;
	spinlock_t		lock;
	// Manfeel: add chipselect	
	uint16_t		chipselect;

	struct rt2880_spi_ops	*ops;
};

static inline struct rt2880_spi *spidev_to_rt2880_spi(struct spi_device *spi)
{
	return spi_master_get_devdata(spi->master);
}

static inline u32 rt2880_spi_read(struct rt2880_spi *rs, u32 reg)
{
	return ioread32(rs->base + reg);
}

static inline void rt2880_spi_write(struct rt2880_spi *rs, u32 reg, u32 val)
{
	iowrite32(val, rs->base + reg);
}

static inline void rt2880_spi_setbits(struct rt2880_spi *rs, u32 reg, u32 mask)
{
	void __iomem *addr = rs->base + reg;
	unsigned long flags;
	u32 val;

	spin_lock_irqsave(&rs->lock, flags);
	val = ioread32(addr);
	val |= mask;
	iowrite32(val, addr);
	spin_unlock_irqrestore(&rs->lock, flags);
}

static inline void rt2880_spi_clrbits(struct rt2880_spi *rs, u32 reg, u32 mask)
{
	void __iomem *addr = rs->base + reg;
	unsigned long flags;
	u32 val;

	spin_lock_irqsave(&rs->lock, flags);
	val = ioread32(addr);
	val &= ~mask;
	iowrite32(val, addr);
	spin_unlock_irqrestore(&rs->lock, flags);
}

static int rt2880_spi_baudrate_set(struct spi_device *spi, unsigned int speed)
{
	struct rt2880_spi *rs = spidev_to_rt2880_spi(spi);
	u32 rate;
	u32 prescale;
	u32 reg;

	dev_dbg(&spi->dev, "speed:%u\n", speed);

	/*
	 * the supported rates are: 2, 4, 8, ... 128
	 * round up as we look for equal or less speed
	 */
	rate = DIV_ROUND_UP(rs->sys_freq, speed);
	dev_dbg(&spi->dev, "rate-1:%u\n", rate);
	rate = roundup_pow_of_two(rate);
	dev_dbg(&spi->dev, "rate-2:%u\n", rate);

	/* check if requested speed is too small */
	if (rate > 128)
		return -EINVAL;

	if (rate < 2)
		rate = 2;

	/* Convert the rate to SPI clock divisor value.	*/
	prescale = ilog2(rate / 2);
	dev_dbg(&spi->dev, "prescale:%u\n", prescale);

	reg = rt2880_spi_read(rs, RAMIPS_SPI_CFG);
	reg = ((reg & ~SPICFG_SPICLK_PRESCALE_MASK) | prescale);
	rt2880_spi_write(rs, RAMIPS_SPI_CFG, reg);
	rs->speed = speed;
	return 0;
}

static int mt7621_spi_baudrate_set(struct spi_device *spi, unsigned int speed)
{
/*	u32 master = rt2880_spi_read(rs, MT7621_SPI_MASTER);

	// set default clock to hclk/5
	master &= ~(0xfff << 16);
	master |= 0x3 << 16;
*/
	return 0;
}

/*
 * called only when no transfer is active on the bus
 */
static int
rt2880_spi_setup_transfer(struct spi_device *spi, struct spi_transfer *t)
{
	struct rt2880_spi *rs = spidev_to_rt2880_spi(spi);
	unsigned int speed = spi->max_speed_hz;
	int rc;

	if ((t != NULL) && t->speed_hz)
		speed = t->speed_hz;

	if (rs->speed != speed) {
		dev_dbg(&spi->dev, "speed_hz:%u\n", speed);
		rc = rs->ops->baudrate_set(spi, speed);
		if (rc)
			return rc;
	}

	return 0;
}

static void rt2880_spi_set_cs(struct rt2880_spi *rs, int enable)
{
	int cs = rs->chipselect;
	// read out
	u32 val = ioread32(rs->base + RAMIPS_SPI_ARB);  //RAMIPS_SPI_ARB  0x00f0

	// swtich between CS0 and CS1
	if (cs == 0) {
		val &= ~(1<<16);
	} else if(cs == 1) {
		val |= (1<<16);
	}

	// write back
	iowrite32(val, rs->base + RAMIPS_SPI_ARB);

	if (enable)
		rt2880_spi_clrbits(rs, RAMIPS_SPI_CTL, SPICTL_SPIENA);
	else
		rt2880_spi_setbits(rs, RAMIPS_SPI_CTL, SPICTL_SPIENA);
}

static void mt7621_spi_set_cs(struct rt2880_spi *rs, int enable)
{
	u32 polar = rt2880_spi_read(rs, MT7621_SPI_POLAR);

	if (enable)
		polar |= 1;
	else
		polar &= ~1;
	rt2880_spi_write(rs, MT7621_SPI_POLAR, polar);
}

static inline int rt2880_spi_wait_till_ready(struct rt2880_spi *rs)
{
	int i;

	for (i = 0; i < RALINK_SPI_WAIT_MAX_LOOP; i++) {
		u32 status;

		status = rt2880_spi_read(rs, RAMIPS_SPI_STAT);
		if ((status & SPISTAT_BUSY) == 0)
			return 0;

		cpu_relax();
		udelay(1);
	}

	return -ETIMEDOUT;
}

static inline int mt7621_spi_wait_till_ready(struct rt2880_spi *rs)
{
	int i;

	for (i = 0; i < RALINK_SPI_WAIT_MAX_LOOP; i++) {
		u32 status;

		status = rt2880_spi_read(rs, MT7621_SPI_TRANS);
		if ((status & SPITRANS_BUSY) == 0) {
			return 0;
		}
		cpu_relax();
		udelay(1);
	}

	return -ETIMEDOUT;
}

static unsigned int
rt2880_spi_write_read(struct spi_device *spi, struct list_head *list, struct spi_transfer *xfer)
{
	struct rt2880_spi *rs = spidev_to_rt2880_spi(spi);
	unsigned count = 0;
	u8 *rx = xfer->rx_buf;
	const u8 *tx = xfer->tx_buf;
	int err;

	dev_dbg(&spi->dev, "read (%d): %s %s\n", xfer->len,
		  (tx != NULL) ? "tx" : "  ",
		  (rx != NULL) ? "rx" : "  ");

	if (tx) {
		for (count = 0; count < xfer->len; count++) {
			rt2880_spi_write(rs, RAMIPS_SPI_DATA, tx[count]);
			rt2880_spi_setbits(rs, RAMIPS_SPI_CTL, SPICTL_STARTWR);
			err = rt2880_spi_wait_till_ready(rs);
			if (err) {
				dev_err(&spi->dev, "TX failed, err=%d\n", err);
				goto out;
			}
		}
	}

	if (rx) {
		for (count = 0; count < xfer->len; count++) {
			rt2880_spi_setbits(rs, RAMIPS_SPI_CTL, SPICTL_STARTRD);
			err = rt2880_spi_wait_till_ready(rs);
			if (err) {
				dev_err(&spi->dev, "RX failed, err=%d\n", err);
				goto out;
			}
			rx[count] = (u8) rt2880_spi_read(rs, RAMIPS_SPI_DATA);
		}
	}

out:
	return count;
}

static unsigned int
mt7621_spi_write_read(struct spi_device *spi, struct list_head *list, struct spi_transfer *xfer)
{
	struct rt2880_spi *rs = spidev_to_rt2880_spi(spi);
	struct spi_transfer *next = NULL;
	const u8 *tx = xfer->tx_buf;
	u8 *rx = NULL;
	u32 trans;
	int len = xfer->len;

	if (!tx)
		return 0;

	if (!list_is_last(&xfer->transfer_list, list)) {
		next = list_entry(xfer->transfer_list.next, struct spi_transfer, transfer_list);
		rx = next->rx_buf;
	}

	trans = rt2880_spi_read(rs, MT7621_SPI_TRANS);
	trans &= ~SPI_CTL_TX_RX_CNT_MASK;

	if (tx) {
		u32 data0 = 0, opcode = 0;

		switch (xfer->len) {
		case 8:
			data0 |= tx[7] << 24;
		case 7:
			data0 |= tx[6] << 16;
		case 6:
			data0 |= tx[5] << 8;
		case 5:
			data0 |= tx[4];
		case 4:
			opcode |= tx[3] << 8;
		case 3:
			opcode |= tx[2] << 16;
		case 2:
			opcode |= tx[1] << 24;
		case 1:
			opcode |= tx[0];
			break;

		default:
			dev_err(&spi->dev, "trying to write too many bytes: %d\n", next->len);
			return -EINVAL;
		}

		rt2880_spi_write(rs, MT7621_SPI_DATA0, data0);
		rt2880_spi_write(rs, MT7621_SPI_OPCODE, opcode);
		trans |= xfer->len;
	}

	if (rx)
		trans |= (next->len << 4);
	rt2880_spi_write(rs, MT7621_SPI_TRANS, trans);
	trans |= SPI_CTL_START;
	rt2880_spi_write(rs, MT7621_SPI_TRANS, trans);

	mt7621_spi_wait_till_ready(rs);

	if (rx) {
		u32 data0 = rt2880_spi_read(rs, MT7621_SPI_DATA0);
		u32 opcode = rt2880_spi_read(rs, MT7621_SPI_OPCODE);

		switch (next->len) {
		case 8:
			rx[7] = (opcode >> 24) & 0xff;
		case 7:
			rx[6] = (opcode >> 16) & 0xff;
		case 6:
			rx[5] = (opcode >> 8) & 0xff;
		case 5:
			rx[4] = opcode & 0xff;
		case 4:
			rx[3] = (data0 >> 24) & 0xff;
		case 3:
			rx[2] = (data0 >> 16) & 0xff;
		case 2:
			rx[1] = (data0 >> 8) & 0xff;
		case 1:
			rx[0] = data0 & 0xff;
			break;

		default:
			dev_err(&spi->dev, "trying to read too many bytes: %d\n", next->len);
			return -EINVAL;
		}
		len += next->len;
	}

	return len;
}

static int rt2880_spi_transfer_one_message(struct spi_master *master,
					   struct spi_message *m)
{
	struct rt2880_spi *rs = spi_master_get_devdata(master);
	struct spi_device *spi = m->spi;
	struct spi_transfer *t = NULL;
	int par_override = 0;
	int status = 0;
	int cs_active = 0;

	/* Load defaults */
	status = rt2880_spi_setup_transfer(spi, NULL);
	if (status < 0)
		goto msg_done;

	list_for_each_entry(t, &m->transfers, transfer_list) {
		if (t->tx_buf == NULL && t->rx_buf == NULL && t->len) {
			dev_err(&spi->dev,
				"message rejected: invalid transfer data buffers\n");
			status = -EIO;
			goto msg_done;
		}

		if (t->speed_hz && t->speed_hz < (rs->sys_freq / 128)) {
			dev_err(&spi->dev,
				"message rejected: device min speed (%d Hz) exceeds required transfer speed (%d Hz)\n",
				(rs->sys_freq / 128), t->speed_hz);
			status = -EIO;
			goto msg_done;
		}

		if (par_override || t->speed_hz || t->bits_per_word) {
			par_override = 1;
			status = rt2880_spi_setup_transfer(spi, t);
			if (status < 0)
				goto msg_done;
			if (!t->speed_hz && !t->bits_per_word)
				par_override = 0;
		}

		// Manfeel: get the chipselect number		
		rs->chipselect = spi->chip_select;

		if (!cs_active) {
			rs->ops->set_cs(rs, 1);
			cs_active = 1;
		}

		if (t->len)
			m->actual_length += rs->ops->write_read(spi, &m->transfers, t);

		if (t->delay_usecs)
			udelay(t->delay_usecs);

		if (t->cs_change) {
			rs->ops->set_cs(rs, 0);
			cs_active = 0;
		}
	}

msg_done:
	if (cs_active)
		rs->ops->set_cs(rs, 0);

	m->status = status;
	spi_finalize_current_message(master);

	return 0;
}

static int rt2880_spi_setup(struct spi_device *spi)
{
	struct rt2880_spi *rs = spidev_to_rt2880_spi(spi);

	if ((spi->max_speed_hz == 0) ||
	    (spi->max_speed_hz > (rs->sys_freq / 2)))
		spi->max_speed_hz = (rs->sys_freq / 2);

	if (spi->max_speed_hz < (rs->sys_freq / 128)) {
		dev_err(&spi->dev, "setup: requested speed is too low %d Hz\n",
			spi->max_speed_hz);
		return -EINVAL;
	}

	/*
	 * baudrate & width will be set rt2880_spi_setup_transfer
	 */
	return 0;
}

static void rt2880_spi_reset(struct rt2880_spi *rs)
{
	rt2880_spi_write(rs, RAMIPS_SPI_CFG,
			 SPICFG_MSBFIRST | SPICFG_TXCLKEDGE_FALLING |
			 SPICFG_SPICLK_DIV16 | SPICFG_SPICLKPOL);
	rt2880_spi_write(rs, RAMIPS_SPI_CTL, SPICTL_HIZSDO | SPICTL_SPIENA);

	// Manfeel: set CS1 pin
	void __iomem *base_gpio = rs->base - 0xb00;
	u32 val_gpio = ioread32(base_gpio + RAMIPS_SPI_GPIO);
	val_gpio &= ~(3 << 11);
	iowrite32(val_gpio,base_gpio + RAMIPS_SPI_GPIO);
}

static void mt7621_spi_reset(struct rt2880_spi *rs)
{
	u32 master = rt2880_spi_read(rs, MT7621_SPI_MASTER);

	master &= ~(0xfff << 16);
	master |= 3 << 16;

	master |= 7 << 29;
	rt2880_spi_write(rs, MT7621_SPI_MASTER, master);
}

static struct rt2880_spi_ops spi_ops[] = {
	{
		.init_hw = rt2880_spi_reset,
		.set_cs = rt2880_spi_set_cs,
		.baudrate_set = rt2880_spi_baudrate_set,
		.write_read = rt2880_spi_write_read,
	}, {
		.init_hw = mt7621_spi_reset,
		.set_cs = mt7621_spi_set_cs,
		.baudrate_set = mt7621_spi_baudrate_set,
		.write_read = mt7621_spi_write_read,
	},
};

static const struct of_device_id rt2880_spi_match[] = {
	{ .compatible = "ralink,rt2880-spi", .data = &spi_ops[0]},
	{ .compatible = "ralink,mt7621-spi", .data = &spi_ops[1] },
	{},
};
MODULE_DEVICE_TABLE(of, rt2880_spi_match);

static int rt2880_spi_probe(struct platform_device *pdev)
{
        const struct of_device_id *match;
	struct spi_master *master;
	struct rt2880_spi *rs;
	unsigned long flags;
	void __iomem *base;
	struct resource *r;
	int status = 0;
	struct clk *clk;

        match = of_match_device(rt2880_spi_match, &pdev->dev);
	if (!match)
		return -EINVAL;

	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	base = devm_ioremap_resource(&pdev->dev, r);
	if (IS_ERR(base))
		return PTR_ERR(base);

	clk = devm_clk_get(&pdev->dev, NULL);
	if (IS_ERR(clk)) {
		dev_err(&pdev->dev, "unable to get SYS clock, err=%d\n",
			status);
		return PTR_ERR(clk);
	}

	status = clk_prepare_enable(clk);
	if (status)
		return status;

	master = spi_alloc_master(&pdev->dev, sizeof(*rs));
	if (master == NULL) {
		dev_dbg(&pdev->dev, "master allocation failed\n");
		return -ENOMEM;
	}

	/* we support only mode 0, and no options */
	master->mode_bits = 0;

	master->setup = rt2880_spi_setup;
	master->transfer_one_message = rt2880_spi_transfer_one_message;
	master->num_chipselect = RALINK_NUM_CHIPSELECTS;
	master->bits_per_word_mask = SPI_BPW_MASK(8);
	master->dev.of_node = pdev->dev.of_node;

	dev_set_drvdata(&pdev->dev, master);

	rs = spi_master_get_devdata(master);
	rs->base = base;
	rs->clk = clk;
	rs->master = master;
	rs->sys_freq = clk_get_rate(rs->clk);
	rs->ops = (struct rt2880_spi_ops *) match->data;
	dev_dbg(&pdev->dev, "sys_freq: %u\n", rs->sys_freq);
	spin_lock_irqsave(&rs->lock, flags);

	device_reset(&pdev->dev);

	rs->ops->init_hw(rs);

	return spi_register_master(master);
}

static int rt2880_spi_remove(struct platform_device *pdev)
{
	struct spi_master *master;
	struct rt2880_spi *rs;

	master = dev_get_drvdata(&pdev->dev);
	rs = spi_master_get_devdata(master);

	clk_disable(rs->clk);
	spi_unregister_master(master);

	return 0;
}

MODULE_ALIAS("platform:" DRIVER_NAME);

static struct platform_driver rt2880_spi_driver = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table = rt2880_spi_match,
	},
	.probe = rt2880_spi_probe,
	.remove = rt2880_spi_remove,
};

module_platform_driver(rt2880_spi_driver);

MODULE_DESCRIPTION("Ralink SPI driver");
MODULE_AUTHOR("Sergiy <piratfm@gmail.com>");
MODULE_AUTHOR("Gabor Juhos <juhosg@openwrt.org>");
MODULE_LICENSE("GPL");
