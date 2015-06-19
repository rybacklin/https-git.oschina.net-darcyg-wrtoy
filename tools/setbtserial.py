#!/usr/bin/python
# -*- coding: utf-8 -*-

##############################################################################
#                                                                            #
#    This is an example of how to use the SerialAT class                     #
#                                                                            #
#    Python 3.X is not supported yet... :-(                                  #
#    Be sure you are using Python 2.X and have already installed PySerial    #
#    Python 2.X is available on: https://www.python.org/download             #
#    PySerial is available on: https://pypi.python.org/pypi/pyserial         #
#                                                                            #
##############################################################################

# Currently 'import SerialAT' is not supported
from SerialAT import *
import time


# AT() returns a dict
# 'suc' - succeeded to receive the response and result strings
# 'arg' - a list of strings : the parameters found from response string
# 'end' - the received result string

class BtATSet:
    device="/dev/ttyUSB0"
    baud=57600
    defbaud=9600
    debug=False
    def __init__(self,dev="/dev/ttyUSB0",baud=57600,debug=False):
      self.at=SerialAT()
      self.debug=debug
      self.at.setDebug(debug)
      self.device=dev
      self.baud=baud
      
    def open(self):
      self.at=SerialAT()
      self.at.serialInit(self.device,self.baud)
      self.at.serialOpen()

    def reset(self):
      self.at.serialReset()

    def close(self):
      self.at.serialClose()
      
    def open_at_baud(self,baud=57600):
      #self.closeauto()
      if baud != self.baud: self.baud=baud
      #print self.baud
      self.open()
      
    def chk_at(self,baud=-1):
      #self.at.AT('    ',{'re':('OK','ERROR'),'req':''},0.20)
      self.at.AT('    ',{'re':('OK','ERROR'),'req':''},0.20)
      self.at.AT('   ',{'re':('OK','ERROR'),'req':''},0.20)
      result = self.at.AT('AT',{'re':('OK','ERROR'),'req':'OK'},0.20)
      #result = self.at.AT('AT',{'re':('OK','ERROR'),'req':'OK'},0.10)
      if baud == -1: baud=self.baud
      if self.debug: print baud, result
      if "OK" == result['re']:
        print "BtSerial %s is baud %d bps"%(self.device,baud)
        #if baud != self.defbaud:
        #  print "  no auto set baud %d bps"%(baud)
      else:
        print "BtSerial %s not baud %d bps"%(self.device,baud)
      return (result["re"]=="OK") if True else False
        
    def set_new_baud(self,baud=57600):
      bauds=[1200,2400,4800,9600,19200,38400,57600,115200,230400,460800,921600,1382400]
      c=1
      t=4
      for i in bauds:
        if i == baud : 
          t=c
          break
        c+=1
      result = self.at.AT("AT+BAUD%X "%(t),{'re':('OK','ERROR'),'req':'+BAUD'},0.10)
      if self.debug: print baud, result
      return (result["re"]=="OK") if True else False

    def set_new_name(self,name):
      result = self.at.AT("AT+NAME%s "%(name),{'re':('OK','ERROR'),'req':'+NAME'},0.10)
      if self.debug: print result
      return (result["re"]=="OK") if True else False

    def exit(self):
      self.at.serialClose()

    def forceBtSet(self,newName="SPP-CA",targetBaud=57600,baseBaud=9600):
      baud=targetBaud
      self.close()
      self.open_at_baud(baud)
      print "step 1 :",
      if self.chk_at():
        if self.set_new_name(newName):
          print "    set new name (%s) ok!"%(newName)
        else:
          print "    not new name (%s) err!"%(newName)
        self.close()

        print "  btserial baud is %s bps, exit..."%(str(baud))
        return
      self.close()
      baud=baseBaud
      self.open_at_baud(baud)
      print "step 2 :",
      if self.chk_at():
        print "  btserial baud is %s bps, will set btserial baud at %s bps"%(str(baseBaud),str(targetBaud))

        if self.set_new_name(newName):
          print "    set new name (%s) ok!"%(newName)
        else:
          print "    not new name (%s) err!"%(newName)
        if self.set_new_baud(targetBaud):
          print "    btserial baud is %s bps.."%(str(targetBaud))
        else:
          print "    btserial baud not set %s bps.."%(str(targetBaud))

      else:
        print "  btserial baud at ???? bps, error!!!!!"
      self.close()
      baud=targetBaud
      self.open_at_baud(baud)
      print "step 3 :",
      if self.chk_at():
        print "  btserial baud is %s bps, exit..."%(str(baud))
      self.close()

if __name__ == '__main__': 
  bt=BtATSet(debug=False)
  #bt.forceBtSet("SPP-CA",9600,57600)
  bt.forceBtSet("SPP-SEWAGE",57600,9600)

