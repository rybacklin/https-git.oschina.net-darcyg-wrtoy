#!/bin/bash

[ -f $(pwd)/$1/options.bash ] && source $(pwd)/$1/options.bash
[ -f $(pwd)/$1/expand.bash ] && source $(pwd)/$1/expand.bash

now()
{
  date +%Y%m%d-%H%M%S
}

nowy()
{
  date +%Y
}

nowm()
{
  date +%m
}

nowd()
{
  date +%d
}

nowym()
{
  date +%Y%m
}

nowd()
{
  date +%d
}

nowmd()
{
  date +%m%d
}

nowh()
{
  date +%H
}

nowhm()
{
  date +%H%M
}

nowms()
{
  date +%M%S
}

nowmsns()
{
  date +%M%S%N
}

nowt()
{
  date +%H%M%S
}

nowtns()
{
  date +%H%M%S%N
}

chk_aptlib_install()
{
  local pack=`dpkg -l | awk '{print \$2}' | grep -x "$1"`
  if [ "$1" == "$pack" ]; then
    echo "$1"
  fi
}

chk_multi_aptlib()
{
  #echo $@ $#
  #b=0
  local e=0
  for s in ${@}
  do
    #b=$((b+1))
    local sv=`chk_aptlib_install $s`
    if [ -n "$sv" ]; then e=$((e+1)); fi
  done
  if [ $e -eq $# ]; then echo 0; else echo 1; fi
}

install_apt_pack()
{
  #echo $@
  #arr=(${@//\|/})
  local nline=$(echo $@|tr ' ' ','|tr -s ' ')
  local arr=($(echo $nline|tr '|' ' '|tr -s ' '))
  local arrlen=$((${#arr[@]}-1))
  local aptlib=${arr[$arrlen]}
  #echo $aptlib

  if [ ! -z $aptlib ]; then
    local aptlist=$(echo $aptlib|tr ',' ' '|tr -s ' ')
    local isapt=`chk_multi_aptlib $aptlist`
    if [ "$isapt" -eq 0 ]; then
      echo "apt-get has installed $aptlist"
    else
      echo "apt-get need install $aptlist"
      for s in ${arr[*]}
      do
        local skip=0
        #'ppa:webupd8team/java'
        local hasppa=`echo $s | grep "^ppa\:"`
        if [ ! -z $hasppa ] && [ "$skip" -eq 0 ]; then
          echo "find $hasppa"
          sudo add-apt-repository $hasppa
          skip=1
        fi

        local hasupdate=`echo $s | grep -x "update"`
        if [ ! -z $hasupdate ] && [ "$skip" -eq 0 ]; then
          echo "apt library $hasupdate ..."
          sudo apt-get update
          skip=1
        fi

        local hasupgrade=`echo $s | grep -x "upgrade"`
        if [ ! -z $hasupgrade ] && [ "$skip" -eq 0 ]; then
          echo "apt library $hasupgrade ..."
          sudo apt-get upgrade
          skip=1
        fi

        local hasfix=`echo $s | grep -x "fix"`
        if [ ! -z $hasfix ] && [ "$skip" -eq 0 ]; then
          echo "apt library install --fix-missing [apt-get -f install] ..."
          sudo apt-get -f install
          skip=1
        fi

        local hasforce=`echo $s | grep -x "force"`
        local force=""
        if [ ! -z $hasforce ] && [ "$skip" -eq 0 ]; then
          echo "  mode : $hasforce"
          force="-y"
          skip=1
        fi
        
        #local hasremove=`echo $s | grep -x "remove"`
        #if [ ! -z $hasremove ] && [ "$skip" -eq 0 ]; then
        #  echo "apt library $hasupgrade ..."
        #  sudo apt-get remove $aptlist
        #  skip=1
        #fi

        #local haspurge=`echo $s | grep -x "purge"`
        #if [ ! -z $haspurge ] && [ "$skip" -eq 0 ]; then
        #  echo "apt library $haspurge ..."
        #  sudo apt-get purge $aptlist
        #  skip=1
        #fi

        #local haspclean=`echo $s | grep -x "clean"`
        #if [ ! -z $haspclean ] && [ "$skip" -eq 0 ]; then
        #  echo "apt library $haspclean ..."
        #  sudo apt-get clean $aptlist
        #  skip=1
        #fi

        if [ "$skip" -eq 0 ] && [ ! -z $s ]; then
          aptlist=$(echo $s|tr ',' ' '|tr -s ' ')
          isapt=`chk_multi_aptlib $aptlist`
          #echo $isapt
          if [ "$isapt" -eq 0 ]; then
            echo "apt-get has installed $aptlist"
          else
            echo "apt-get install $aptlist ..."
            sudo apt-get install -y $aptlist
          fi
          skip=1;
        fi
      done
    fi
  fi
}

chmod_user()
{
  local tmp_dir=$1
  local tmp_usr=$2 
  if [ -z "$tmp_usr" ]; then
    tmp_usr=$USER
  fi
  sudo chown -Rf $tmp_usr:$tmp_usr $tmp_dir
  #sudo chmod a+w $tmp_dir
}

chk_mkdir()
{
  local tmp_dir=$1
  local tmp_usr=$3  
  if [ -z "$tmp_usr" ]; then
    tmp_usr=$USER
  fi
  if [ ! -d $tmp_dir ]; then
    echo "mkdir $tmp_dir"
    if [ "$2" == "sudo" ]; then
      sudo mkdir -p $tmp_dir
      sudo chown $tmp_usr:$tmp_usr $tmp_dir
      sudo chmod a+w $tmp_dir
    else
      mkdir -p $tmp_dir
    fi
  fi
}

chk_downfile()
{
  local tmp_url=$1
  local tmp_file=$2
  local useContinue=$3
  local tmp_bak=$tmp_file.bak
  echo "==DOWNLOAD============================"
  echo "  URL       : $tmp_url"
  echo "  localfile : $tmp_file"
  echo "======================================"
  if [ ! -f $tmp_file ]; then
    if [ "$useContinue" == "yes" ]; then
      #echo "==yes"
      wget -N -c --max-redirect 5 -O $tmp_bak $tmp_url
    else
      #echo "==no"
      if [ -f $tmp_bak ]; then
        rm -rf $tmp_bak
      fi
      wget -N --max-redirect 5 -O $tmp_bak $tmp_url
    fi
    mv $tmp_bak  $tmp_file
    echo "Download $tmp_file OK!"
  fi
}

trim() {
    echo $@
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

chk_pathrc()
{
  local tmp_stat=`cat ~/.bashrc | sed -e 's/^ *//g' -e 's/ *$//g' | grep "^source ~\/.config\/.pathrc$"`
  if [ ! -z "$tmp_stat" ]; then
    #echo "result 1: $tmp_stat"
    tmp_stat=""
  else
    #echo "result 2: $tmp_stat"
    `echo "source ~/.config/.pathrc" >> ~/.bashrc`
  fi

  if [ ! -f ~/.config/.pathrc ]; then
    echo "init ~/.config/.pathrc"
    `echo "# export PATH " > ~/.config/.pathrc`
    `echo "PATH=$PATH" >> ~/.config/.pathrc`
  fi
}

chk_addpath()
{
  chk_pathrc
  local tmp_mode=$1
  local tmp_name=$2
  local tmp_path=$3
  local tmp_nopath=0

  local tmp_arr=(${PATH//:/ })
  for tmp_item in ${tmp_arr[@]}
  do
    #echo $tmp_item  $tmp_path
    if [ "$tmp_item" == "$tmp_path" ]; then
      tmp_nopath=1
    fi
  done
  #echo $tmp_nopath
  if [ "$tmp_nopath" -eq 0 ]; then
    local has_name=`cat ~/.config/.pathrc | awk -F '=' '{print $1}' | grep "$tmp_name"`
    #echo "has_name ===> $has_name"
    if [ ! -z $has_name ]; then
      #查找替换
      local tmp_awk_param="{gsub(/^$tmp_name[a-zA-Z0-9\:\-\_\=\/\s\t\?\$]*/,\"$tmp_name=$tmp_path\");print}"
      local tmp_data=`awk $tmp_awk_param ~/.config/.pathrc `
      echo "REPLACE PATH : $tmp_name=$tmp_path"
      #echo $tmp_data
      `echo "$tmp_data" > ~/.config/.pathrc`
    else
      # 缓存PATH路径
      local tmp_old_path=`awk '{print $1}' ~/.config/.pathrc |  awk -F '=' '{print $1 "#" $0}' | grep "^PATH" | awk -F '#' '{print $2}'`
      # 替换PATH路径为$tmp_name
      local tmp_awk_param="{gsub(/^PATH[a-zA-Z0-9\:\-\_\=\/\s\t\?\$]*/,\"$tmp_name=$tmp_path\");print}"
      local tmp_data=`cat ~/.config/.pathrc | awk $tmp_awk_param `
      #echo "================"
      #echo "$tmp_data"
      #echo "================"
      `echo "$tmp_data" > ~/.config/.pathrc`
      local tmp_arr=(${tmp_old_path//=/ })

      #写新的PATH路径
      if [ "$tmp_mode" -eq 1 ]; then
        local tmp_Ppath=${tmp_arr[0]}=\$$tmp_name:${tmp_arr[1]}
      else
        local tmp_Ppath=${tmp_arr[0]}=${tmp_arr[1]}:\$$tmp_name
      fi

      echo "ADD PATH : $tmp_name=$tmp_path"
      `echo "$tmp_Ppath" >> ~/.config/.pathrc`
    fi
    source ~/.config/.pathrc
  else
    echo "PATH EXISTED : $tmp_name=$tmp_path"
  fi
}

edit_conf_line()
{
  local src_conf=$1
  local tmp_conf=/tmp/__redisconf
  local tmp_str=$2
  local tmp_val=$3
  local tmp_sudo=$4
  show i "配置修改:  $tmp_str ==> $tmp_val"
  #show i $tmp_val
  #show i $tmp_sudo
  #echo "cat $src_conf | grep -x \"$tmp_str\""
  local tmp=`cat $src_conf | grep -x "$tmp_str"`
  if [ ! -z "$tmp" ]; then
    show s "配置$tmp_str存在,修改配置"
    if [ -f $src_conf ]; then
      #echo 'sudo sed "/'$tmp_str'/c\'$tmp_val"\" $tmp_conf > $tmp_conf"
      $tmp_sudo sh -c "cat $src_conf | sed \"/$tmp_str/c\\$tmp_val\" > $tmp_conf"
      if [ -f $tmp_conf ]; then
        $tmp_sudo mv -f $tmp_conf $src_conf
      fi
    else
      $tmp_sudo sh -c "echo \"$tmp_val\" > $src_conf"
    fi
  else
    tmp=`cat $src_conf | grep -x "$tmp_val"`
    if [ -z "$tmp" ]; then
      show s "配置$tmp_val不存在,添加配置"      
      $tmp_sudo sh -c "echo \"$tmp_val\" > $src_conf"
    else
      show s "配置$tmp_val存在,不修改" 
    fi
  fi
}

chk_gitcloneurl()
{
  local projname=$1
  local projdir=$2
  local projurl=$3
  if [ ! -d $projdir ]; then
    show s "git 克隆 $projname"
    #cd $projdir/..
    git clone $projurl
    #cd $projdir
  fi
}

chk_gitcloneurl_ex()
{
  local projname=$1
  local rootdir=$2
  local projurl=$3
  local projdir=$4
  local branch=$5
  chk_mkdir $rootdir
  cd $rootdir
  if [ ! -d $projdir ]; then
    show s "git 克隆 $projname"
    git clone $projurl
    cd $projdir
    git checkout $branch
  else
    show s "git 升级 $projname"
    cd $projdir
    git reset --hard
    git fetch
    git checkout -f $branch
  fi
}

set_pythonenv()
{
  sudo chmod a+r /usr/local/lib/python2.7/dist-packages/ -Rf
}

install_pip_pack()
{
  local packs=$@
  for item in ${packs[@]}
  do
    local hasInstallPack=`pip show $item`
    if [ -z "$hasInstallPack" ]; then
      show i "pip安装$item项目"
      sudo pip install $item -i http://pypi.v2ex.com/simple
    else
      show s "pip已经安装$item项目"
    fi
  done
}

install_pip_git()
{
  local tmp_name=$1
  local tmp_dir=$3
  local tmp_url=$2
  local hasInstallPack=`pip show $tmp_name`
  if [ -z "$hasInstallPack" ]; then
    local tmp_gitroot=/tmp/gitroot
    chk_mkdir $tmp_gitroot
    cd $tmp_gitroot

    if [ -d $tmp_dir ]; then
      show i "git拉取$tmp_name项目默认分支的最新版本"
      cd $tmp_dir
      git pull
    else
      show i "git克隆$tmp_name项目"
      git clone $tmp_url
      cd $tmp_dir
    fi
    sudo python setup.py install
  else
    show s "pip已经安装$tmp_name项目"
  fi
}

show_text()
{
  local mode=$1
  local infos=$@
  local info=${infos[@]:1}
  if [ $mode == "t" ]; then
    echo " "
    echo "###==INSTALL====================================###"
    #echo " "
    echo "    $info"
    echo " "
  elif [ $mode == "i" ]; then
    echo "@@@  $info ..."
  elif [ $mode == "s" ]; then
    echo "==>  $info"
  elif [ $mode == "d" ]; then
    echo "$info"
  elif [ $mode == "l" ]; then
    echo "==================================================="
  else
    echo "$info"
  fi
}

show()
{
  show_text $@
}

is_server_old()
{
  local tmp_val=`dpkg -l | awk '{print $2}' | grep xserver`
  if [ -z "$tmp_val" ]; then 
    echo "1" 
  else 
    echo "0"
  fi
}

is_desktop_old()
{
  local tmp_val=`dpkg -l | awk '{print $2}' | grep xserver`
  #tmp_val=""
  if [ ! -z "$tmp_val" ]; then 
    echo "1"
  else 
    echo "0"
  fi
}


tabnl()
{
  local tmp_count=$[$1*2]
  #local tmp_str=$2
  local tmp_mode=$2
  local tmp_t=""
  for i in $(seq $tmp_count)
  do
    tmp_t+="\x20"
  done
  #echo "\n$tmp_t$tmp_str"
  if [ -z $tmp_mode ]; then
    echo "\n$tmp_t"
  else
    echo "$tmp_t"
  fi
}

gen_website_conf()
{
  local sname=$1
  local sip4=$2
  #local sip6=$3
  local sport=$3
  local sroot=$4
  local sphp=$5
  local tmp=""
  tmp+=`tabnl 0 f`"server {"
  if [ "$sname" == "default" ]; then
	  tmp+=`tabnl 1`"listen $sip4:$sport default_server;"
  else
    tmp+=`tabnl 1`"listen $sip4:$sport;"
  fi
	#tmp+=`tabnl 1`"listen [::]:$sip default_server ipv6only=on;"
	tmp+="\n"
  tmp+=`tabnl 1`"root $sroot;"
	tmp+=`tabnl 1`"index default.php index.php default.html default.htm index.html index.htm;"
	tmp+="\n"	
  tmp+=`tabnl 1`"server_name $sname;"
	tmp+="\n"	
	tmp+=`tabnl 1`"location / {"
	tmp+=`tabnl 2`'try_files \$uri \$uri/ /index.php;'
	tmp+=`tabnl 2`"# include /etc/nginx/naxsi.rules"
	tmp+=`tabnl 1`"}"
	tmp+="\n"	
  if [ "$sname" == "default" ]; then
	  tmp+=`tabnl 1`"location /doc/ {"
	  tmp+=`tabnl 2`"alias /usr/share/doc/;"
	  tmp+=`tabnl 2`"autoindex on;"
	  tmp+=`tabnl 2`"allow 127.0.0.1;"
	  #tmp+=`tabnl 2`"allow ::1;"
	  tmp+=`tabnl 2`"deny all;"
	  tmp+=`tabnl 1`"}"
	  tmp+="\n"	
  fi
  if [ ! -z $sphp ]; then
    tmp+=`tabnl 1`"location ~ \.php$ {"
    tmp+=`tabnl 2`"fastcgi_split_path_info ^(.+\.php)(/.+)$;"
    tmp+=`tabnl 2`"#fastcgi_pass 127.0.0.1:9000;"
    tmp+=`tabnl 2`"fastcgi_pass unix:/var/run/php5-fpm.sock;"
    tmp+=`tabnl 2`"fastcgi_index index.php;"
    tmp+=`tabnl 2`'#fastcgi_param SCRIPT_FILENAME /opt/website/itvyun.com/redis/html/\$fastcgi_script_name;'
    tmp+=`tabnl 2`"include fastcgi_params;"
    tmp+=`tabnl 1`"}"
	  tmp+="\n"	
  fi
  tmp+=`tabnl 0`"}"
	tmp+="\n"	
  #tmp+=`tabnl 1 ""`
  #tmp+=`tabnl 2 ""`
  echo -e $tmp
}

add_website_phptest()
{
  local tmp_title=$1
  local tmp_path=$2
  local tmp=""
  tmp+=`tabnl 0 f`"<?php"
  tmp+=`tabnl 0`'header(\"Cache-Control: no-cache\");'
  tmp+=`tabnl 0`'header(\"Pragma: no-cache\");'
  tmp+=`tabnl 0`'\$host=\$_SERVER[\"HTTP_HOST\"];'
  tmp+=`tabnl 0`"?>"
  tmp+=`tabnl 0`"<html><title>$tmp_title"'[<?php echo(\$host); ?>]</title><body><center>' 
  tmp+=`tabnl 0`"<?php"
  tmp+=`tabnl 0`'echo(\"host:\".\$host.\"<br>\");'
  tmp+=`tabnl 0`'echo(\"rand:\".rand(1000000,9999999));'
  tmp+=`tabnl 0`"phpinfo();"
  tmp+=`tabnl 0`"?>"
  tmp+=`tabnl 0`"</center></body></html>"
  sh -c "echo \"$tmp\" > $tmp_path"
}

create_website()
{
  local stitle=$1
  local sname=$2
  local sip4=$3
  #local sip6=$3
  local sport=$4
  local sroot=$5
  local sphp=$6
  if [ -z $stitle ]; then
    stitle=$sname
  fi
  local nginx_root=/etc/nginx
  local src_root=$nginx_root/sites-available
  local site_root=$nginx_root/sites-enabled
  local back_root=$nginx_root/backup
  local opt_root=/opt/website
  local tmp=`nowym`
  #echo $tmp
  local date_back_root=$back_root/`nowym`/
  #echo $date_back_root

  #local default_site_root=$opt_root/default/html
  local src_conf=$src_root/$sname
  local link_conf=$site_root/$sname

  local bak_conf=$date_back_root/$sname-`nowmd`-`nowtns`
  local last_conf=$back_root/last/$sname

  local webroot=$opt_root/$sroot

  #if [ "$sname" == "default" ]; then
  #  bak_conf=$back_root/$sname
  #else
  #  bak_conf=$back_root/`nowhm`/$sname-`nowmd`-`nowtns`
  #fi
  if [ -d $src_root ]; then
    show s "开始建立$sname网站"
    chk_mkdir $back_root sudo www-data
    chk_mkdir $back_root/last sudo www-data
    if [ ! -f $last_conf ]; then
      if [ -f $src_conf ]; then
        show s "拷贝$sname网站默认配置"
        cp -f $src_conf $last_conf.first
      fi
    fi
    show i "产生$sname网站配置文件"
    local tmp_conf=`gen_website_conf $sname $sip4 $sport $webroot $sphp`
    sudo sh -c "echo \"$tmp_conf\" > $src_conf"
    if [ ! -d $date_back_root ]; then
      chk_mkdir $date_back_root sudo www-data
    fi
    sudo sh -c "cp -f $src_conf $bak_conf"
    if [ -f $last_conf ]; then
      sudo rm -f $last_conf
    fi
    sudo sh -c "ln -s $bak_conf $last_conf"
    if [ ! -f $link_conf ]; then
      show i "使$sname网站配置文件.生效"
      sudo sh -c "ln -s $src_conf $link_conf"
    else
      show i "$sname网站配置文件.已生效"
    fi

    show s "$sname网站根目录:$webroot"
    if [ ! -d $webroot ]; then
      chk_mkdir $webroot sudo www-data
    fi

    show s "$sname网站默认文件:$webroot/index.php [$stitle]"
    if [ -f $webroot/index.php ]; then
      rm $webroot/index.php
    fi
    if [ ! -f $webroot/index.php ]; then
      add_website_phptest $stitle $webroot/index.php
    fi

  fi
}

create_website_adv()
{
  local tip=$4
  local tport=$5
  local site_id=$1
  local site_subdomain=$2
  local site_domain=$3

  if [ ! -z `chk_local_ip $tip` ]; then
    show t "配置主机网站:$site_subdomain.$site_domain"
    create_website $site_id $site_subdomain.$site_domain $tip $tport $site_domain/$site_subdomain/html php 
  fi
}

local_ips()
{
  #/sbin/ifconfig | grep -w "inet" | awk '{print $2}' | awk -F ":" '{print $2}'
  echo `/sbin/ifconfig | grep -w "inet" | awk '{print $2}' | awk -F ":" '{print $2}'`
}

chk_local_ip()
{
  local tmp_ip=$1
  echo `/sbin/ifconfig | grep -w "inet" | awk '{print $2}' | awk -F ":" '{print $2}' | grep -x "$tmp_ip"`
}

chk_php_pecl()
{
  local tmp_name=$1
  echo `pecl list | grep -w $tmp_name`
}

install_php_mod_conf()
{
  local mod=$1
  if [ ! -f /etc/php5/mods-available/$mod.ini ]; then
    sudo ln -s /etc/php5/conf.d/$mod.ini /etc/php5/mods-available/$mod.ini
    sudo php5enmod $mod
  fi
}

install_php_pecl()
{
  local tmp_name=$1
  local tmp_val=`chk_php_pecl $tmp_name`
  #echo $tmp_val
  if [ -z "$tmp_val" ]; then
    sudo pecl install $tmp_name
  fi
  local tmp_root=/etc/php5
  local tmp_mod=$tmp_root/mods-available
  local tmp_cli=$tmp_root/cli/conf.d
  local tmp_fpm=$tmp_root/fpm/conf.d
  local tmp_oho=$tmp_root/conf.d
  local tmp_ini=$tmp_name.ini
  if [ -d $tmp_mod ]; then  
    sudo sh -c "echo \"extension=$tmp_name.so\" > $tmp_mod/$tmp_ini"
  fi
  if [ -d $tmp_php ]; then  
    sudo sh -c "echo \"extension=$tmp_name.so\" > $tmp_php/$tmp_ini"
  fi
  if [ -d $tmp_cli ]; then  
    sudo sh -c "echo \"extension=$tmp_name.so\" > $tmp_cli/20-$tmp_ini"
  fi
  if [ -d $tmp_fpm ]; then  
    sudo sh -c "echo \"extension=$tmp_name.so\" > $tmp_fpm/20-$tmp_ini"
  fi
}

get_local_ip()
{
  echo `/sbin/ifconfig | grep -w "inet" | grep -v "127.0.0.1" | awk '{print $2}' | awk -F ":" '{print $2}'`
}

chk_haxe_lib()
{
  local tmp_name=$1
  echo "$(haxelib list | awk -F ':' '{print $1}' | grep -w $tmp_name )"
}

install_haxe_lib()
{
  local tmp_name=$1
  echo `chk_haxe_lib $tmp_name`
  if [ -z `chk_haxe_lib $tmp_name` ]; then
    show i "未安装HAXE库$tmp_name"
    haxelib install $tmp_name
  else
    show i "已安装HAXE库$tmp_name"
  fi
}

get_url_text()
{
  local tmp_url=$1
  local tmp_page=`curl -s $tmp_url`
  #tmp_page=`wget -q $tmp_url -O - | html2text`
  echo $tmp_page
}

install_haxe_alllib()
{
  local tmp_page=`get_url_text "http://lib.haxe.org/files/3.0/"`
  if [ ! -z "$tmp_page" ]; then
    local tmp_files=`echo "$tmp_page" | html2text | grep -Ev "[=\*]+|Apache|\[\[(ICO|DIR)\]\]" | awk '{line=$3;sub(/-[0-9]+,[0-9]+,[0-9]+[\-\,a-zA-Z0-9]*.zip/,"",line);print line}' | sort | uniq`
    local arr=($tmp_files)
    local arrlen=$((${#arr[@]}))
    local var_i=0    
    for l in ${arr[*]}
    do
      ((var_i+=1)) 
      show s "安装HAXE库 : $l ($var_i/$arrlen)"
      haxelib install $l
    done
  fi
}

enc_ase256_base64_str()
{
  local tmp_str=$1
  local tmp_key=$2
  local result=""
  if [ -z "$tmp_str" ]; then
    return 1
  fi
  if [ -z "$tmp_key" ]; then
    return 2
  fi
  result=`echo $tmp_str | openssl enc -aes-256-cfb -e -base64 -k $tmp_key -salt`
  echo $result
  return 0
}

dec_ase256_base64_str()
{
  local tmp_str=$1
  local tmp_key=$2
  local result=""
  if [ -z "$tmp_str" ]; then
    return 1
  fi
  if [ -z "$tmp_key" ]; then
    return 2
  fi
  result=`echo $tmp_str | openssl enc -aes-256-cfb -d -base64 -k $tmp_key -salt`
  echo $result
  return 0
}

enc_ase256_str()
{
  local tmp_str=$1
  local tmp_key=$2
  local result=""
  if [ -z "$tmp_str" ]; then
    return 1
  fi
  if [ -z "$tmp_key" ]; then
    return 2
  fi
  result=`echo $tmp_str | openssl enc -aes-256-cfb -e -k $tmp_key -salt`
  echo $result
  return 0
}

dec_ase256_str()
{
  local tmp_str=$1
  local tmp_key=$2
  local result=""
  if [ -z "$tmp_str" ]; then
    return 1
  fi
  if [ -z "$tmp_key" ]; then
    return 2
  fi
  result=`echo $tmp_str | openssl enc -aes-256-cfb -d -k $tmp_key -salt`
  echo $result
  return 0
}

read_ini()
{ 
  local INIFILE=$1
  local SECTION=$2
  local ITEM=$3
  if [ -f "$INIFILE" ]; then
    #echo "read_ini $INIFILE $SECTION $ITEM"
    #有bug
    ReadINI=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
    echo $ReadINI
  else
    echo ""
  fi
}

write_ini()
{ 
  local INIFILE=$1
  local SECTION=$2
  local ITEM=$3
  local NEWVAL=$4
  if [ -f "$INIFILE" ]; then
    #echo "000"
    local result=`read_ini $INIFILE $SECTION $ITEM`
    #echo $result
    if [ -z "$result" ]; then
      result=`grep -x "\[$SECTION\]" $INIFILE`
      if [ -z "$result" ]; then
        #echo "100"
        `sh -c "echo \"[$SECTION]\n$ITEM=$NEWVAL\" >> $INIFILE"`
      else
        #echo "200"
        #sleep 1
        `sed -i "s/^\[$SECTION\]/\[$SECTION\]\n$ITEM=$NEWVAL/g" $INIFILE`
        #sleep 1
      fi
    else
      #echo "300"
      #sleep 3
      `sed -i "/^\[$SECTION\]/,/^\[/ {/^\[$SECTION\]/b;/^\[/b;s/^$ITEM=.*/$ITEM=$NEWVAL/g;}" $INIFILE`
      #sleep 1
    fi
  else
    #echo "400"
    `sh -c "echo \"[$SECTION]\n$ITEM=$NEWVAL\" > $INIFILE"`
  fi
}

read_proj_ini()
{
  local tmp_item=$1
  local tmp_section=$2
  local tmp_ini=$3
  local result=""

  if [ -z "$tmp_item" ]; then
    $tmp_item="item01"
  fi

  if [ -z "$tmp_section" ]; then
    $tmp_section="default"
  fi

  if [ ! -f "$tmp_ini" ]; then
    tmp_ini=`echo ~/.proj.ini`
  fi

  if [ -f $tmp_ini ]; then
    result=`read_ini $tmp_ini $tmp_section $tmp_item`
  fi
  
  echo $result
}

write_proj_ini()
{
  local tmp_item=$1
  local tmp_value=$2
  local tmp_section=$3
  local tmp_ini=$4
  local result=""

  if [ -z "$tmp_item" ]; then
    $tmp_item="item01"
  fi

  if [ -z "$tmp_section" ]; then
    $tmp_section="default"
  fi

  if [ ! -f "$tmp_ini" ]; then
    tmp_ini=`echo ~/.proj.ini`
  fi
  #echo "$tmp_ini"
  #if [ -f "$tmp_ini" ]; then
  result=`write_ini $tmp_ini $tmp_section $tmp_item $tmp_value`
  #fi
  echo $result
  return 0
}

base64_enc()
{
  if [ ! -z "$1" ]; then
    echo `echo "$1" | base64 -w 0`
  else
    echo ""
  fi
}

base64_dec()
{
  if [ ! -z "$1" ]; then
    echo `echo "$1" | base64 -d`
  else
    echo ""
  fi
}

safestr_enc()
{
  if [ ! -z "$1" ]; then
    echo `echo "$1" | sed "s/=/#/g"`
  else
    echo ""
  fi
}

safestr_dec()
{
  if [ ! -z "$1" ]; then
    echo `echo "$1" | sed "s/#/=/g"`
  else
    echo ""
  fi
}

safeb64_enc()
{
  if [ ! -z "$1" ]; then
    local tmp=`echo "$1" | base64 -w 0`
    echo `echo "$tmp" | sed "s/=/#/g"`
  else
    echo ""
  fi
}

safeb64_dec()
{
  if [ ! -z "$1" ]; then
    local tmp=`echo "$1" | sed "s/#/=/g"`
    echo `echo "$tmp" | base64 -d`
  else
    echo ""
  fi
}

read_bproj_ini()
{
  local result=`read_proj_ini $1 $2 $3`
  if [ ! -z "$result" ]; then
    echo `safeb64_dec $result`
  else
    echo ""
  fi
}

write_bproj_ini()
{
  local b64=""
  if [ ! -z "$2" ]; then
    b64=`safeb64_enc $2`
  fi
  #echo $b64
  echo `write_proj_ini $1 $b64 $3 $4`
}

set_secure_key()
{
  local item=`safeb64_enc _secure_key_`
  local section=`safeb64_enc _default_secure_`
  #echo $section
  #echo $item
  local ini=`echo ~/.proj.ini`
  #echo $ini
  `write_bproj_ini $item $1 $section $ini`
}

get_secure_key()
{
  local item=`safeb64_enc _secure_key_`
  local section=`safeb64_enc _default_secure_`
  local ini=`echo ~/.proj.ini`
  echo `read_bproj_ini $item $section $ini`
}

read_eproj_ini()
{
  local result=`read_proj_ini $1 $2 $3`
  local skey=`get_secure_key`
  #echo "$result $skey"
  if [ ! -z "$result" -a ! -z "$skey" ]; then
    result=`safestr_dec $result`
    result=`dec_ase256_base64_str $result $skey`
    echo $result
  else
    echo ""
  fi
}

write_eproj_ini()
{
  local skey=`get_secure_key`
  if [ ! -z "$skey" -a ! -z "$2" ]; then 
    local result=`enc_ase256_base64_str $2 $skey`
    result=`safestr_enc $result`
    result=`write_proj_ini $1 $result $3 $4`
    echo $result
  else
    echo ""
  fi
}

get_sproj_ini()
{
  local _item=$1
  local _section=$2
  local ini=`echo $3`
  if [ -z "$_item" ]; then
    _item="item01"
  fi
  if [ -z "$_section" ]; then
    _section="default"
  fi
  if [ -z "$ini" -o ! -f "$ini" ]; then
    _section=`echo ~/.proj.ini`
  fi
  local item=`safeb64_enc $_item`
  local section=`safeb64_enc $_section`
  echo `read_eproj_ini $item $section $_ini`
}

set_sproj_ini()
{
  local _item=$1
  local newval=$2
  local _section=$3
  local ini=`echo $4`
  if [ -z "$_item" ]; then
    _item="item01"
  fi
  if [ -z "$_section" ]; then
    _section="default"
  fi
  if [ -z "$ini" -o ! -f "$ini" ]; then
    _section=`echo ~/.proj.ini`
  fi
  local item=`safeb64_enc $_item`
  local section=`safeb64_enc $_section`
  echo `write_eproj_ini $item $newval $section $_ini`
}

expect_scp()
{
  local tmp_hst=$1
  local tmp_usr=$2
  local tmp_pwd=$3
  echo " =================================="
  echo "   自动登陆scp数据拷贝"
  echo "   HOST: $tmp_hst"
  echo "   USER: $tmp_usr"
  echo " =================================="
  local tmp_src=$4
  local tmp_dst=$5

  expect -c "
      set force_conservative 0 ;
      set timeout 15
      spawn scp {*}[split $tmp_src \",\"] \"$tmp_usr@$tmp_hst:$tmp_dst\"
      expect yes/no { send yes\r ; exp_continue }
      expect password: { send $tmp_pwd\r }
      expect 100% { exp_continue }
      sleep 0.5
      exit
  "
}

expect_scps()
{
  local tmp_hst=$1
  local tmp_usr=$2
  local tmp_pwd=$3
  echo " =================================="
  echo "   自动登陆scp数据拷贝"
  echo "   HOST: $tmp_hst"
  echo "   USER: $tmp_usr"
  echo " =================================="
  local tmp_src=$4
  local tmp_dst=$5

  expect -c "
      set force_conservative 0 ;
      set timeout 15
      spawn -noecho bash
      send \"scp -r [split $tmp_src \"|\"] $tmp_usr@$tmp_hst:$tmp_dst\r\"
      expect yes/no { send yes\r ; exp_continue }
      expect password: { send $tmp_pwd\r }
      expect 100% {
        expect \\\\$ { 
          #puts \"scp finished!\";
          puts \" \"
          send exit\r
        }
      }
      sleep 0.5
      exit
  "
}

expect_ssh()
{
  local tmp_hst=$1
  local tmp_usr=$2
  local tmp_pwd=$3
  local tmp_cmd=$4
  echo " =================================="
  echo "   自动登陆ssh"
  echo "   HOST: $tmp_hst"
  echo "   USER: $tmp_usr"
  echo " =================================="
  #echo $tmp_cmd
  OLD_IFS="$IFS" 
  # 按字符串,切割数组
  IFS="," 
  local tmp=""
  tmp+=`tabnl 0`"#set force_conservative 0 ;"
	tmp+="\n"
  tmp+=`tabnl 0`"set timeout 10"
	tmp+=`tabnl 0`"spawn ssh $tmp_usr@$tmp_hst"
  tmp+=`tabnl 0`"expect yes/no { send yes\\\\r ; exp_continue }"
  tmp+=`tabnl 0`"expect \"*assword:\" { send $tmp_pwd\\\\r }"
  tmp+=`tabnl 0`"expect \"\\\\\\\\$\""
  # 获取超级用户权限
  tmp+=`tabnl 0`"send \"sudo echo SuperUser\\\\r\""
  tmp+=`tabnl 0`"expect \"*assword for $tmp_usr:\" { send $tmp_pwd\\\\r }"
	tmp+="\n"	
  local cmdlist=($tmp_cmd)
  for cmd in ${cmdlist[*]}
  do
    # 过滤空字串
    if [ " " != $(echo $cmd|tr -s " ") ]; then
      # 执行单个shell命令
	    tmp+=`tabnl 0`"expect \"\\\\\\\\$\""
	    tmp+=`tabnl 0`"send \"$cmd\\\\r\""
    fi
  done
	tmp+="\n"	
	tmp+=`tabnl 0`"send exit\\\\r"
	tmp+=`tabnl 0`"expect eof"
	tmp+="\n"	
  IFS="$OLD_IFS" 
  echo -e "$tmp" | expect
  return 0
}

get_linux_ver()
{
  echo `lsb_release -r -s`
  return 0
}

find_replace_line()
{
  local tmpfile=$1
  local tmpsrc=$2
  local tmpdst=$3
  local tmpsudo=$4
  if [ -f $tmpfile ]; then
    #echo "$tmpfile"
    #echo "{if (\$0 == \"${tmpsrc}\") printf \"${tmpdst}\n\"; else printf \$0\"\n\"}"
    if [ -z "$tmpsudo" ]; then 
      awk "{if (\$0 == \"${tmpsrc}\") printf \"${tmpdst}\n\"; else printf \$0\"\n\"}" $tmpfile 1<>$tmpfile
    else
      sudo chmod o+w $tmpfile
      awk "{if (\$0 == \"${tmpsrc}\") printf \"${tmpdst}\n\"; else printf \$0\"\n\"}" $tmpfile 1<>$tmpfile
      sudo chmod o-w $tmpfile
    fi
    #local temp=``
    #sudo sh -c "echo \"$temp\" > $tmpfile"
  fi
}

insert_at()
{
  local srcfile=$1
  local srctag=$2
  local dsttag=$3
  local mode=$4
  local sumode=$5
  local cmd=""
  if [ "$mode" == "b" ]; then
    cmd="sed -i '/$srctag/i\\$dsttag' $srcfile"
  else
    cmd="sed -i '/$srctag/a\\$dsttag' $srcfile"
  fi
  $sumode sh -c "$cmd"
}

replace_at()
{
  local srcfile=$1
  local srctag=$2
  local dsttag=$3
  local sumode=$4
  local cmd="sed -i 's/$srctag/$dsttag/g' $srcfile"
  $sumode sh -c "$cmd"
}

function detect_gnome()
{
  ps -e | grep -E '^.* gnome-session$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi
  TEMP_G_VERSION=`gnome-session --version | awk '{print $2}'`
  TEMP_G_DESKTOP="GNOME"
  return 1
}

function detect_kde()
{
  ps -e | grep -E '^.* kded4$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  else    
    TEMP_G_VERSION=`kded4 --version | grep -m 1 'KDE' | awk -F ':' '{print $2}' | awk '{print $1}'`
    TEMP_G_DESKTOP="KDE"
    return 1
  fi
}

function detect_unity()
{
  ps -e | grep -E '^.* unity-panel$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi
  TEMP_G_VERSION=`unity --version | awk '{print $2}'`
  TEMP_G_DESKTOP="UNITY"
  return 1
}

function detect_xfce()
{
  ps -e | grep -E '^.* xfce4-session$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi
  TEMP_G_VERSION=`xfce4-session --version | grep xfce4-session | awk '{print $2}'`
  TEMP_G_DESKTOP="XFCE"
  return 1
}

function detect_cinnamon()
{
  ps -e | grep -E '^.* cinnamon$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi
  TEMP_G_VERSION=`cinnamon --version | awk '{print $2}'`
  TEMP_G_DESKTOP="CINNAMON"
  return 1
}

function detect_mate()
{
  ps -e | grep -E '^.* mate-panel$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi
  TEMP_G_VERSION=`mate-about --version | awk '{print $4}'`
  TEMP_G_DESKTOP="MATE"
  return 1
}

function detect_lxde()
{
  ps -e | grep -E '^.* lxsession$' > /dev/null
  if [ $? -ne 0 ];
  then
    return 0
  fi

  # We can detect LXDE version only thru package manager
  which apt-cache > /dev/null 2> /dev/null
  if [ $? -ne 0 ];
  then
    which yum > /dev/null 2> /dev/null
  if [ $? -ne 0 ];
  then
    TEMP_G_VERSION='UNKNOWN'
  else
    # For Fedora
    TEMP_G_VERSION=`yum list lxde-common | grep lxde-common | awk '{print $2}' | awk -F '-' '{print $1}'`
  fi
  else    
    # For Lubuntu and Knoppix
    TEMP_G_VERSION=`apt-cache show lxde-common /| grep 'Version:' | awk '{print $2}' | awk -F '-' '{print $1}'`
  fi
  TEMP_G_DESKTOP="LXDE"
  return 1
}

function detect_sugar()
{
  if [ "$DESKTOP_SESSION" == "sugar" ];
  then
    TEMP_G_VERSION=`python -c "from jarabe import config; print config.version"`
    TEMP_G_DESKTOP="SUGAR"
  else
    return 0
  fi
}

function get_desktop()
{
  TEMP_G_DESKTOP="UNKNOWN"
  if detect_gnome;
  then
    if detect_kde;
    then
      if detect_unity;
      then
        if detect_xfce;
        then
	        if detect_cinnamon;
	        then
            if detect_mate;
            then
		          if detect_lxde;
		          then
		            detect_sugar
		          fi
            fi
	        fi
        fi
      fi
    fi
  fi
  if [ "$1" == "" -o "$1" == "n" -o "$1" == "name" ]; then
    echo $TEMP_G_DESKTOP
  elif [ "$1" == "v" -o "$1" == "ver" ]; then
    echo $TEMP_G_VERSION
  else
    echo $TEMP_G_DESKTOP $TEMP_G_VERSION
  fi
}

function is_desktop()
{
  local tmpflag=`get_desktop`
  if [ "$tmpflag" == "UNKNOWN" ]; then
    echo "0"
  else
    echo "1"
  fi
}

function is_server()
{
  local tmpflag=`get_desktop`
  if [ "$tmpflag" == "UNKNOWN" ]; then
    echo "1"
  else
    echo "0"
  fi
}

function find_dpkg()
{
  local tmp=`dpkg -l | awk '{ print $2 }' | grep "$1"`
  if [ "$tmp" == "$1" ]; then
    echo "1"
  else
    echo "0"
  fi
}

input_and_set_spwd()
{
  local title=$1
  local ifspwd=""
  local spwd=""
  local spwd=""
  read -p "  是否输入$title口令(y/N):" ifspwd
  if [ -z "$ifspwd" -o "$ifspwd" == "n" ]; then
    # 为空或为否
    echo "    跳过口令设置"
  else
    echo -n "  输入口令:"; read -s spwd
    if [ -z "$spwd" -o ${#spwd} -lt 8 ]; then
      echo ""
      echo "    未输入口令或口令长度小于8"
    else
      echo ""
      echo -n "  再次输入口令:"; read -s spwd2
      if [ "$spwd" == "$spwd2" ]; then
        echo ""
        echo "    设置口令成功!"
        set_secure_key "$spwd"
      else
        echo ""
        echo "    两次口令输入不一致,设置口令失败!"
      fi
    fi
  fi
}

input_and_set_site_spwd()
{
  local title=$1
  local site=$2
  local user=$3
  local other=$4
  local section="site_date"
  local ifspwd=""
  local spwd=""
  local spwd2=""
  local item="${site}_${user}"
  echo -n "  是否输入$other host=$site user=$user 的 $title 口令(y/N):"; read -s ifspwd; echo ""
  local ifspwdmd5=`echo -n "$ifspwd" | md5sum`
  if [ -z "$ifspwd" -o "$ifspwd" == "n" ]; then
    # 为空或为否
    echo "    跳过口令设置"
  else
    echo -n "  输入口令:"; read -s spwd 
    if [ -z "$spwd" -o ${#spwd} -lt 6 ]; then
      echo ""
      echo "    未输入口令或口令长度小于6"
    else
      echo ""
      echo -n "  再次输入口令:"; read -s spwd2
      if [ "$spwd" == "$spwd2" ]; then
        local status=""
        echo ""
        status=`set_sproj_ini "$item" "$spwd" "$section"`
        sleep 0.3
        status=`set_sproj_ini "$item" "$spwd" "$section"`
        sleep 0.3
        status=`set_sproj_ini "$item" "$spwd" "$section"` 
        local spwd3=`get_sproj_ini "$item" "$section"`
        if [ "$spwd" == "$spwd3" ]; then
          echo "    设置口令成功!"
        else
          echo "    写加密ini错误,设置口令失败!"
        fi
      else
        echo ""
        echo "    两次口令输入不一致,设置口令失败!"
      fi
    fi
  fi
}

is_number()
{
  v=`echo $1 | awk '{print($0~/^[-]?([0-9])+[.]?([0-9])+$/)?"number":"string"}'`
  #[ $v == "string" ] && return 0 || return 1
  [ "$v" == "number" ] && echo 1 || echo 0
}

show_number()
{
  [ $(is_number 12) -eq 1 ] && echo "number" || echo "no string"
  [ $(is_number www) -eq 1 ] && echo "number" || echo "no string"
}

set_jcfg_item()
{
  local jfile=$3
  [ -z "$jfile" ] && jfile=".jconfig"
  [ ! -f "$jfile" ] && echo "{}" > $jfile
  v=$(cat $jfile)
  [ "$v" == "\n" -o "$v" == " " -o "$v" == "" ] && echo "{}" > $jfile
  [ -z "$1" ] && return 1
  v=$(get_jcfg_item $1 $jfile)
  [ "$v" == "$2" ] && return 0
  if [ $(is_number $2) == "1" ]; then
    #echo "num"
    v=$(cat $jfile | jq $1=$2)
    [ "$v" != "" ] && echo $v > $jfile
  else
    #echo "str"
    v=$(cat $jfile | jq $1=\"$2\")
    [ "$v" != "" ] && echo $v > $jfile
  fi
}

get_jcfg_item()
{
  local jfile=$2
  [ -z "$jfile" ] && jfile=".jconfig"
  [ ! -f "$jfile" ] && echo "{}" > $jfile
  v=$(cat $jfile)
  [ "$v" == "\n" -o "$v" == " " -o "$v" == "" ] && echo "{}" > $jfile
  v=$(cat $jfile | jq $1)
  [ "$v" == "null" -o -z "$v" ] || {
     [ ${v: -1} == '"' -a ${v:0:1} == '"' ] && echo ${v:1:-1} || echo ${v}
  }
}
