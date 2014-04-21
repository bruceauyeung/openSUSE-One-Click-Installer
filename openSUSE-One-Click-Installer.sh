#!/bin/bash

# 修改语言为英语，确保命令的输出都是英语，这样对命令输出的处理就不会出错了
export LANG=default

# 禁用 cd 源
CD_REPO_ID=`zypper lr -u | awk -F'[|+]'  '$6 ~ /^\s*cd:\/\// {print $1}'`

if [ -n "$CD_REPO_ID" ]; then
    sudo zypper mr -d $CD_REPO_ID
fi

# 刷新软件源并更新系统
sudo zypper refresh
sudo zypper update -l

# 安装 gstreamer 相关插件，这样基于 phonon 框架的多媒体软件就可以播放受专利保护的多媒体文件了
sudo zypper in -l gstreamer-0_10-plugins-base gstreamer-0_10-plugins-good gstreamer-0_10-plugins-bad gstreamer-0_10-plugins-ugly gstreamer-0_10-plugins-ugly-orig-addon gstreamer-0_10-plugins-ffmpeg gstreamer-0_10-plugins-fluendo_mp3

# 安装smplayer, mplayer, w32codec-all
sudo zypper ar -f http://packman.inode.at/suse/openSUSE_13.1/ packman
sudo zypper refresh
sudo zypper in -l  mplayer smplayer w32codec-all smplayer-lang

# 解决Firefox不能播放flash在线视频
sudo zypper in -l flash-player flash-player-kde4 pullin-flash-player

# 在大陆常常不能访问 dl.google.com，所以添加 IP地址映射
sudo sh -c "echo '203.208.46.163    dl.google.com' > /etc/hosts"

# Google Chrome
sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/$(uname -m) Google-Chrome
sudo zypper ref
sudo zypper in -l google-chrome-stable

# quassel，一款先进的跨平台的分布式IRC聊天客户端，界面非常友好功能很强大。
sudo zypper in -l quassel-mono

# 天气预报插件
sudo zypper -n in -l plasmoid-yawp

# FDesktopRecorder 依赖 ffmpeg 等来自于 Packman 的包，通过指定软件源来强制改变提供商
sudo zypper ar -fG -r http://download.opensuse.org/repositories/home:/ecsos/openSUSE_13.1/home:ecsos.repo
sudo zypper -n in -l packman:libswscale2 packman:libswresample0 packman:libavresample1 packman:libavfilter3 packman:libavdevice55 packman:ffmpeg FDesktopRecorder

# 和微软绘图及其相似的KDE绘图工具
sudo zypper -n in -l KolourPaint

sudo zypper -n in libreoffice-l10n-zh-CN libreoffice-kde4

sudo zypper ar -fG -r http://download.opensuse.org/repositories/KDE:/Extra/openSUSE_13.1/KDE:Extra.repo

# tomahawk use phonon-backend-vlc, so vlc-codecs is needed.
sudo zypper -n in -l tomahawk vlc-codecs

sudo zypper in -l FDesktopRecorder libswscale2

# TODO:自动挂载windows分区
# TODO:自动安装 Oracle JDK
# sudo zypper ar -fG -r http://download.opensuse.org/repositories/home:/Superpeppo89/openSUSE_13.1/home:Superpeppo89.repo
# zypper -n in -l java-1_8_0-sun 

# wget --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u15-b03/jdk-7u15-linux-x64.rpm"

# 安装歌词字幕插件
sudo zypper in -l osdlyrics

# 压缩，解压 rar 文件
sudo zypper -n in -l rar unrar

# 支持 7zip 压缩包
sudo zypper in -l p7zip



# 支付宝安全控件的依赖包
sudo zypper in libpng12-0

# 系统统计工具集，包含 sar, pidstat 等
sudo zypper in -l sysstat

# wireshark 网络抓包工具
sudo zypper -n in -l wireshark

sudo zypper -n in -l aria2

sudo zypper -n in kate

# sudo zypper -n in qgit

# 解决 wireshark 没有权限访问网络接口的问题
sudo /usr/sbin/groupadd wireshark
sudo /usr/sbin/usermod -a -G wireshark $USER
sudo /usr/bin/chgrp wireshark /usr/bin/dumpcap
sudo /usr/bin/chmod 4754 /usr/bin/dumpcap

# 添加有用的易于理解的别名
echo "alias today='date "+%Y-%m-%d"'">>~/.bashrc
echo 'alias zin="sudo zypper in"'>>~/.bashrc
echo 'alias zup="sudo zypper up"'>>~/.bashrc
echo 'alias zls="zypper ls"'>>~/.bashrc
echo 'alias zmr="sudo zypper mr"'>>~/.bashrc
echo 'alias zrr="sudo zypper rr"'>>~/.bashrc
echo 'alias zrm="sudo zypper rm -u"'>>~/.bashrc
echo 'alias zse="zypper se"'>>~/.bashrc

echo "alias lxadd='python ~/xunlei-lixian/lixian_cli.py add'">>~/.bashrc
echo "alias lxcfg='python ~/xunlei-lixian/lixian_cli.py config'">>~/.bashrc
echo "alias lxdl='python ~/xunlei-lixian/lixian_cli.py download --continue'">>~/.bashrc
echo "alias lxin='python ~/xunlei-lixian/lixian_cli.py login'">>~/.bashrc
echo "alias lxls='python ~/xunlei-lixian/lixian_cli.py list'">>~/.bashrc
echo "alias lxout='python ~/xunlei-lixian/lixian_cli.py logout'">>~/.bashrc
echo -E "alias lxlstoday='lxls `date  "+%Y-%m-%d"`'">>~/.bashrc
. ~/.bashrc





