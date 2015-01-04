#!/usr/bin/python
#-*- coding:utf-8 -*-

from utils.utils import *
from argtools import command, argument
from utils.patchProj import *

@command.add_sub(name='test')
@argument('-c', '--clear', action='store_true', default=False, help='清空')
@argument('-s', '--source-dir', default='/', help='来源目录')
@argument('-d', '--dest-dir', default='/', help='目的目录')
@argument('-n', '--num', type=int, default=0, help='数量')
@argument('-S', '--show-msg', action='store_true', default=False, help='显示')
def test(args):
    """ 测试项目

    """
    y=readfile("projs/base/001-open-wireless.yaml")
    print yaml2obj(y)

@command.add_sub(name='proj')
@argument('projectname', default='', help='项目名称')
@argument('-s', '--sourcecode-dir', default='/works/openwrt/openwrt', help='源码目录')
#@argument('-p', '--project-name', default='', help='项目名称')
@argument('-t', '--project-type', default='x86', help='项目组根')
@argument('-w', '--enable-write', action='store_true', default=False, help='复写源文件')
@argument('-f', '--enable-write-fix', action='store_true', default=False, help='写fix文件')
@argument('-d', '--enable-demo', action='store_true', default=False, help='Demo模式')
def proj(args):
    """ 项目

    """
    if not args.project_type in ["x86","ramips","rpi"]:
        print "错误的平台编号"
        return
    proj = patchProj(args.sourcecode_dir,args.projectname,args.project_type)
    #print args.projectname
    #print args.project_type
    if isEmpty(args.projectname) or not proj.valid_proj():
        print "不存在的项目"
        return
    proj.enable_write_source(args.enable_write)
    proj.enable_write_fix(args.enable_write_fix)
    proj.enable_demo_mode(args.enable_demo)
    proj.patch_yaml()


if __name__ == "__main__":
    screen_clear()
    command.run()
    #t=1399466769
