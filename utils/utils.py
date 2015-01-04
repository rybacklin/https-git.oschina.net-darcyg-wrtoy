#!/usr/bin/python
#-*- coding:utf-8 -*-

import os
import sys
import time
#import redisco
import json
import hashlib
import yaml
import shutil
from glob import glob

def md5(str):
    return hashlib.md5(str).hexdigest()

def list_all_file_from_dir(rootDir):
    paths = []
    for list in sorted(os.listdir(rootDir)):
        path = os.path.join(rootDir, list)
        if os.path.isdir(path):
            paths += list_all_file_from_dir(path)
        else:
            paths += [path]
    return paths

def delay():
    time.sleep(0.3)

def echo(msg,x=-1,y=-1):
    pos_s=''
    pos_e=''
    if x>=0 or y>=0:
        pos_s="\x1b7\x1b[%d;%df" % (x,y)
        pos_e="\x1b8"
    print pos_s, msg, pos_e

def obj2json(obj):
    return json.dumps(obj)

def json2obj(str):
    return json.loads(str,"utf8")

def o2j(obj):
    return json.dumps(obj)

def j2o(str):
    return json.loads(str,"utf8")

def fscan_lines(filepath):
    def fscan_blocks(files, size=65536):
        while True:
            b = files.read(size)
            if not b: break
            yield b
    with open(filepath, "r") as f:
        print sum(bl.count("\n") for bl in fscan_blocks(f))

def file_lines(filepath):
    count = -1
    for count, line in enumerate(open(filepath, 'rU')):
        pass
    return count+1

def file2json(file,sum_all=None):
    if os.path.exists(file):
        data={"filepath":file,"lines":file_lines(file)}
        if sum_all != None:
            sum_all["fnum"] += 1
            sum_all["lnum"] += data["lines"]
        return obj2json(data)
    return ""

def file2json_ex(file,sum_all=None,srcpath="",fixpath=""):
    if os.path.exists(file):
        data={"filepath":file,"lines":file_lines(file)}
        if srcpath != fixpath:
            newpath=file.replace(srcpath,fixpath)
            data["fixfilepath"]=newpath
        if sum_all != None:
            sum_all["fnum"] += 1
            sum_all["lnum"] += data["lines"]
        return obj2json(data)
    return ""

def readfile(file):
    s=""
    if os.path.exists(file):
        with open(file, "r") as f:
            s=f.read()
        f.close()
    return s

def writefile(file,s):
    with open(file, "w") as f:
        f.write(s)
    f.close()

def isEmpty(str):
    return len(str)==0

def screen_clear():
    os.system('clear')

def read_input(title,vals,defval):
    if vals:
        print title%(vals),
    else:
        print title,
    line = sys.stdin.readline().strip()
    if len(line)==0:
        return defval
    else:
        return line

def time2stamp(timestr, format_type='%Y-%m-%d %H:%M:%S'):
    return time.mktime(time.strptime(timestr, format_type))

def stamp2time(stamp, format_type='%Y-%m-%d %H:%M:%S'):
    return time.strftime(format_type, time.localtime(stamp))

def t2s(timestr, format_type='%Y-%m-%d %H:%M:%S'):
    return time.mktime(time.strptime(timestr, format_type))

def s2t(stamp, format_type='%Y-%m-%d %H:%M:%S'):
    return time.strftime(format_type, time.localtime(stamp))

def s2te(stamp, format_type='%Y:%m-%d:%H-%M-%S'):
    return s2t(stamp, format_type)

def yaml2obj(ystr):
    return yaml.load(ystr)

def obj2yaml(obj):
    return yaml.dump(obj)

# 判断是否为数字
def isNum(value):
    try:
        value + 1
    except TypeError:
        return False
    else:
        return True

# 判断是否为数字
def isInt(value):
    try:
        x = int(value)
    except TypeError:
        return False
    except ValueError:
        return False
    except Exception, e:
        return False
    else:
        return True

def print_line(mode="",char="=",length=80):
    if isEmpty(mode.strip()):
        print(char*length)
    else:
        #mode=mode.strip()
        ms=mode.split(',')
        dotrim=True
        f=5
        t=""
        for m in ms:
            if isInt(m):
                f=int(m)
                if f<0:dotrim=False
                f=abs(f)
            else:
                if dotrim: t=m.strip()
                else: t=m
        tl=len(t)
        str=(char*f)+t+(char*(length-tl-f))
        print(str)

def get_filelist(dir,ext=[]):
    lists=[]
    if os.path.exists(dir):
      list = os.listdir(dir)
      for line in list:
          filepath = os.path.join(dir,line)
          if os.path.isfile(filepath):
              base=os.path.splitext(filepath)
              if (len(ext)>0):
                  for e in ext:
                      if base[1].lower() == e.lower():
                          lists += [filepath]
              else:
                  lists += [filepath]
    return sorted(lists) 

def del_path_ex(path,debug=False):
    if path==None:return False
    if os.path.exists(path):
        if debug: print 'del:',path
        if os.path.isfile(path) or os.path.islink(path):
            #pass
            os.remove(path)
        elif os.path.isdir(path):
            #pass
            shutil.rmtree(path)
    else:
        files=sorted(glob(path))
        for f in files:
            if debug: print 'del:',f
            if os.path.isfile(f) or os.path.islink(f):
                #pass
                os.remove(f)
            elif os.path.isdir(f):
                #pass
                shutil.rmtree(f)
    return True

def copy_ex(src,dst,debug=False):
    if src==None or dst==None: return False
    if os.path.exists(src):
        if debug: print 'copy:',src
        if os.path.isfile(src) or os.path.islink(src):
            dstp,dstf=os.path.split(dst)
            if not os.path.exists(dstp): os.makedirs(dstp,0755)
            shutil.copyfile(src,dst)
        elif os.path.isdir(src):
            if not os.path.exists(dst): os.makedirs(dst,0755)
            shutil.copytree(src,dst)
        return True
    else:
        pass
        #files=sorted(glob(src))
        #for f in files:
        #    if debug: print 'copy:',f
        #    if os.path.isfile(f) or os.path.islink(f):
        #        pass #os.remove(f)
        #    elif os.path.isdir(f):
        #        pass#shutil.rmtree(f)
    return False
