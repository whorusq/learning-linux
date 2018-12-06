### `mysqlDump.sh`

#### 使用说明

1. 使用前先设置数据库连接参数
2. 设置待备份的数据库名称

    - 方式一：在脚本文件里修改变量 DB_NAME
    - 方式二：运行脚本时动态传参，如 `./mysqlDump.sh db_name`

    > 注意：脚本运行参数优先级高于脚本文件中的设置；待备份的数据库名称支持多个，以 `,` 分隔。

#### 示例

```
[root@local wwwroot]# ./mysqlDump.sh online_v3.0

==> 开始备份数据库：online_v3.0
Warning: Using a password on the command line interface can be insecure.
online_v3.0_20181012164400.sql

==> 备份完成，生成备份文件：/opt/backup/online_v3.0_20181012164400.sql.tar.gz
```

#### `mysqlDumpRemote2Local.sh`

> 适用场景：远程服务器上的 MySQL 不允许远程访问，此时我们需要先登录服务器，备份数据库后，将备份文件拉取到本机。

示例：

```
➜  ./mysqlDumpRemote2Local.sh

        1. test ===> db_demo

请输入序号选择待备份的数据库：1

==> 操作开始

==> 登录 test 正式服务器，备份数据库
spawn ssh root@192.168.1.127 -p 22
root@192.168.1.127's password:
Last login: Tue Nov 13 13:43:53 2018 from xxxxxxxxx

 登录成功
[root@ test ~]# ls /opt/backup &>/dev/null && cd /opt/backup || mkdir -p /opt/backup && cd /opt/backup
[root@ test backup]# mysqldump -uroot -ppwd123456 -P 3306 db_demo > test_20181113135359.sql
Warning: Using a password on the command line interface can be insecure.
[root@dbhs backup]# tar -zcvf test_20181113135359.tar.gz test_20181113135359.sql
test_20181113135359.sql
[root@dbhs backup]# exit
logout
Connection to 192.168.1.127 closed.

==> 退出 test 正式服务器

==> 将备份文件拉取到本机

spawn scp -P 22 root@192.168.1.127:/opt/backup/test_20181113135359.tar.gz /Users/xxxxx/mydev/linux-learning/shell
root@218.29.103.28's password:
test_20181113135359.tar.gz                       100%   66KB 941.5KB/s   00:00

==> 操作结束，文件位置：/Users/xxxxx/mydev/linux-learning/shell/test_20181113135359.tar.gz
```

### `mysqlImport.sh`

> 使用备份文件恢复数据到指定数据库，并使用 `pv` 查看实时导入进度。

#### 示例

```
./mysqlImport.sh
请输入备份文件绝对路径：v3.0_20181109_020001.sql
请输入要恢复到的数据库名称：bak_import_test

注意：将使用备份文件【v3.0_20181109_020001.sql】恢复到数据库【bak_import_test】
是否确认并继续？[yes|no] : yes

==> 操作开始
Warning: Using a password on the command line interface can be insecure.
0:02:28 [======================================================================================================================>] 100%

==> 操作结束
```
