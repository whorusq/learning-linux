#!/bin/bash
################################################
# TODO: 将备份的数据库文件（xx.sql）恢复到本地指定的数据库
# 示例：
#       ./mysqlImport.sh
#
# Author: whoru.S.Q <whoru@sqiang.net>
# Version: 1.0
################################################

# 数据库设置
DB_USER=root
DB_PWD=123123

# 参数检查
if [ ! -n "$DB_USER" -o ! -n "$DB_PWD" ]; then
    echo -en "缺少数据库配置参数，请先修改\n"
    exit 1
fi
read -p "请输入备份文件名称（非当前目录，输入文件的完整路径）：" BACKUP_FILE
if [ ! -f $BACKUP_FILE ]; then
    echo "备份文件不存在，请检查路径："$BACKUP_FILE
    exit 1
fi
read -p "请输入要恢复到的数据库名称：" DB_NAME

function main {
    echo -en "\n注意：将使用备份文件【\033[32m"$BACKUP_FILE"\033[0m】恢复到数据库【\033[32m"$DB_NAME"\033[0m】\n"
    read -p "是否确认并继续？[yes|no] : " GOON
    if [ -n "$GOON" ]; then
        case $GOON in
            yes)
                doImport
                ;;
            no)
                exit 0
                ;;
            *)
                echo -en "\n无效的操作，仅支持 yes 或 no\n"
                exit 1
                ;;
        esac
    else
        exit 1
    fi
}

function doImport {
    sleep 1
    echo -en "\n\033[32m==>\033[0m 操作开始 \n"

    if [ `which pv | grep pv | wc -l` -eq 0 ]; then
        $(which pv) -t -p $BACKUP_FILE | $(which mysql) -u$DB_USER -p$DB_PWD -D $DB_NAME
    else
        $(which mysql) -u$DB_USER -p$DB_PWD $DB_NAME < $BACKUP_FILE
    fi

    echo -en "\n\033[32m==>\033[0m 操作结束 \n"
}


# 运行
main
