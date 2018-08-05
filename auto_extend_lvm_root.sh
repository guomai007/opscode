#!/bin/sh
freespace_line=`parted /dev/sda print free|grep 'Free Space'|tail -n1`
if echo $freespace_line|grep GB >/dev/null ;then
   start_size=`echo $freespace_line|awk '{print $1}'`
   end_size=`echo $freespace_line|awk '{print $2}'`
else
   exit 1
fi

echo $start_size,$end_size
parted /dev/sda mkpart primary $start_size $end_size                                                                                 
partprobe                                                                                                                            
pvcreate /dev/sda4                                                                                                                   
vgextend cl /dev/sda4                                                                                                                
aa=`vgdisplay |grep 'Free  PE / Size'|awk '{print $(NF-1),$NF}'`
add_size=`echo $aa | sed 's/\([0-9]*\)\.[0-9]* \([MGTP]\)i\(B\)/\1\2\3/g'`
lvextend -L $add_size /dev/cl/root                                                                                                   
resize2fs  /dev/cl/root         
echo "resize /dev/cl/root ADD $add_size Success..."
