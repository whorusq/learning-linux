#!/bin/bash
################################################
# TODO: 登录远程服务器，备份指定数据库并下载到本地
# 示例：
#       ./mysqlDumpRemote2Local.sh
#
# Author: whoru.S.Q <whoru@sqiang.net>
# Version: 1.0
################################################


# 待操作待服务器列表
# 格式："描述,数据库名,数据库用户名,数据库密码,数据库端口号,SSH登录用户名,SSH服务器IP,SSH登录密码,SSH端口号"
HOSTS=(
    "test,db_demo,root,pwd123456,3306,root,192.168.1.127,pwd3333,22"
)
HOSTS_LEN=`echo ${#HOSTS[*]}`
HOST_KEY=

# 服务器上备份文件的存放目录
DB_BACKUP_PATH=/opt/backup

# 当前脚本所处目录
BASE_PATH=$(cd "$(dirname "$0")";pwd)

# 入口
function main {
    #检查基础设置
    if [ "$HOST_LEN" == "0" ]; then
        echo "您还没有配置待操作的服务器参数"
        exit 1
    fi

    # 显示菜单
    MENU="\n"
    INDEX=1
    for host in ${HOSTS[*]}
    do
        local host_name=`echo $host | awk -F ',' '{ print $1" ===> "$2}'`
        MENU=$MENU"\t"$INDEX". "$host_name"\n"
        INDEX=`expr $INDEX + 1`
    done
    echo -en $MENU"\n"

    # 检查选择
    checkChoice

    # 开始导出操作
    doDump
}

function checkChoice {
    read -p "请输入序号选择待备份的数据库：" HOST_NUM
    len=`echo "$HOST_NUM"|sed 's/[1-9]//g'`
    if [ -n "$len" ]; then
        ifGoon "输入有误，只支持1-9的数字，是否重新输入[y/n]："
    else
        KEY=`expr $HOST_NUM - 1`
        if [ $KEY -le $HOSTS_LEN ]; then
            HOST_KEY=$KEY
        else
            ifGoon "未知的序号，是否重新输入[y/n]："
        fi
    fi
}

function ifGoon {
    echo -en "\033[32m==>\033[0m "
    read -p $1 GOON
    if [ "$GOON" == "y" ]; then
        checkChoice
    else
        exit 0
    fi
}

function doDump {
    if [ -z "$HOST_KEY" ]; then
        echo "未知的序号"
        exit 0
    fi

    # 从对应的配置中解析数据库和 SSH 参数
    HOST=${HOSTS[$HOST_KEY]}
    HOST_NAME=`echo $HOST | awk -F ',' '{ print $1 }'`
    DB_NAME=`echo $HOST | awk -F ',' '{ print $2 }'`
    DB_USER=`echo $HOST | awk -F ',' '{ print $3 }'`
    DB_PWD=`echo $HOST | awk -F ',' '{ print $4 }'`
    DB_PORT=`echo $HOST | awk -F ',' '{ print $5 }'`
    SSH_USER=`echo $HOST | awk -F ',' '{ print $6 }'`
    SSH_IP=`echo $HOST | awk -F ',' '{ print $7 }'`
    SSH_PWD=`echo $HOST | awk -F ',' '{ print $8 }'`
    SSH_PORT=`echo $HOST | awk -F ',' '{ print $9 }'`

    # 备份文件名
    DUMP_FILENAME=$HOST_NAME"_"`date +%Y%m%d%H%M%S`

    echo -e "\n\033[32m==>\033[0m 操作开始 "
    sleep 1

    echo -e "\n\033[32m==>\033[0m 登录 ${HOST_NAME} 正式服务器，备份数据库"
    sleep 1
    expect -c "
        spawn ssh ${SSH_USER}@${SSH_IP} -p ${SSH_PORT}
        expect {
            \"yes/no\" {send \"yes\n\"; exp_continue;}
            \"*assword\" { send \"${SSH_PWD}\r\n\"; exp_continue ; sleep 3; }
            \"Last*\" {  send_user \"\n 登录成功 \n\";}
        }

        expect \"*]#\"
        send \"ls ${DB_BACKUP_PATH} &>/dev/null && cd ${DB_BACKUP_PATH} || mkdir -p ${DB_BACKUP_PATH} && cd ${DB_BACKUP_PATH} \r\"
        send \"mysqldump -u${DB_USER} -p${DB_PWD} -P ${DB_PORT} ${DB_NAME} > ${DUMP_FILENAME}.sql \r\"
        send \"sha1sum ${DUMP_FILENAME}.sql > ${DUMP_FILENAME}.sha1sum \r\"
        send \"tar -zcvf ${DUMP_FILENAME}.tar.gz ${DUMP_FILENAME}.* --remove-files  \r\"
        send \"exit \r\"

        interact
    "

    echo -e "\n\033[32m==>\033[0m 退出 ${HOST_NAME} 正式服务器 \n"
    sleep 1

    echo -e "\n\033[32m==>\033[0m 将备份文件拉取到本机"
    sleep 1
    expect -c "
        spawn scp -P $SSH_PORT $SSH_USER@$SSH_IP:$DB_BACKUP_PATH/$DUMP_FILENAME.tar.gz ./
        expect {
            \"*assword\" { send \"${SSH_PWD}\r\n\"; exp_continue; }
        }
    "

    if [ -f $DUMP_FILENAME.tar.gz ]; then
        tar zxvf $DUMP_FILENAME.tar.gz
        # 检查文件完整性
        SHA1SUM_REMOTE=`cat $DUMP_FILENAME.sha1sum | awk '{print $1}'`
        SHA1SUM_LOCAL=`sha1sum $DUMP_FILENAME.sql | awk '{print $1}'`
        if [ "$SHA1SUM_REMOTE" == "$SHA1SUM_LOCAL" ]; then
            echo -e "\n\033[32m==>\033[0m 操作结束，文件位置："$BASE_PATH/$DUMP_FILENAME.sql" \n"
        else
            echo -e "\n\033[31m下载的文件不完整，请使用上面的 scp 命令手动拉取\033[0m"
        fi
    else
        echo -e "\n\033[31m无法下载文件，请使用上面的 scp 命令手动拉取\033[0m"
    fi
}

# 运行
main

