# sysinfo.sh

## 简介

以 CentOS 7 为基础写的，有想法的同学可以自行完善或提交PR。


程序查询了以下内容进行展示：
- 当前用户名
- 主机名
- 当前主机时间
- 内核版本
- CPU 名称
- 处理器数量
- CPU 负载
- 内存负载
- 开机时长
- 当前登录用户数
- 当前进程数量
- Nvidia GPU 名称
- Nvidia 驱动版本
- Nvidia CUDA 版本
- Nvidia cuDNN 版本
- 磁盘空间使用情况
- 网卡接口名称、MAC、IP地址

## 使用

该脚本支持安装到 /usr/local/bin/ 目录下，以便日常使用，安装后会写入 /etc/profile ，在登录时会展示执行结果，实现动态的 /etc/motd 。

### 安装 

```
sh sysinfo.sh install
```


### 卸载

```
sh sysinfo.sh uninstall
```

或者 

```
sysinfo uninstall
```