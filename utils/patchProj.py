#!/usr/bin/python
#-*- coding:utf-8 -*-

import os
import time
from utils import *
import re

class patchProj:

    show=False
    write=False
    write_fix=False
    demo_mode=False
    host_patch_mode=False
    platform_patch_mode=False
    proj_cwd=os.getcwd()
    current_dir=""

    def __init__(self,sourcecode_dir,proj_name,proj_root="x86"):
        self.proj_name = proj_name
        self.sourcecode_dir=sourcecode_dir
        #self.has_platform = not (proj_root == "")
        self.proj_root = "projs_"+proj_root
        self.platform = proj_root
        self.platform_root = "platforms/"+proj_root
        self.valid_proj()

    def enable_write_source(self,enabled):
        self.write=enabled

    def enable_write_fix(self,enabled):
        self.write_fix=enabled

    def enable_demo_mode(self,enabled):
        self.demo_mode=enabled

    def enable_host_mode(self,enabled):
        self.host_patch_mode=enabled

    def enable_platform_mode(self,enabled):
        self.platform_patch_mode=enabled

    def set_current_dir(self,path):
        self.current_dir=path

    def get_current_dir(self,subpath="",fix="/files"):
        if isEmpty(subpath):
            return self.current_dir+fix+"/"
        else:
            return self.current_dir+fix+"/"+subpath
            
    def get_root(self,mode):
        if mode == "old":
          return self.proj_root
        elif mode == "new":
          return self.platform_root
        else: return "projs"

    def get_projs_path_demo(self,mode=""):
        return self.proj_cwd+"/"+self.get_root(mode)+"/demo"

    def get_projs_path_apps(self,mode=""):
        return self.proj_cwd+"/"+self.get_root(mode)+"/apps"

    def get_projs_path_base(self,mode=""):
        return self.proj_cwd+"/"+self.get_root(mode)+"/base"

    def get_projs_path_common(self,mode=""):
        return self.proj_cwd+"/"+self.get_root(mode)+"/common"

    def get_projs_path_projname(self,sub="",mode=""):
        projpath=""
        if (isEmpty(sub)):
            projpath=self.proj_cwd+"/"+self.get_root(mode)+"/proj_"+self.proj_name
        else:
            projpath=self.proj_cwd+"/"+self.get_root(mode)+"/proj_"+self.proj_name+"/"+sub
        if os.path.exists(projpath):
            return projpath
        else: return ""

    def get_host_path(self,platform="base-file"):
        return self.proj_cwd+"/platforms/host/"+platform

    def valid_proj(self):
        if isEmpty(self.proj_name):
            self.proj_path=""
            return False
        return not (isEmpty(self.get_projs_path_projname()))

    def get_proj_demo(self,mode="",ext=[".yaml"]):
        return get_filelist(self.get_projs_path_demo(mode),ext)

    def get_proj_apps(self,mode="",ext=[".yaml"]):
        return get_filelist(self.get_projs_path_apps(mode),ext)

    def get_proj_base(self,mode="",ext=[".yaml"]):
        return get_filelist(self.get_projs_path_base(mode),ext)

    def get_proj_common(self,mode="",ext=[".yaml"]):
        return get_filelist(self.get_projs_path_common(mode),ext)

    def get_proj_main(self,sub="",mode="",ext=[".yaml"]):
        return get_filelist(self.get_projs_path_projname(sub,mode),ext)

    def get_host_patchs(self,ext=[".yaml"]):
        #print self.get_host_path()
        return get_filelist(self.get_host_path(),ext)

    def get_platform_patchs(self):
        patchs=[]
        tmppath=self.proj_cwd+"/platforms/host/"+self.platform+"/base.yaml"
        if os.path.isfile(tmppath): patchs += [ tmppath ]
        tmppath=self.proj_cwd+"/platforms/host/"+self.platform+"/proj_"+self.proj_name+".yaml"
        if os.path.isfile(tmppath): patchs += [ tmppath ]
        return patchs

    def get_yaml_patchobj(self,filepath):
        if os.path.exists(filepath):
            ystr=readfile(filepath)
            return yaml2obj(ystr)
        return None

    def get_source_code_dir(self,base="",fix=""):
        root_dir=self.sourcecode_dir
        if not isEmpty(fix):
            if fix[0]=="/" or root_dir[-1]=="/": root_dir+=fix
            else: root_dir+="/"+fix
        if isEmpty(base): pass
        elif base[0]=="/" or root_dir[-1]=="/": root_dir += base
        else: root_dir += "/"+base
        return root_dir

    def patch_yaml(self):

        if self.host_patch_mode:
            patchs=self.get_host_patchs()
            if (len(patchs)>0):
                self.set_current_dir(self.get_host_path())
                print_line(" -3 , host ",char="*")
                print "应用主机补丁(platforms/host/base-file)",len(patchs),"个"
                self.patch_yaml_from_dir(patchs)
            return

        if self.platform_patch_mode:
            patchs=self.get_platform_patchs()
            if (len(patchs)>0):
                self.set_current_dir(self.get_host_path(self.platform))
                print_line(" -3 , platform ",char="*")
                print "目标平台补丁(platforms/host/"+self.platform+")",len(patchs),"个"
                self.patch_yaml_from_dir(patchs)
            return

        if self.demo_mode:
            patchs=self.get_proj_demo("orig")
            if (len(patchs)>0):
                self.set_current_dir(self.get_projs_path_demo("orig"))
                print_line(" -3 , demo ",char="*")
                print "应用标准补丁",len(patchs),"个"
                self.patch_yaml_from_dir(patchs)
            return

        patchs=self.get_proj_base("orig")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_base("orig")) #"old"
            print_line(" -3 , base ",char="*")
            print "应用标准补丁(projs/base)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_common("orig")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_common("orig"))
            print_line(" -3 , common ",char="*")
            print "应用共享补丁(projs/common)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_apps("orig")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_apps("orig"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用APP补丁/(projs/apps)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_base("old")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_base("old"))
            print_line(" -3 , base ",char="*")
            print "应用标准补丁(projs_"+self.platform+"/base)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_common("old")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_common("old"))
            print_line(" -3 , common ",char="*")
            print "应用共享补丁(projs_"+self.platform+"/common)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_apps("old")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_apps("old"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用APP补丁(projs_"+self.platform+"/apps)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_main("","old")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_projname("","old"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用项目补丁(projs_"+self.platform+"/proj_"+self.proj_name+")",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_base("new")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_base("new"))
            print_line(" -3 , base ",char="*")
            print "应用标准补丁(platforms/"+self.platform+"/base)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_common("new")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_common("new"))
            print_line(" -3 , common ",char="*")
            print "应用共享补丁(platforms/"+self.platform+"/common)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_apps("new")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_apps("new"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用APP补丁(platforms/"+self.platform+"/apps)",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_main("","new")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_projname("","new"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用项目补丁(platforms/"+self.platform+"/proj_"+self.proj_name+")",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        patchs=self.get_proj_main("","orig")
        if (len(patchs)>0):
            self.set_current_dir(self.get_projs_path_projname("","orig"))
            print_line(" -3 , proj_%s "%self.proj_name,char="*")
            print "应用项目补丁(projs/proj_"+self.proj_name+")",len(patchs),"个"
            self.patch_yaml_from_dir(patchs)

        self.set_current_dir("")


    def patch_yaml_from_dir(self,paths=[]):
        i=0
        for p in paths:
            i+=1
            fname = os.path.basename(p)
            if fname[0]=="#":
                print_line("-5, 忽略补丁 %03d : %s "%(i,fname),char="#")
                continue
            objs=self.get_yaml_patchobj(p)
            if (objs!=None):
                if ("patchs" in objs):
                    if ("used" in objs["patchs"]):
                      chk_used = objs["patchs"]["used"]
                      if isinstance(chk_used,bool): chk_used = "yes" if chk_used else "no"
                      elif isinstance(chk_used, str): chk_used = chk_used.lower()
                      if chk_used == "n" or chk_used == "no" or chk_used == "false":
                          print_line("-5, 忽略补丁 %03d : %s "%(i,fname),char="#")
                          continue
                    if ("platform" in objs["patchs"]):
                      chk_platform = objs["patchs"]["platform"]
                      if isinstance(chk_platform,list): pass
                      elif isinstance(chk_platform, str): chk_platform = [ chk_platform.lower() ]
                      if not (self.platform in chk_platform):
                          print_line("-5, 忽略补丁(平台) %03d : %s "%(i,fname),char="#")
                          continue
                    if ("projs" in objs["patchs"]):
                      chk_projs = objs["patchs"]["projs"]
                      if isinstance(chk_projs,list): pass
                      elif isinstance(chk_projs, str): chk_projs = [ chk_projs.lower() ]
                      if not (self.proj_name in chk_projs):
                          print_line("-5, 忽略补丁(项目) %03d : %s "%(i,fname),char="#")
                          continue
                elif ("patch" in objs) and ("used" in objs["patch"]):
                    chk_used = objs["patch"]["used"]
                    if isinstance(chk_used,bool): chk_used = "yes" if chk_used else "no"
                    elif isinstance(chk_used, str): chk_used = chk_used.lower()
                    if chk_used == "n" or chk_used == "no" or chk_used == "false":
                        print_line("-5, 忽略补丁 %03d : %s "%(i,fname),char="#")
                        continue
                    if ("platform" in objs["patch"]):
                      chk_platform = objs["patch"]["platform"]
                      if isinstance(chk_platform,list): pass
                      elif isinstance(chk_platform, str): chk_platform = [ chk_platform.lower() ]
                      if not (self.platform in chk_platform):
                          print_line("-5, 忽略补丁(平台) %03d : %s "%(i,fname),char="#")
                          continue
                    if ("projs" in objs["patch"]):
                      chk_projs = objs["patch"]["projs"]
                      if isinstance(chk_projs,list): pass
                      elif isinstance(chk_projs, str): chk_projs = [ chk_projs.lower() ]
                      if not (self.proj_name in chk_projs):
                          print_line("-5, 忽略补丁(项目) %03d : %s "%(i,fname),char="#")
                          continue
                print_line(" -5 , 应用补丁 %03d : %s "%(i,fname),char="#")
                #print(patch_obj)
                if ("patchs" in objs):
                  if ("items" in objs["patchs"]):
                    patch_objs = objs["patchs"]["items"]
                  else:
                    patch_objs = objs["patchs"]
                elif ("patch" in objs):
                    patch_objs = [ objs ]
                else: patch_objs = []
                for patch_obj in patch_objs:
                  if ("patch" in patch_obj) and "path" in (patch_obj["patch"]):
                    self.apply_patch_yaml(patch_obj["patch"])

    def apply_patch_yaml(self,yamlobj):
        if "path" in yamlobj:
            path=self.sourcecode_dir+yamlobj["path"]
            if os.path.exists(path):
                content=""
                isWrite=os.path.isfile(path)
                if isWrite:
                    content=readfile(path)
                i=0
                print "apply patch file:",yamlobj["path"], ("[file]" if isWrite else "[dir]"),
                if ("used" in yamlobj):
                    chk_used = yamlobj["used"]
                    if isinstance(chk_used,bool): chk_used = "yes" if chk_used else "no"
                    elif isinstance(chk_used, str): chk_used = chk_used.lower()
                    if chk_used == "n" or chk_used == "no" or chk_used == "false":
                        print ": config set not used."
                        return
                    else: print ""
                else: print ""
                for item in yamlobj["items"]:
                    hash_before=hash_after=""
                    if ("name" in item):print " "+item["name"].encode("utf8")
                    print "  apply patch item [",i,"]:",
                    if isWrite:hash_before=md5(content)
                    content=self.apply_patch_yaml_item(content,item)
                    if isWrite:hash_after=md5(content)
                    if (isinstance(content,bool)):
                        print "yes" if content else "no"
                    else:
                        if len(hash_before)>0 and hash_before == hash_after:
                            print "skip"
                        else: print "apply"
                        i+=1
                        if self.show:
                            print "orig:"
                            print item["orig"]
                            print "fix:"
                            print item["fix"]
                if self.show:
                    print content
                if isWrite and self.write_fix:
                    writefile(path+".fix",content)
                if isWrite and self.write:
                    writefile(path,content)
                if self.write and os.path.exists(path+".fix"):
                    os.remove(path+".fix")
            else:
                print "not patch file:",path

    def apply_patch_yaml_item(self,content,patch):
        item=patch
        mode=""
        _org=""
        hash_before=hash_after=""
        debug=False
        showsource=False
        result=True

        if "mode" in item:
            modes=item["mode"].split(",")
            for m in modes:
                m=m.strip().lower()
                if m[0] == "#":
                    continue
                elif m=="debug":
                    debug=True
                elif m=="source":
                    showsource=True
                else:
                    mode=m

        if "used" in item:
            if isinstance(item["used"],bool) and item["used"] == False :
                mode="skip"
            elif isinstance(item["used"],str) and item["used"] != "yes" :
                mode="skip"

        if showsource:
            _org=content
        if debug:
            hash_before=md5(content)

        if "fix" in patch and "defs" in patch:
            defs = []
            if not isinstance(patch["defs"],list) and isinstance(patch["defs"],dict):
                defs = [patch["defs"]]
            else: defs = patch["defs"]
            if len(defs) > 0:
                #print "1",
                for fixdef in defs:
                    if "id" in fixdef and "src" in fixdef:
                        src_id="{"+fixdef["id"]+"}"
                        fn=self.get_current_dir(fixdef["src"])
                        #print src_id,fn,
                        if os.path.exists(fn):
                            #print fn,
                            fp=open(fn,'r')
                            src_str=fp.read()
                            fp.close()
                            patch["fix"] = patch["fix"].replace(src_id,src_str)

        if isEmpty(mode) or mode == "std" or mode == "std+":
            if "orig" in patch:
                if isinstance(patch["orig"],list):
                    tmp_hash=md5(content)
                    for orig in patch["orig"]:
                        _content = content.replace(orig,patch["fix"])
                        if md5(_content) != tmp_hash:
                            content = _content
                            if not mode=="std+":break
                else:
                    content = content.replace(patch["orig"],patch["fix"])
            else:
                print "no orig(std)",
        elif mode=="regex" or mode=="regex+":
            if "orig" in patch:
                if isinstance(patch["orig"],list):
                    tmp_hash=md5(content)
                    for orig in patch["orig"]:
                        _content = re.sub(orig, patch["fix"], content)
                        if md5(_content) != tmp_hash:
                            content = _content
                            if not mode=="regex+":break
                else:
                    content = re.sub(patch["orig"], patch["fix"], content)
            else:
                print "no orig(regex)",
        elif mode=="add" or mode=="add+":
            if content.find(patch["fix"]) < 0:
                if "orig" in patch and len(patch["orig"])>=0:
                    if isinstance(patch["orig"],list):
                        tmp_hash=md5(content)
                        for orig in patch["orig"]:
                            at=content.find(orig)
                            #print patch["orig"],at
                            if at>=0:
                                at+=len(orig)
                                #if content[at-1] == "\n": content=content[0:at]+patch["fix"]+content[at:]
                                #else: content=content[0:at]+"\n"+patch["fix"]+content[at:]
                                content=content[0:at]+patch["fix"]+content[at:]
                            if md5(content) != tmp_hash:
                                if not mode=="add+":break
                    else:
                        at=content.find(patch["orig"])
                        #print patch["orig"],at
                        if at>=0:
                            at+=len(patch["orig"])
                            #if content[at-1] == "\n": content=content[0:at]+patch["fix"]+content[at:]
                            #else: content=content[0:at]+"\n"+patch["fix"]+content[at:]
                            content=content[0:at]+patch["fix"]+content[at:]
                else:
                    if len(content)>0 and content[-1]=="\n":
                        content = content+patch["fix"]
                    else:content = content+"\n"+patch["fix"]
            else:
                print "no orig(add)",
        elif mode=="skip":
            print "src_skip",
            pass #return content
        elif mode=="config":
            if "cfgs" in patch:
                cfgs=[]
                if debug: print ""
                if not isinstance(patch["cfgs"],list):
                    cfgs=[patch["cfgs"]]
                else: cfgs=patch["cfgs"]
                for item in cfgs:
                    content=self.config_file_from_yaml(content,item,debug)
        elif mode=="copy":
            rootbase=""
            if ("base" in item):rootbase=item["base"]
            src_root = self.get_current_dir()
            #print src_root,
            if os.path.exists(src_root):
                if ("orig" in item):
                    #(os.path.exists(rootbase))
                    if isinstance(item["orig"],list):
                        items=item["orig"]
                    else: items=[item["orig"]]
                    if debug: print ""
                    for citem in items:
                        srcf=dstf=""
                        chmod=0
                        if isinstance(citem,dict):
                            srcf = citem["src"].strip()
                            if "dst" in citem: dstf = citem["dst"].strip()
                            else: dstf=srcf
                            if "chmod" in citem: chmod=citem["chmod"]
                        else:
                            srcf = citem.strip()
                            dstf=srcf
                        srcp=self.get_current_dir(srcf)
                        dstp=self.get_source_code_dir(dstf,rootbase)
                        if debug:
                            print "src",srcp
                            print "dst",dstp

                        if not copy_ex(srcp,dstp,debug=debug):result=False
                        if chmod > 0:
                            #print chmod
                            os.chmod(dstp,chmod)
                else: print "no orig",
            else: print "no files path",
        elif mode=="del":
            rootbase=""
            if ("base" in item):rootbase=item["base"]
            if ("orig" in item):
                if isinstance(item["orig"],list):
                    items=item["orig"]
                else: items=[item["orig"]]
                if debug:print ""
                for citem in items:
                    delf=None
                    delp=None
                    if isinstance(citem,dict):
                        if "item" in citem:
                            delf = citem["item"].strip()
                            delp=self.get_source_code_dir(delf,rootbase)
                    else:
                        delf = citem.strip()
                        delp=self.get_source_code_dir(delf,rootbase)
                    if debug:
                        print "del",self.get_source_code_dir(delf,rootbase)
                    if not del_path_ex(delp,debug=debug): result=False
            else: print "no orig(del)",
        if not (mode in ["copy","del"]):
            if debug: hash_after=md5(content)
            if debug:
                print "\norig:",hash_before
                if "orig" in item: print item["orig"]
            if showsource:
                print("")
                print_line("-2, SRC ","=")
                print _org
            if debug:
                print "fix:",hash_after
                if "fix" in item: print item["fix"]
            if showsource:
                print("")
                print_line("-2, FIX ","+")
                print content
            return content
        else: return result

    def config_line_create(self,id,mode):
        if mode=="y" or mode=="" or mode==None:
            return "%s=y"%id
        elif mode=="m":
            return "%s=m"%id
        elif mode=="n":
            return "# %s is not set"%id
        else:
            return "%s=%s"%(id,mode)

    def config_line_get(self,id):
        return [ self.config_line_create(id,"n"),self.config_line_create(id,"y"),self.config_line_create(id,"m") ]

    def chk_config_id(self,src,id):
        regs="(%s=.*|#\s%s\sis\snot\sset)"%(id,id)
        m = re.search(regs,src)
        if m:
            return m.group()
        return None

    def config_id_split(self,line):
        at=line.find("=")
        mod="y"
        if at >=0:
            id=line[0:at].strip()
            mod=line[at+1:].strip()
            if mod=="Y" or mod=="M" or mod=="N": mod=mod.lower()
        else:
            id=line.strip()
        return { "id":id, "mod":mod }

    def config_id_process(self,src,line,insert="",debug=False):
        item=self.config_id_split(line)
        id=item["id"]
        mod=item["mod"]
        return self.config_id_subprocess(src,id,mod,insert,debug)

    def config_id_subprocess(self,src,id,mod,insert="",debug=False):
        ins=self.config_id_split(insert)
        insid=ins["id"]
        cfg = self.chk_config_id(src,id)
        newcfg=self.config_line_create(id,mod)
        if isinstance(cfg,str):
            src=src.replace(cfg,newcfg)
            if debug: print "    replace",cfg,"|",newcfg
        else:
            if insert!="":
                cfg = self.chk_config_id(src,insid)
                if isinstance(cfg,str):
                    src=src.replace(cfg,"%s\n%s"%(cfg,newcfg))
                    if debug: print "    replace i",cfg,"|",newcfg
                else:
                    src += "\n%s"%newcfg
                    if debug: print "    add i new line |",newcfg
            else:
                src += "\n%s"%newcfg
                if debug: print "    add new line |",newcfg
        return src

    def config_file_from_yaml(self,src,item,debug=False):
        insert=""
        if isinstance(item,str):
            src=self.config_id_process(src,item,insert,debug)
        elif isinstance(item,dict):
            if "id" in item and "val" in item:
                if "insert" in item: insert = item["insert"]
                src = self.config_id_subprocess(src,item["id"],item["val"],insert,debug)
            if "item" in item:
                if "insert" in item: insert = item["insert"]
                src = self.config_id_process(src,item["item"],insert,debug)
            elif "i" in item or "y" in item or "m" in item or "n" in item or "c" in item:
                if "i" in item: insert = item["i"]
                if "y" in item:
                    items=[]
                    if isinstance(item["y"],str): items=[item["y"]]
                    elif isinstance(item["y"],list): items=item["y"]
                    for it in items[::-1]:
                        src = self.config_id_subprocess(src,it,"y",insert,debug)
                if "m" in item:
                    items=[]
                    if isinstance(item["m"],str): items=[item["m"]]
                    elif isinstance(item["m"],list): items=item["m"]
                    for it in items[::-1]:
                        src = self.config_id_subprocess(src,it,"m",insert,debug)
                if "n" in item:
                    items=[]
                    if isinstance(item["n"],str): items=[item["n"]]
                    elif isinstance(item["n"],list): items=item["n"]
                    for it in items[::-1]:
                        src = self.config_id_subprocess(src,it,"n",insert,debug)
                if "c" in item:
                    items=[]
                    if isinstance(item["c"],str): items=[item["c"]]
                    elif isinstance(item["c"],list): items=item["c"]
                    for it in items[::-1]:
                        src = self.config_id_process(src,it,insert,debug)
        return src
