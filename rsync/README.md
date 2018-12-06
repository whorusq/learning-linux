
<p align="center">
	<a href="https://rsync.samba.org">
		<img src="./rsync.jpg" attr="rsync logo" title="官网：https://rsync.samba.org">
	</a>
</p>

目录：

1. [概述](#1-概述)
2. [安装配置](#2-安装配置)
3. [客户端使用](#3-客户端使用)
	- 3.1. [基本格式](#31-基本格式)
	- 3.2. [其它常用选项](#32-其它常用选项)
	- 3.3. [同步远程服务器时免登录密码](#33-同步远程服务器时免登录密码)

---

### 1. 概述

> rsync 是 Unix / Linux 系统下一个快速、灵活的的文件同步和复制工具，，支持本地复制和远程复制与同步，基于协议  [GNU General Public License](https://rsync.samba.org/GPL.html) 开源 。rsync 工具广泛用于备份和镜像，且作为一种改进的复制命令。

官网：[https://rsync.samba.org](https://rsync.samba.org)

最新稳定版本：[v3.1.2](https://download.samba.org/pub/rsync/src/rsync-3.1.2-NEWS) 更新于 2015年12月21日

特性：

- 可以镜像保存整个目录树和文件系统。
- 可以很容易做到保持原来文件的权限、时间、软硬链接等。
- 无须特殊权限即可运行。
- 快速：
    - 第一次同步时 rsync 会复制全部内容，但在下一次只传输修改过的文件。
    - rsync 在传输数据的过程中可以实行压缩及解压缩操作，因此可以使用更少的带宽。
- 安全：可以使用 scp、ssh 等方式来传输文件，当然也可以通过直接的 socket 连接。
- 支持匿名传输，以方便进行网站镜象。

### 2. 安装配置

> 在类 Unix 环境下，rsync 都是默认安装的。

检查是否安装

```
$ rsync --version
rsync  version 3.0.9  protocol version 30
Copyright (C) 1996-2011 by Andrew Tridgell, Wayne Davison, and others.
Web site: http://rsync.samba.org/
Capabilities:
    64-bit files, 64-bit inums, 64-bit timestamps, 64-bit long ints,
    socketpairs, hardlinks, symlinks, IPv6, batchfiles, inplace,
    append, ACLs, xattrs, iconv, symtimes

rsync comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
are welcome to redistribute it under certain conditions.  See the GNU
General Public Licence for details.
```

如果提示未找到命令，则通过如下命令进一步检查

```bash
# CentOS
$ rpm -qa | grep rsync
rsync-3.0.9-17.el7.x86_64

# Ubuntu
$ dpkg -l | grep rsync 
```

安装

```bash
# CentOS
$ yum install rsync

# Ubuntu
$ sudo apt-get install rsync
```

### 3. 客户端使用

#### 3.1. 基本格式

```bash
$ rsync [options] source destination
```

> 其中 source / destination 可以是**本地**，也可以是**远程**，文件传输方向为从 source 到 destination。
>
> - 如果是远程的话，需要追加参数登录用户名、远程服务器地址、位置，格式如：username@ip:path
>
> - 如果具体到目录下的文件名，则可以只同步单个文件。


示例：

```bash
# 将本地目录 project1 下的文件同步到另一台机器上对应的目录
$ rsync -avz ~/www/project1/ dev@192.168.1.149:/Home/dev/www/project1
```
选项：

- `-a` 保留符号链接、权限信息、时间戳，以及 owner & group 信息。
- `-v` 显示更多打印信息。
- `-z` 打开压缩功能。


#### 3.2. 其它常用选项


- `-P` 或 `--progress` 

    > 查看传输进度。

- `-i` 

    > 查看 source / destination 之间的差异。

    ```bash
    $ rsync -avzi thegeekstuff@192.168.200.10:/var/lib/rpm/ /root/temp/
    Password:
    receiving file list ... done
    >f.st.... Basenames
    .f....og. Dirnames
    
    sent 48 bytes  received 2182544 bytes  291012.27 bytes/sec
    total size is 45305958  speedup is 20.76
    ```
    
    说明：
    - f 标识是一个文件
    - s 标识文件大小发生了变化
    - t 标识时间戳发生了变化
    - o 标识文件属主 owner 发了变化
    - g 标识文件属组 group 发了变化


- `-d` 

    > 只同步目录树结构，不同步文件。

- `--delete` 
    
    > 存在于目标位置的文件，如果源位置不存在则删除。

- `--existing` 
    
    > 只同步在目标位置已经存在的文件，源位置如果有新增的文件，在目标位置不创建。

- `-e 'ssh -p 10010'` 

    > 指定远程 shell 来保证安全连接。


- `-u` 

    > 不覆盖在目标位置被修改过的文件。

- `--include '*.html' --exclude '*.conf'`

	> 包含文件，包含多条使用 `--include-from=include.list` 
	>
	> 排除文件，排除多条使用 `--exclude-from=exclude.list`
	>
	> 在文件 exclude.list 或 include.list 中，每行指定一个要包含或排除的文件、目录，使用 **/** 标识源路径。
	
	比如下面的 exclude.list 文件内容：
	
	```
	/index.php
	/Application/Common/Conf/
	/Application/Runtime/
	/Uploads
	``` 


- `--max-size='100K'` 

    > 限制传输的文件大小，可用单位 K / M / G 等。

- `-W`
    
    > 传输整个源位置（source）的文件

    该选项不再对 **source** 和 **destination** 做差异比较，直接传输整个文件，将大大提高 rsync 的处理速度。

    注意：

    > 此选项适合网络带宽不是问题的场景，如果你的网络带宽不理想，尤其是有丢包现象的，还是推荐默认的增量更新方式，避免使用此选项。


#### 3.3. 同步远程服务器时免登录密码

生成本机公钥

```bash
$ ssh-keygen
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

将公钥拷贝到远程服务器

```bash
$ ssh-copy-id -i ~/.ssh/id_rsa.pub -p 10010 test@192.168.1.149
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
test@192.168.1.149's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -p '10010' 'test@192.168.1.149'"
and check to make sure that only the key(s) you wanted were added.
```

检查远程服务器是否添加

```
$ cat ~/.ssh/authorized_keys 
ssh-rsa AAAAB3xxxxxxxxxxxxxxxxx0xuysQjs6bcmGvIsGJZS8J/gouy9AjjfaQqsYLBdHo5bXGTMN3fQ1TntSluB4lfINtzCYf4+VP55WLEzMNTeJnHtVBQen6yNYckcxxxxxxxxxxxxxxxxxG+IAxVS/ugI9kfiOrltxZKn5VUE4hRqwqLIeu9CMhFrPNtTNCLQuqI8FQRz+MixZjFPdsY0OrzxxxxxxxxxxxxxxxxxQeIK/BPOxwolg5xNO29sEw8p5T7al6VxxxxxxxxxxxxxxxxxuLZ8jkv/uMqmyXxxxxxxxxxxxxxxxxxwfMJT4UfdOzr root@localhost.localdomain
```

上面的秘钥信息就是我本机对应的公钥，再次执行 rsync 命令就不需要输入登录密码了。