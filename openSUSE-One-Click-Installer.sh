#!/bin/bash

# 修改语言为英语，确保命令的输出都是英语，这样对命令输出的处理就不会出错了
OLD_LANG=$LANG
export LANG=default
SCRIPT_DIR=$(dirname $0)

if [ ! -f $SCRIPT_DIR/README.md ]; then
  wget -nd -c -P $SCRIPT_DIR --no-check-certificate --no-cookies  "https://raw.githubusercontent.com/redhatlinux10/openSUSE-One-Click-Installer/master/README.md"
fi
if [ ! -f $SCRIPT_DIR/ooci.conf ]; then
  wget -nd -c -P $SCRIPT_DIR --no-check-certificate --no-cookies  "https://raw.githubusercontent.com/redhatlinux10/openSUSE-One-Click-Installer/master/ooci.conf"
fi

cat "$SCRIPT_DIR/README.md"
read -p "你确定继续吗？ (Y|n) : " confirm_continue

if [ -z "$confirm_continue" ]; then
  confirm_continue="Y"
fi
if [ "$confirm_continue" == "n" -o "$confirm_continue" == "no" ]; then
  exit
fi

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

# 启用 aliyun 相关镜像源
if [ "$enable_openSUSE_aliyun_mirrors" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f http://mirrors.aliyun.com/opensuse/distribution/$OSVER/repo/oss/suse/ openSUSE-Oss-aliyun && sudo zypper mr -d  repo-oss
  sudo zypper --gpg-auto-import-keys ar -f http://mirrors.aliyun.com/opensuse/distribution/$OSVER/repo/non-oss/suse openSUSE-Non-Oss-aliyun && sudo zypper mr -d  repo-non-oss
  sudo zypper --gpg-auto-import-keys ar -f http://mirrors.aliyun.com/opensuse/update/$OSVER/ openSUSE-Update-aliyun && sudo zypper mr -d  repo-update
  sudo zypper --gpg-auto-import-keys ar -f http://mirrors.aliyun.com/opensuse/update/$OSVER-non-oss/ openSUSE-Update-Non-Oss-aliyun && sudo zypper mr -d  repo-update-non-oss
fi
# 添加软件源
# w32codec-all 需要该源
sudo zypper --gpg-auto-import-keys ar -f http://mirrors.aliyun.com/packman/openSUSE_$OSVER/ packman-aliyun

#w32codec-all依赖于包 libstdc++33， 而devel:gcc 里有 libstdc++33
sudo zypper --gpg-auto-import-keys ar -f http://download.opensuse.org/repositories/devel:/gcc/openSUSE_$OSVER/ devel:gcc


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

if [ "$install_kwplayer" != "0" ]; then
  # kwplayer needs this repo
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/opensuse_zh/openSUSE_$OSVER/home:opensuse_zh.repo
  # kwplayer needs python3-leveldb
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/devel:/languages:/python3/openSUSE_$OSVER/devel:languages:python3.repo
  sudo zypper -n in -l python3-leveldb dbus-1-python3 kwplayer
fi

# 解决Firefox不能播放flash在线视频
if [ "$install_flash_player" != "0" ]; then
  sudo zypper -n in -l flash-player flash-player-kde4 pullin-flash-player
fi

if [ "$install_google_chrome" != "0" ]; then
  # 在大陆常常不能访问 dl.google.com，所以添加 IP地址映射
  # sudo sh -c "echo '203.208.46.163    dl.google.com' > /etc/hosts"
  # Google Chrome
  # sudo zypper --gpg-auto-import-keys ar -f http://dl.google.com/linux/chrome/rpm/stable/$(uname -m) Google-Chrome
  # 在大陆常常不能访问 dl.google.com，所以启用 fdzh google chrome 镜像源
  sudo zypper --gpg-auto-import-keys ar -fr http://repo.fdzh.org/chrome/google-chrome-mirrors.repo
  sudo zypper ref
  sudo zypper -n in -l google-chrome-stable
fi

# quassel，一款先进的跨平台的分布式IRC聊天客户端，界面非常友好功能很强大。
if [ "$install_quassel" != "0" ]; then
  sudo zypper -n in -l quassel-mono
fi

if [ "$install_plasmoid_yawp" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/KDE:/Extra/openSUSE_$OSVER/KDE:Extra.repo
  # 天气预报插件
  sudo zypper -n in -l plasmoid-yawp
fi

if [ "$install_fdesktoprecorder" != "0" ]; then
  # FDesktopRecorder 依赖 ffmpeg 等来自于 Packman 的包，通过指定软件源来强制改变提供商
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/ecsos/openSUSE_$OSVER/home:ecsos.repo
  sudo zypper -n in -l packman:libavutil52 packman:libswscale2 packman:libswresample0 packman:libavresample1 packman:libavfilter4 packman:libavdevice55 packman:ffmpeg FDesktopRecorder
fi

# 和微软绘图及其相似的KDE绘图工具
if [ "$install_kolourpaint" != "0" ]; then
  sudo zypper -n in -l KolourPaint
fi

if [ "$install_libreoffice_l10n_zh_cn"!="0" ]; then
  sudo zypper -n in libreoffice-l10n-zh-CN libreoffice-kde4
fi

if [ "$install_tomahawk" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/KDE:/Extra/openSUSE_$OSVER/KDE:Extra.repo
  # tomahawk use phonon-backend-vlc, so vlc-codecs ( in packman ) is needed.
  sudo zypper -n in -l tomahawk packman:vlc-codecs
fi

if [ "$install_vlc" != "0" ]; then
  # vlc-codecs 包含许多受限多媒体格式的解码器
  sudo zypper -n in -l packman:vlc packman:vlc-codecs packman:xvba-video
fi

# TODO:自动挂载windows分区
# 自动安装 Oracle Java
if [ "$install_oracle_java" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/Superpeppo89/openSUSE_$OSVER/home:Superpeppo89.repo
  zypper -n in -l java-1_8_0-sun java-1_8_0-sun-plugin
fi

# 自动安装 Oracle JDK 最新版本
if [ "$install_oracle_jdk" != "0" ]; then
source Oracle-JDK-Installer.sh 
fi

if [ "$fix_javafx_mediaplayer_creation_error" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/Superpeppo89/openSUSE_$OSVER/home:Superpeppo89.repo
  
  # see http://www.oracle.com/technetwork/java/javase/certconfig-2095354.html
  zypper -n in -l libavformat53
fi

sudo zypper -n in -l git
git config credential.helper 'cache --timeout 3600'

if [ "$install_krusader" != "0" ]; then
  sudo zypper -n in -l krusader
fi
# 安装歌词字幕插件
if [ "$install_osdlyrics" != "0" ]; then
  sudo zypper -n in -l osdlyrics
fi
# 压缩，解压 rar 文件
sudo zypper -n in -l rar unrar

# 支持 7zip 压缩包
sudo zypper -n in -l p7zip

# 安装了该包后 ark 打开一些 windows 下创建的 zip 时不再乱码
# 这些 zip 包中的文件名实际上是以 GBK 编码的
sudo zypper -n in -l unzip-rcc

if [ "$install_iptux" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/opensuse_zh/openSUSE_$OSVER/home:opensuse_zh.repo
  # 飞鸽传书的 linux 版本
  sudo zypper -n in -l iptux
fi

if [ "$install_hotshots" != "0" ]; then
  sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/Lazy_Kent/openSUSE_$OSVER/home:Lazy_Kent.repo
  sudo zypper -n in -l hotshots
fi

if [ "$install_aliedit" != "0" ]; then
  # 支付宝安全控件的依赖包
  sudo zypper -n in libpng12-0

  # 安装支付宝安全控件
  ALIEDIT_TMP_DIR=`mktemp -d`
  aria2c --conditional-get=true --allow-overwrite=true -c -d $ALIEDIT_TMP_DIR --check-certificate=false https://download.alipay.com/alipaysc/linux/aliedit/1.0.3.20/aliedit.tar.gz

  tar -C $ALIEDIT_TMP_DIR -xzvf  $ALIEDIT_TMP_DIR/aliedit.tar.gz

  # aliedit.sh 需要键入一个字符来退出执行
  sh $ALIEDIT_TMP_DIR/aliedit.sh <<QUITMARK
  x
QUITMARK
  rm -rf $ALIEDIT_TMP_DIR
fi

# 系统统计工具集, 包含 sar, pidstat 等
sudo zypper -n in -l sysstat
sudo zypper -n in -l dmidecode

# 包含 glxinfo, glxgears 等工具
sudo zypper -n in -l Mesa-demo-x

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

if [ "$install_bcloud" != "0" ]; then
    # kwplayer needs this repo
    sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/home:/opensuse_zh/openSUSE_$OSVER/home:opensuse_zh.repo
    sudo zypper --gpg-auto-import-keys ar -f -r http://download.opensuse.org/repositories/devel:/languages:/python3/openSUSE_$OSVER/devel:languages:python3.repo
    sudo zypper -n in home_opensuse_zh:bcloud devel_languages_python3:python3-keyring
fi

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

if [ "$translate_user_dirs_names_from_chinese_to_english" != "0" ]; then
  export LANG=default
  xdg-user-dirs-update --force
  cd ~/桌面/ && ls -A | xargs -i mv -f {} ~/Desktop/ && rmdir ~/桌面
  cd ~/下载/ && ls -A | xargs -i mv -f {} ~/Downloads/ && rmdir ~/下载
  cd ~/模板/ && ls -A | xargs -i mv -f {} ~/Templates/ && rmdir ~/模板
  cd ~/公共/ && ls -A | xargs -i mv -f {} ~/Public/ && rmdir ~/公共
  cd ~/文档/ && ls -A | xargs -i mv -f {} ~/Documents/ && rmdir ~/文档
  cd ~/音乐/ && ls -A | xargs -i mv -f {} ~/Music/ && rmdir ~/音乐
  cd ~/图片/ && ls -A | xargs -i mv -f {} ~/Pictures/ && rmdir ~/图片
  cd ~/视频/ && ls -A | xargs -i mv -f {} ~/Videos/ && rmdir ~/视频
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
  echo 'alias zar="sudo zypper ar"'>>~/.bashrc
  echo 'alias zref="sudo zypper ref"'>>~/.bashrc
  echo 'alias zrm="sudo zypper rm -u"'>>~/.bashrc
  echo 'alias zse="zypper se"'>>~/.bashrc
  echo 'alias zinfo="zypper info"'>>~/.bashrc
  echo 'alias skill9="sudo kill -9"'>>~/.bashrc
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


# mkvtoolnix
