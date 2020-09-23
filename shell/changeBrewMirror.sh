#!/bin/bash
################################################
# TODO: 修改 macOS 系统下的 brew 为国内镜像源
# 示例：
#
#       ./changeBrewMirror.sh
#
# Author: whoru.S.Q <whoru@sqiang.net>
# Link: https://sqiang.net
# Version: 1.0
################################################

# 镜像列表
# 格式："镜像名称,brew地址,homebrew-core地址,homebrew-bottles地址"
MIRROR_LIST=(
  "阿里云,https://mirrors.aliyun.com/homebrew/brew.git,https://mirrors.aliyun.com/homebrew/homebrew-core.git,https://mirrors.aliyun.com/homebrew/homebrew-bottles"
  "中科院,https://mirrors.ustc.edu.cn/brew.git,https://mirrors.ustc.edu.cn/homebrew-core.git,https://mirrors.ustc.edu.cn/homebrew-bottles"
)
IFS_OLD=$IFS
# 支持的 shell 类型
SHELL_TYPE_LIST=("/bin/zsh" "/bin/bash")
# 当前 shell 的配置文件路径
SHELL_CONFIG_PATH=""
# 允许的操作序号
ALLOWED_CHOICE=(0)
# 输入错误计数
ERROR_NO=0
# 最大错误输入次数
MAX_ERROR_NO=3


# 菜单
function menu {
  # 根据配置读取镜像列表，构造操作菜单
  local menu_num=1
  local MENUS=""
  for(( i=1; i<=${#MIRROR_LIST[@]}; i++))
  do
    IFS=,
    local mirror=(${MIRROR_LIST[$(($i-1))]})
    MENUS=$MENUS"[${menu_num}]. ${mirror[0]}镜像源\n"
    ALLOWED_CHOICE[i]=$menu_num
    menu_num=$(($menu_num+1))
  done
  MENUS=$MENUS"[0]. 恢复默认\n"
  clear
  echo "-------------------------------------"
	echo -en $MENUS
	IFS=$IFS_OLD
	echo "-------------------------------------"

  getShellConfigPath ;

  handleChoice ;
}

# 处理用户输入
function handleChoice {
  echo -en "请输入\033[32m序号\033[0m选择要执行的操作: "
	read choice

  if [[ "${ALLOWED_CHOICE[@]}"  =~ "$choice" ]]; then
    if [ $choice -eq 0 ]; then
      reset ;
    else
      change $choice;
    fi
  else
    if [ $ERROR_NO -lt $MAX_ERROR_NO ]; then
      echo -e "无效操作，请重新输入...\n"
      ERROR_NO=$(($ERROR_NO+1))
      handleChoice ;
    else
      echo -e "错误次数过多，请重新运行程序"
      exit 1
    fi
  fi
}

# 获取 shell 配置文件路径
function getShellConfigPath {
  local shell_type=`echo $SHELL`
  if [[ "${SHELL_TYPE_LIST[@]}"  =~ "$shell_type" ]]; then
    case "$shell_type" in
      "/bin/zsh")
        SHELL_CONFIG_PATH=~/.zshrc
        ;;
      "/bin/bash")
        SHELL_CONFIG_PATH=~/.bash_profile
        ;;
      *)
        # default
        ;;
    esac
  else
    echo -e "未知的 shell 类型，请手动设置"
    exit 1
  fi
}

# 显示上一步执行结果
function showResult {
  if [ `echo $?` -eq 0 ]; then
    echo "ok"
  else
    echo "failed"
  fi
}

# 替换
# brew config | grep "${mirror_config[1]}" | wc -l
function change {
  # 根据传过来的编号读取对应的配置信息
  IFS=,
  local mirror_config=(${MIRROR_LIST[$(($1-1))]})

  # brew.git
  echo -e "\n\033[32m==>\033[0m 替换\033[32m brew.git \033[0m\n"
  cd "$(brew --repo)"
  git remote set-url origin ${mirror_config[1]}
  showResult ;

  # homebrew-core.git
  echo -e "\n\033[32m==>\033[0m 替换\033[32m homebrew-core.git \033[0m\n"
  cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
  git remote set-url origin ${mirror_config[2]}
  showResult ;

  # 更新
  echo -e "\n\033[32m==>\033[0m 更新\033[32m brew \033[0m\n"
  brew update
  showResult ;

  # homebrew-bottles
  echo -e "\n\033[32m==>\033[0m 替换\033[32m homebrew-bottles \033[0m\n"
  local exp="export HOMEBREW_BOTTLE_DOMAIN=${mirror_config[3]}"
  if [ $SHELL_CONFIG_PATH != "" ]; then
    echo $exp >> $SHELL_CONFIG_PATH
    source $SHELL_CONFIG_PATH >/dev/null 2>&1
  else
    echo -e "找不到 shell 配置文件，请手动将 $exp 添加到你系统的环境变量中。"
    exit 1
  fi
  showResult ;

  echo -e "\n成功切换到【${mirror_config[0]}】镜像源\n"
}

# 恢复
function reset {
  echo -e "\n\033[32m==>\033[0m 恢复\033[32m brew.git \033[0m\n"
  cd "$(brew --repo)"
  git remote set-url origin https://github.com/Homebrew/brew.git
  showResult ;

  echo -e "\n\033[32m==>\033[0m 恢复\033[32m homebrew-core.git \033[0m\n"
  cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
  git remote set-url origin https://github.com/Homebrew/homebrew-core.git
  showResult ;

  echo -e "\n\033[32m==>\033[0m 更新\033[32m brew \033[0m\n"
  brew update
  showResult ;

  echo -e "\n\033[32m==>\033[0m 恢复\033[32m homebrew-bottles \033[0m\n"
  sed -e '/HOMEBREW_BOTTLE_DOMAIN/d' $SHELL_CONFIG_PATH >/dev/null 2>&1
  source $SHELL_CONFIG_PATH >/dev/null 2>&1
  showResult ;

  echo -e "\n已恢复\n"
}

menu ;