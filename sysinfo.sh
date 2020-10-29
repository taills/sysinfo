#!/bin/bash
#########################################################
# Function :sysinfo for Linux                           #
# Platform :CentOS 7                                    #
# Version  :1.0                                         #
# Date     :2020-10-30                                  #
# Author   :taills                                      #
# Contact  :taills@qq.com                               #
# Github   :https://github.com/taills/sysinfo           #
#########################################################
if [ -n "$1" ] ; then
    if [ `id -u` -ne 0 ];then
        echo "请使用 root 用户执行该脚本进行安装/卸载操作"
        exit 1
    fi
    if [ "$1" = "install" ] ;then
        if [ "$0" = "/usr/local/bin/sysinfo" ] ;then
            echo "骚年，已经安装过了! /usr/local/bin/sysinfo 已存在，可直接使用。"
            exit 0
        fi
        /usr/bin/cp $0 /usr/local/bin/sysinfo
        chmod +x /usr/local/bin/sysinfo
        echo /usr/local/bin/sysinfo >>/etc/profile
        exit 0
    fi
    if [ "$1" = "uninstall" ] ;then
        rm -f /usr/local/bin/sysinfo
        sed -i '/^\/usr\/local\/bin\/sysinfo/d' /etc/profile
        exit 0
    fi
    printf "\n脚本用法:\n\t安装\tsh %s install\n\t卸载\tsh %s uninstall\n\t卸载\tsysinfo uninstall\n\n执行安装操作会把脚本自身复制到 /usr/local/bin/sysinfo ,并添加到 /etc/profile 中\n每次登录即可执行该脚本，也可以执行 sysinfo 命令\n" $0 $0
    exit 1
fi

# 对齐格式
format2c=" %-20s%-20s\n"
format3c=" %-20s%-20s%-20s\n"

line1="------------------------------------------------------------------------"
line2="========================================================================"

NOW=`date  "+%F %T"`
ME=`whoami`
# 表头 + 分割线
printf "\nHello ${ME},\n\nThe system information of Host [${HOSTNAME}] at ${NOW} is:\n\n${line2}\n${format2c}${line1}\n" " Name" "Value"
# 内核

printf "$format2c" "Kernel Version" $(uname -r)


# CPU
cat /proc/cpuinfo  |grep 'model name' |sort -u |awk -v F="$format2c" -F ': ' '{printf F,"CPU",$2}'
# processor count
PROCESSOR_COUNT=$(cat /proc/cpuinfo  |grep processor |wc -l)
printf "$format2c" "Processors" "$PROCESSOR_COUNT"


#Cpu load
load1=`cat  /proc/loadavg  |  awk  '{print $1}' `
load5=`cat  /proc/loadavg  |  awk  '{print $2}' `
load15=`cat  /proc/loadavg  |  awk  '{print $3}' `

printf  "$format2c" "System Load" "$load1, $load5, $load15"

#System uptime
uptime=`cat  /proc/uptime  |  cut  -f1 -d.`
upDays=$((uptime /60/60/24 ))
upHours=$((uptime /60/60 %24))
upMins=$((uptime /60 %60))
upSecs=$((uptime%60))
up_lastime=`date  -d  "$(awk -F. '{print $1}' /proc/uptime) second ago"  +"%Y-%m-%d %H:%M:%S" `
  
#Memory Usage
mem_usage=`free  -m |  awk  '/Mem:/{total=$2} /buffers\/cache/ {used=$3} END {printf("%3.2f%%",used/total*100)}' `
swap_usage=`free  -m |  awk  '/Swap/{printf "%.2f%",$3/$2*100}' `

printf "$format2c" "Memory Usage" "$mem_usage"   
printf "$format2c" "Swap Usage" "$swap_usage"
 

# Uptime
printf  "$format2c" "System Uptime" "$upDays days $upHours hours $upMins min $upSecs sec"

#User
users=`users  |  wc  -w`
printf  "$format2c" "Login Users" $users 

#Processes
processes=`ps  aux |  wc  -l`
printf  "$format2c" "Processes"   $processes


if [ -f /usr/bin/nvidia-smi ]; then
    # Nvidia GPU
    /usr/bin/nvidia-smi  -q|grep 'Product Name' | awk -v F="$format2c" -F ': ' '{printf F,"GPU Product Name",$2}'
    # Nvidia Driver
    /usr/bin/nvidia-smi  -q|grep 'Driver Version' | awk -v F="$format2c" -F ': ' '{printf F,"Driver Version",$2}'
    # CUDA Version
    /usr/bin/nvidia-smi  -q|grep 'CUDA Version' | awk -v F="$format2c" -F ': ' '{printf F,"CUDA Version",$2}'
fi


# cuDNN
CUDNN_LIB_PATH=/usr/lib64/libcudnn.so
if [ -f "$CUDNN_LIB_PATH" ]; then
    readlink -f $CUDNN_LIB_PATH | awk -F 'libcudnn.so.' -v F="$format2c" '{printf F,"cuDNN Version",$2}'
fi

echo
echo $line2
#System fs usage
Filesystem=$( df  -h |  awk  '/^\/dev/{print $6}' )
printf "$format2c"  "Mount Point" "Usage"
echo $line1
for  f  in  $Filesystem
do
     df  -h| awk -v A="$format2c" -v B=$f '{if($NF==B) printf A,B,$3" ("$5")"}'
done

echo 
echo $line2
#Interfaces
INTERFACES=$(ip -4 ad |  grep  'state '  |  awk  -F ":"  '!/^[0-9]*: ?lo/ {print $2}' )
printf "$format3c" "Interface" "MAC" "IP Address"
echo $line1
for  i  in  $INTERFACES
do
    MAC=$(ip ad show dev $i |  grep  "link/ether"  |  awk  '{print $2}' ) 
    ip ad show dev $i |  awk -v A="$format3c" -v B="$i" -v C="$MAC" '/inet/{printf A,B,C,$2}'
done


