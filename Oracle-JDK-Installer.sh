if [ `which aria2c 2>/dev/null|wc -l` -ne 0  ]
then
  ARIA2C_INSTALLED=1
fi
if [ "`uname -m`"="x86_64" ]
then
  JDK_FILE_NAME="jdk-8u51-linux-x64.rpm"          # 更新时需要修改的值
  JDK_RPM_NAME="jdk1.8.0_51-1.8.0_51-fcs.x86_64" # 更新时需要修改的值
else
  JDK_FILE_NAME="jdk-8u51-linux-i586.rpm" # 更新时需要修改的值
  JDK_RPM_NAME="jdk1.8.0_51-1.8.0_51-fcs" # 更新时需要修改的值
fi
JDK_DL_URL="http://download.oracle.com/otn-pub/java/jdk/8u51-b16/$JDK_FILE_NAME" # 更新时需要修改的值
JDK_INSTALLED_RPM_COUNT=`rpm -qa|grep $JDK_RPM_NAME|wc -l`

if [ "$JDK_INSTALLED_RPM_COUNT" == "0" ]
then
  if [ ! -f ~/$JDK_FILE_NAME ] ; then 
    if [ "$ARIA2C_INSTALLED" == "1" ]
    then
      aria2c -c -d ~ -x 10 -s 10 --check-certificate=false --header="Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie; s_cc=true; s_sq=%5B%5BB%5D%5D" "$JDK_DL_URL"
    else
      wget -c -p ~ --no-check-certificate --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk8-downloads-2133151.html; oraclelicense=accept-securebackup-cookie; s_cc=true; s_sq=%5B%5BB%5D%5D" "$JDK_DL_URL"
    fi
  fi
  
  sudo rpm -Uvh --nodeps ~/$JDK_FILE_NAME
  JAVA_BIN_PATH=`rpm -ql $JDK_RPM_NAME|grep -E '[0-9]+/bin/java$'`
  JAVA_PLUGIN_LIB_PATH=`rpm -ql $JDK_RPM_NAME|grep -E '/libnpjp2.so$'`
  # 获取已经安装的 Java 的 alternative 的最大优先级并加一（忽略不包含 priority 的行）
  JAVA_BIN_CUR_PRI=`/usr/sbin/update-alternatives --display java|awk '{if($0!~/priority/)next}{max=(max>$4)?max:$4}END{print max+1}'`
  JAVA_PLUGIN_CUR_PRI=`/usr/sbin/update-alternatives --display javaplugin|awk '{if($0!~/priority/)next}{max=(max>$4)?max:$4}END{print max+1}'`    
  sudo /usr/sbin/update-alternatives --install "/usr/bin/java" "java" "$JAVA_BIN_PATH" $JAVA_BIN_CUR_PRI
  sudo /usr/sbin/update-alternatives --install "/usr/lib$(test $(getconf LONG_BIT) -eq 64&&echo '64')/browser-plugins/javaplugin.so" "javaplugin" "$(rpm -ql $JDK_RPM_NAME|grep -E '/libnpjp2.so$')" $JAVA_PLUGIN_CUR_PRI
  sudo /usr/sbin/update-alternatives --auto java
  sudo /usr/sbin/update-alternatives --auto javaplugin


  # TODO: 设置 JDK 8 为缺省版本
fi