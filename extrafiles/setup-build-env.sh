#!/bin/bash
user_uid=`stat -c '%u' /home/poky`
user_gid=`stat -c '%g' /home/poky`
groupadd -o -g "$user_gid" yoctouser
useradd -m -s /bin/bash -u "$user_uid" -g "$user_gid" -G sudo yoctouser
echo 'yoctouser:yoctouser' | chpasswd

runuser -u yoctouser -- git config --global user.name "$GIT_NAME"
runuser -u yoctouser -- git config --global user.email "$GIT_EMAIL"
runuser -u yoctouser -- git config --global credential.helper store
runuser -u yoctouser -- echo "https://$GIT_USERNAME:$GIT_PASSWORD@github.com" >> /home/yoctouser/.git-credentials

if [ "$NO_CONF_RESET" != "true" ]; then
    runuser -l yoctouser -c "echo 'Setting up conf'"

    # This url has changed.
    sed -i 's/http:\/\/www.aleksey.com\/xmlsec\/download\/older-releases\//http:\/\/www.aleksey.com\/xmlsec\/download\//g' /home/yoctouser/poky/meta-security/recipes-security/xmlsec1/xmlsec1_1.2.25.bb
    sed -i 's/http:\/\/www.aleksey.com\/xmlsec\/download\//http:\/\/www.aleksey.com\/xmlsec\/download\/older-releases\//g' /home/yoctouser/poky/meta-security/recipes-security/xmlsec1/xmlsec1_1.2.25.bb

    # To make this work with newer kernel versions, including WSL
    sed -i '/EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"/d' /home/yoctouser/poky/meta-java/recipes-core/icedtea/icedtea7-native_2.1.3.bb
    sed -i '/EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"/d' /home/yoctouser/poky/meta-java/recipes-core/openjdk/openjdk-8-native_172b11.bb
    sed -i '/EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"/d' /home/yoctouser/poky/meta-java/recipes-core/openjdk/openjdk-8_172b11.bb

    echo 'EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"' >> /home/yoctouser/poky/meta-java/recipes-core/icedtea/icedtea7-native_2.1.3.bb
    echo 'EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"' >> /home/yoctouser/poky/meta-java/recipes-core/openjdk/openjdk-8-native_172b11.bb
    echo 'EXTRA_OEMAKE += "DISABLE_HOTSPOT_OS_VERSION_CHECK=ok"' >> /home/yoctouser/poky/meta-java/recipes-core/openjdk/openjdk-8_172b11.bb

    sed -i 's/DL_DIR ?= "\/home\/yoctouser\/downloads"/#DL_DIR ?= "\${TOPDIR}\/downloads"/g' /home/yoctouser/build/conf/local.conf
    sed -i 's/#DL_DIR ?= "\${TOPDIR}\/downloads"/DL_DIR ?= "\/home\/yoctouser\/downloads"/g' /home/yoctouser/build/conf/local.conf

    sed -i 's/-t 2 -T 30 /-t 2 -T 120 /g' /home/yoctouser/poky/meta/conf/bitbake.conf
fi

if [ ! -z $YOCTO_BUILD_PARALLEL  ] && [ $YOCTO_BUILD_PARALLEL > 0 ]; then
    echo "PARALLELISM NUMBER HAS BEEN DECLARED: $YOCTO_BUILD_PARALLEL"
    sed -i '/BB_NUMBER_THREADS/d' /home/yoctouser/build/conf/local.conf
    sed -i '/PARALLEL_MAKE/d' /home/yoctouser/build/conf/local.conf
    echo 'BB_NUMBER_THREADS = "'"$YOCTO_BUILD_PARALLEL"'"' >> /home/yoctouser/build/conf/local.conf
    echo 'PARALLEL_MAKE = "-j '"$YOCTO_BUILD_PARALLEL"'"' >> /home/yoctouser/build/conf/local.conf
fi

if [ "$USE_PROXY" == "on" ]; then
    echo "PROXY IS ON"
    echo -e "\n. /home/yoctouser/proxy/proxy.sh" >> /home/yoctouser/.bash_profile
else
    echo -e "\n. /home/yoctouser/proxy/proxy.sh 1 1 1 1 1 1 1 1 1 1 1 1 1" >> /home/yoctouser/.bash_profile
fi
if [ "$UNAME_WRAP" == "on" ]; then
    echo "UNAME FAKING IS ON"
    mv /bin/uname /bin/uname.orig && mv /bin/uname.sh /bin/uname
fi

su - yoctouser