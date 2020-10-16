#!/bin/bash
################################################
# TODO: 备份当前服务器上指定的数据库（多个库，以 , 分隔）
# 示例：
#       ./mysqlDump.sh 备份默认设置的数据库
#       ./mysqlDump.sh db_name1,db_name2,... 备份指定名称的数据库
#
# Author: whoru.S.Q <whoru@sqiang.net>
# Version: 1.0
################################################

# 数据库连接参数
DB_HOST="127.0.0.1"
DB_USER="root"
DB_PWD=""
DB_PORT="3306"

# 待备份的数据库名称，多个库时以 , 分隔
DB_NAME=

# 备份文件路径
DUMP_FILE_PATH=/opt/backup

function main {
    # 参数检查
    # 如果当前脚本在执行时传递了参数，则优先级高于当前脚本文件中变量的默认设置
    if [ -n "$1" ]; then
        DB_NAME=$1
    else
        if [ ! "$DB_NAME" ]; then
            read -p "请输入要备份的数据库名称：" dbname
            DB_NAME=$dbname
        fi
    fi

    # 检查备份目录是否存在
    if [ ! -d "$DUMP_FILE_PATH" ]; then
        mkdir -p $DUMP_FILE_PATH
        if [ "$?" -ne "0" ]; then
            echo -en "无法创建备份文件目录：$DUMP_FILE_PATH"
            exit 1
        fi
    fi

    # 操作开始
    OLD_IFS="$IFS"
    IFS=","
    arr=($DB_NAME)
    IFS="$OLD_IFS"
    for db in ${arr[@]}
    do
        # echo "$db"
        doDump $db
    done
}

function doDump {

    echo -en "\n\033[32m==>\033[0m 开始备份数据库：$1\n"

    dump_date=`date +%Y%m%d%H%M%S`
    dump_file=$1"_"$dump_date".sql"
    final_dump_file=$dump_file".tar.gz"

    # 备份
    # 考虑还原数据库时的通用性，备份的同时不执行压缩操作
    $(which mysqldump) -u$DB_USER -p$DB_PWD -P $DB_PORT $DB_NAME > $dump_file
    if [ "$?" -ne "0" ]; then
        echo -en "操作失败"
        exit 1
    fi

    # 压缩、转移备份的文件
    tar -zcvf $final_dump_file $dump_file
    mv $final_dump_file $DUMP_FILE_PATH
    rm -rf $dump_file

    echo -en "\n\033[32m==>\033[0m 备份完成，生成备份文件：$DUMP_FILE_PATH/$final_dump_file\n"
}

# 运行
main $1

