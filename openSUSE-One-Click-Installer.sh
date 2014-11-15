#!/bin/bash

# 修改语言为英语，确保命令的输出都是英语，这样对命令输出的处理就不会出错了
export LANG=default
echo "*****************************************************************************************************************************************"
echo "openSUSE一键安装脚本，由 Bruce Auyeung ( bruce.auyeung#yahoo.com ) 编写。"
echo "欢迎访问我的博客 http://www.suselinks.us 。"
echo "在全新安装openSUSE之后，该脚本帮助你安装一些必要的软件包。(该脚本支持重复运行)"
echo "比如多媒体播放相关的软件包, FireFox的Flash插件, Google Chrome浏览器,  Oracle JDK(不是JRE，是适合于开发者用的JDK), wireshark, Virtual Box虚拟机等等。"
echo "无论是对于新手还是老手，该脚本都可以为你节约大量的时间。"
echo "该脚本具体的修改内容或者要安装的软件包如下(如果你希望取消某些软件包的安装，可以通过定制 ooci.conf 文件来实现)："
echo "(*) 禁用 cd 源。"
echo "(*) 安装 gstreamer 相关插件，这样基于 phonon 框架的多媒体软件就可以播放受专利保护的多媒体文件了。"
echo "(*) 安装 Smplayer，同时还会自动安装 w32codec-all，这样Smplayer就可以播放 rmvb, wmv 等文件格式了。"
echo "(*) 安装 Flash Player，解决Firefox不能播放flash在线视频的问题。"
echo "(*) 安装 Google Chrome，同时解决访问不了 Google Chrome 源不能访问的问题。"
echo "(*) 安装 Quassel，一款先进的跨平台的分布式IRC聊天客户端，界面非常友好功能很强大。"
echo "(*) 安装 plasmoid-yawp，一款天气预报的等离子部件。"
echo "(*) 安装 FDesktopRecorder，一款基于QT编写的桌面录屏软件。"
echo "(*) 安装 kolourpaint，一款和微软绘图及其相似的KDE绘图工具。"
echo "(*) 安装 libreoffice 中文语言包，并解决 libreoffice 和 KDE 桌面主题不协调的问题。"
echo "(*) 安装 tomahawk，一款基于QT编写的非常美观的音乐播放软件。"
echo "(*) 安装 Oracle JDK 最新版本。"
echo "(*) 安装 krusader，一款双面板的文件管理器，和 Total Commander 极其类似。"
echo "(*) 安装 rar， unrar，用于压缩，解压 rar 文件，同时 Ark 也支持 rar 文件了。"
echo "(*) 安装 p7zip，用于支持 7zip 压缩包，同时 Ark 也支持 7zip 文件了。"
echo "(*) 安装 unzip-rcc，安装了该包后 ark 打开一些 windows 下创建的 zip 文件（这些 zip 包中的文件名实际上是以 GBK 编码的）时不再乱码。"
echo "(*) 安装 libpng12-0，支付宝安全控件的依赖包。"
echo "(*) 安装 wireshark，著名的网络抓包工具。"
echo "(*) 安装 KDiff3，类似 Beyond Compare 的文件/文件夹比较工具。"
echo "(*) 安装 VirtualBox，Oracle 出品的虚拟机。"
echo "(*) 定义 zypper 相关的别名，比如 zin 对应于 sudo zypper in, zrm 对应于 sudo zypper rm -u。"
echo "*****************************************************************************************************************************************"
read -p "你确定继续吗？ (Y|n) : " confirm_continue

if [ -z "$confirm_continue" ]; then
  confirm_continue="Y"
fi
if [ "$confirm_continue" == "n" -o "$confirm_continue" == "no" ]; then
  exit
fi

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/ooci.conf

OSVER=$(lsb_release -r|awk '{print $2}')
ARCH=$(uname -m)

# 禁用 cd 源
if [ "$disable_cd_repo" != "0" ]; then
  CD_REPO_ID=`zypper lr -u | awk -F'[|+]'  '$6 ~ /^\s*cd:\/\// {print $1}'`

  if [ -n "$CD_REPO_ID" ]; then
      sudo zypper mr -d $CD_REPO_ID
  fi
fi

# 添加软件源
# w32codec-all 需要该源
sudo zypper --gpg-auto-import-keys ar -fG http://packman.inode.at/suse/openSUSE_$OSVER/ packman

#w32codec-all依赖于包 libstdc++33， 而devel:gcc 里有 libstdc++33
sudo zypper --gpg-auto-import-keys ar -fG http://download.opensuse.org/repositories/devel:/gcc/openSUSE_$OSVER/ devel:gcc

# 刷新软件源并更新系统
sudo zypper -n refresh
sudo zypper -n update -l

sudo zypper -n in -l aria2

# 安装 gstreamer 相关插件，这样基于 phonon 框架的多媒体软件就可以播放受专利保护的多媒体文件了
if [ "$install_gstreamer_plugins" != "0" ]; then
  sudo zypper -n in -l gstreamer-0_10-plugins-base gstreamer-0_10-plugins-good gstreamer-0_10-plugins-bad gstreamer-0_10-plugins-ugly gstreamer-0_10-plugins-ugly-orig-addon gstreamer-0_10-plugins-ffmpeg gstreamer-0_10-plugins-fluendo_mp3
fi

# 安装smplayer, mplayer, w32codec-all
if [ "$install_smplayer" != "0" ]; then
  sudo zypper -n in -l  mplayer smplayer w32codec-all smplayer-lang libstdc++33
fi

# 解决Firefox不能播放flash在线视频
if [ "$install_flash_player" != "0" ]; then
  sudo zypper -n in -l flash-player flash-player-kde4 pullin-flash-player
fi

if [ "$install_google_chrome" != "0" ]; then
  # 在大陆常常不能访问 dl.google.com，所以添加 IP地址映射
  sudo sh -c "echo '203.208.46.163    dl.google.com' > /etc/hosts"
  # Google Chrome
  sudo zypper --gpg-auto-import-keys ar -fG http://dl.google.com/linux/chrome/rpm/stable/$(uname -m) Google-Chrome
  sudo zypper ref
  sudo zypper -n in -l google-chrome-stable
fi

# quassel，一款先进的跨平台的分布式IRC聊天客户端，界面非常友好功能很强大。
if [ "$install_quassel" != "0" ]; then
  sudo zypper -n in -l quassel-mono
fi

if [ "$install_plasmoid_yawp" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -fG -r http://download.opensuse.org/repositories/KDE:/Extra/openSUSE_$OSVER/KDE:Extra.repo
  # 天气预报插件
  sudo zypper -n in -l plasmoid-yawp
fi

if [ "$install_fdesktoprecorder" != "0" ]; then
  # FDesktopRecorder 依赖 ffmpeg 等来自于 Packman 的包，通过指定软件源来强制改变提供商
  sudo zypper --gpg-auto-import-keys ar -fG -r http://download.opensuse.org/repositories/home:/ecsos/openSUSE_$OSVER/home:ecsos.repo
  sudo zypper -n in -l packman:libswscale2 packman:libswresample0 packman:libavresample1 packman:libavfilter3 packman:libavdevice55 packman:ffmpeg FDesktopRecorder
fi

# 和微软绘图及其相似的KDE绘图工具
if [ "$install_kolourpaint" != "0" ]; then
  sudo zypper -n in -l KolourPaint
fi

if [ "$install_libreoffice_l10n_zh_cn"!="0" ]; then
  sudo zypper -n in libreoffice-l10n-zh-CN libreoffice-kde4
fi

if [ "$install_tomahawk" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -fG -r http://download.opensuse.org/repositories/KDE:/Extra/openSUSE_$OSVER/KDE:Extra.repo
  # tomahawk use phonon-backend-vlc, so vlc-codecs ( in packman ) is needed.
  sudo zypper -n in -l tomahawk vlc-codecs
fi

# TODO:自动挂载windows分区
# TODO:自动安装 Oracle JDK
# sudo zypper ar -fG -r http://download.opensuse.org/repositories/home:/Superpeppo89/openSUSE_13.1/home:Superpeppo89.repo
# zypper -n in -l java-1_8_0-sun 

# 自动安装 Oracle JDK 最新版本
if [ "$install_oracle_jdk" != "0" ]; then
  if [ "$ARCH"="x86_64" ]
  then
    JDK_FILE_NAME="jdk-8u25-linux-x64.rpm"
    JDK_RPM_NAME="jdk1.8.0_25-1.8.0_25-fcs.x86_64"    
  else
    JDK_FILE_NAME="jdk-8u25-linux-i586.rpm"
    JDK_RPM_NAME="jdk1.8.0_25-1.8.0_25-fcs"
  fi

  JDK_INSTALLED_RPM_COUNT=`rpm -qa|grep $JDK_RPM_NAME|wc -l`

  if [ "$JDK_INSTALLED_RPM_COUNT" == "0" ]
  then
    # wget -c -p ~ --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie; s_cc=true; s_sq=%5B%5BB%5D%5D" "http://download.oracle.com/otn-pub/java/jdk/8u25-b17/$JDK_FILE_NAME"
    aria2c -c -d ~ -x 10 -s 10 --check-certificate=false --header="Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie; s_cc=true; s_sq=%5B%5BB%5D%5D" "http://download.oracle.com/otn-pub/java/jdk/8u25-b17/$JDK_FILE_NAME"
    sudo zypper -n in ~/$JDK_FILE_NAME
  fi
fi
sudo zypper -n in -l git git-daemon
sudo zypper -n in -l krusader 
# 安装歌词字幕插件
sudo zypper -n in -l osdlyrics

# 压缩，解压 rar 文件
sudo zypper -n in -l rar unrar

# 支持 7zip 压缩包
sudo zypper -n in -l p7zip

# 安装了该包后 ark 打开一些 windows 下创建的 zip 时不再乱码
# 这些 zip 包中的文件名实际上是以 GBK 编码的
sudo zypper -n in -l unzip-rcc



# 支付宝安全控件的依赖包
sudo zypper -n in libpng12-0

# 系统统计工具集，包含 sar, pidstat 等
sudo zypper -n in -l sysstat
sudo zypper -n in -l dmidecode

# wireshark 网络抓包工具
if [ "$install_wireshark" != "0" ]; then
  sudo zypper -n in -l wireshark
  # 解决 wireshark 没有权限访问网络接口的问题
  sudo /usr/sbin/groupadd wireshark
  sudo /usr/sbin/usermod -a -G wireshark $USER
  sudo /usr/bin/chgrp wireshark /usr/bin/dumpcap
  sudo /usr/bin/chmod 4754 /usr/bin/dumpcap
fi


sudo zypper -n in kate

# kate 和 kwrite 支持 rust 语法高亮
mkdir -p ~/.kde4/share/apps/katepart/syntax/ && aria2c --conditional-get=true --allow-overwrite=true -c -d ~/.kde4/share/apps/katepart/syntax/ --check-certificate=false https://raw.githubusercontent.com/mozilla/rust/master/src/etc/kate/rust.xml
# sudo zypper -n in qgit


if [ "$install_kdiff3" != "0" ]; then
  sudo zypper -n in KDiff3
fi
# http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3-4.3.18_96516_openSUSE123-1.x86_64.rpm 依赖下面的包
# sudo zypper -n in gcc kernel-source virtualbox virtualbox-qt

if [ "$install_virtualbox" != "0" ]; then
  if [ "$ARCH" == "x86_64" ]
  then
    VIRTUALBOX_FILE_NAME="VirtualBox-4.3-4.3.18_96516_openSUSE123-1.x86_64.rpm"
    VIRTUALBOX_FILE_URL="http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3-4.3.18_96516_openSUSE123-1.x86_64.rpm"
    VIRTUALBOX_RPM_NAME="VirtualBox-4.3-4.3.18_96516_openSUSE123-1.x86_64"    
  else
    VIRTUALBOX_FILE_NAME="VirtualBox-4.3-4.3.18_96516_openSUSE123-1.i586.rpm"
    VIRTUALBOX_FILE_URL="http://download.virtualbox.org/virtualbox/4.3.18/VirtualBox-4.3-4.3.18_96516_openSUSE123-1.i586.rpm"
    VIRTUALBOX_RPM_NAME="VirtualBox-4.3-4.3.18_96516_openSUSE123-1"    
  fi

  VIRTUALBOX_INSTALLED_RPM_COUNT=`rpm -qa|grep $VIRTUALBOX_RPM_NAME|wc -l`
  if [ "$VIRTUALBOX_INSTALLED_RPM_COUNT" == "0" ]
  then
    aria2c -c -d ~ -x 10 -s 10 --check-certificate=false  "$VIRTUALBOX_FILE_URL"
    sudo zypper -n in ~/"$VIRTUALBOX_FILE_NAME" gcc kernel-source
  fi
fi
# 添加有用的易于理解的别名
BASH_ZYPPER_ALIASES_DEFINED_KEY="# === ooci bash zypper aliases ==="
BASH_ZYPPER_ALIASES_DEFINED_KEY_COUNT=`grep "$BASH_ZYPPER_ALIASES_DEFINED_KEY"  ~/.bashrc|wc -l`
if [ "$define_bash_zypper_aliases" != "0" -a "$BASH_ZYPPER_ALIASES_DEFINED_KEY_COUNT" == "0" ]; then
  echo "$BASH_ZYPPER_ALIASES_DEFINED_KEY">>~/.bashrc
  echo "alias today='date "+%Y-%m-%d"'">>~/.bashrc
  echo 'alias zin="sudo zypper in"'>>~/.bashrc
  echo 'alias zup="sudo zypper up"'>>~/.bashrc
  echo 'alias zls="zypper ls"'>>~/.bashrc
  echo 'alias zmr="sudo zypper mr"'>>~/.bashrc
  echo 'alias zrr="sudo zypper rr"'>>~/.bashrc
  echo 'alias zrm="sudo zypper rm -u"'>>~/.bashrc
  echo 'alias zse="zypper se"'>>~/.bashrc
  echo 'alias zinfo="zypper info"'>>~/.bashrc
fi

BASH_XUNLEI_LIXIAN_ALIASES_DEFINED_KEY="# === ooci bash xunlei lixian aliases ==="
BASH_XUNLEI_LIXIAN_ALIASES_DEFINED_KEY_COUNT=`grep "$BASH_XUNLEI_LIXIAN_ALIASES_DEFINED_KEY"  ~/.bashrc|wc -l`
if [ "$define_bash_xunlei_lixian_aliases" != "0" -a "$BASH_XUNLEI_LIXIAN_ALIASES_DEFINED_KEY_COUNT" == "0" ]; then
  echo "$BASH_XUNLEI_LIXIAN_ALIASES_DEFINED_KEY">>~/.bashrc
  echo "alias lxadd='python ~/xunlei-lixian/lixian_cli.py add'">>~/.bashrc
  echo "alias lxcfg='python ~/xunlei-lixian/lixian_cli.py config'">>~/.bashrc
  echo "alias lxdl='python ~/xunlei-lixian/lixian_cli.py download --continue'">>~/.bashrc
  echo "alias lxin='python ~/xunlei-lixian/lixian_cli.py login'">>~/.bashrc
  echo "alias lxls='python ~/xunlei-lixian/lixian_cli.py list'">>~/.bashrc
  echo "alias lxout='python ~/xunlei-lixian/lixian_cli.py logout'">>~/.bashrc
  echo -E "alias lxlstoday='lxls `date  "+%Y-%m-%d"`'">>~/.bashrc
fi





