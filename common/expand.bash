#!/bin/bash

function lang()
{
  [ -f "$op_root/.zh_cn" -a ! -z "$2" ] && echo "$2" || echo "$1"
}

function get_wrtoy_path()
{
  if [ -z "$1" ]; then
    echo $(pwd)
  elif [ "$1" == ".." ]; then
    echo $(dirname $(pwd))
  else
    local p=$(pwd)
    if [ -d $(pwd)/$1 ]; then
      cd $(pwd)/$1
      local np=$(pwd)
      cd $p
      echo "$np"
    else
      echo "$p"
    fi
  fi
}

function get_profile_path()
{
  local ppath
  if [ -z "$hard_profile" -o "$hard_profile" == ".hardware" ]; then
    [ -e $op_root/.hardware ] && ppath=$op_root/.hardware || $op_hp_dir/default.json
    op_hp_def=default
  else
    ppath=$op_hp_dir/$hard_profile.json
    op_hp_def=""
  fi
  echo $ppath
}