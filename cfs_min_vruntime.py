#!/bin/env python
try:
    import json
except:
    import simplejson as json
import subprocess,os,shutil

def output(o,flag=0,info='None'):
    dict={"collection_flag":flag,"error_info":info,"MSG":o}
    print json.dumps(dict)

def increase_output_int(x,y):
    xx=float(x.strip())
    yy=float(y.strip())
    value=int(xx-yy)
    return value
    

old='/dev/shm/vruntime.old'
new='/dev/shm/vruntime.new'

try:
   fd=open(old)
   list_old=fd.readlines()
   fd.close()
   fdnew=open(new,'w',buffering=0)
   child=subprocess.Popen("grep min_vruntime /proc/sched_debug |awk '{print $NF}'",shell=True,stdout=fdnew)
   child.wait()
   fdnew.close()
   ff=open(new)
   list_new=ff.readlines()
   increase_value=0
   for i in list_old:
      if '-' in i:
         overflow_tag=0
         break
      else:
         overflow_tag=1
   if len(list_old) == len(list_new) and overflow_tag:
      for x in range(len(list_new)):
         result=increase_output_int(list_new[x],list_old[x])
         if result > 10**9:
            increase_value=result
            break
         else:
            if result > increase_value:
               increase_value=result
   else:
      increase_value=-1

except IOError:
   fd=open(old,'w')
   child=subprocess.Popen("grep min_vruntime /proc/sched_debug |awk '{print $NF}'",shell=True,stdout=fd)
   child.wait()
   increase_value=0
   fd.close()
except:
   increase_value=0.0
finally:
   if os.path.exists(new):
      length_old=len(open(old).readlines())
      length_new=len(open(new).readlines())
      if length_old == length_new:
         shutil.copyfile(new,old) 

dd=[{'min_vruntime_increase':increase_value}]
output(dd)

