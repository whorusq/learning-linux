### 说明
> 1. 本文来自阿里云提供的更新源脚本，请以 root 用户操作。
> 2. 替换脚本中当前系统对应的版本号或版本名称。
> 3. 如果使用的是阿里云服务器，将源的域名从 **mirrors.aliyun.com** 改为 **mirrors.aliyuncs.com**，不占用公网流量。[详见这里](http://mirrors.aliyun.com/)

### CentOS

版本：5、6、7

```bash
# centos5.x
cp -fp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-5.repo
yum clean metadata
yum makecache
```

### Ubuntu

版本：12.04 precise、14.04 trusty、16.04 xenial、17.04 zesty

```bash
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
# 14.04
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
EOF
apt-get update
```

### Debian

版本：6 squeeze、7 wheezy、8 jessie

```bash
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
#debian8
deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
EOF
apt-get update
```
