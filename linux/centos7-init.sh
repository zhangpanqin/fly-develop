#! /bin/bash
##################### 修改以下镜像文件即可 #####################
# 安装的 Mysql 初始化密码,Mysql 8.0 密码复杂度是可以配置的,大小写数字都要有
MYSQL_ROOT_PASSWORD="Thingjs@1234567890"
# 修改密码之后所在文件
MYSQL_ROOT_PASSWORD_AT_FILE="/tmp/mysql.txt"
# java 环境
JAVA_TAR_GZ_URL="https://mirrors.huaweicloud.com/java/jdk/8u201-b09/jdk-8u201-linux-x64.tar.gz"
# maven 环境
MAVEN_TAR_GZ_URL="https://mirrors.huaweicloud.com/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz"
# 安装的 nginx
NGINX_YUM="1:nginx-1.18.0-1.el7.ngx.x86_64"
# 安装的 MYSQL 对应的 bundle,用于建立本地 yum 源
MYSQL_TAR_URL="https://mirrors.huaweicloud.com/mysql/Downloads/MySQL-8.0/mysql-8.0.21-1.el7.x86_64.rpm-bundle.tar"
# 安装的 mysql 的包具体名称
MYSQL_INSTALL_YUM="mysql-community-server-8.0.21-1.el7.x86_64"
# git 安装,从 ius 走阿里镜像
GIT_LOCAL_YUM="git222-2.22.4-1.el7.ius.x86_64"
# 华为 nodejs 镜像
NODE_TAR_GZ_URL="https://mirrors.huaweicloud.com/nodejs/v12.18.3/node-v12.18.3-linux-x64.tar.xz"
# 华为 yarn
YARN_TAR_GZ_URL="https://mirrors.huaweicloud.com/yarn/v1.22.4/yarn-v1.22.4.tar.gz"

##################### 修改以上镜像文件即可 #####################

# 所有包安装的目录
APP_INSTALL_BASE_DIR="/opt"

# 修改前端依赖包的镜像
YARN_REGISTRY="https://registry.npm.taobao.org"

# 获取执行 shell 的 user id,为 0 说明是 root 用户
USER_ID=$(id -u)

if [ "x${USER_ID}" = "x0" ]; then
    echo "start install apps ....."
else
    echo "please exec as root"
    exit 1
fi

# 定义函数
# 返回时间 2020-08-05-10-28-29
file_time() {
    echo $(date +%Y-%m-%d-%H-%M-%S)
}

# 返回时间戳,1970 到现在
file_timestamp() {
    echo $(date +%s)
}

# 备份 centos base 为阿里镜像
backup_yum_repo_centos_base() {
    echo "更换 CentOS-Base yum 源为阿里镜像 ..."
    local CENTOS_BASE_REPO='/etc/yum.repos.d/CentOS-Base.repo'
    local CENTOS_BASE_REPO_ALI_URL='https://mirrors.aliyun.com/repo/Centos-7.repo'
    if [ -f ${CENTOS_BASE_REPO} ]; then
        mv ${CENTOS_BASE_REPO} ${CENTOS_BASE_REPO}.$(file_time).backup
        curl ${CENTOS_BASE_REPO_ALI_URL} -o ${CENTOS_BASE_REPO}
    else
        curl ${CENTOS_BASE_REPO_ALI_URL} -o ${CENTOS_BASE_REPO}
    fi
}

# 备份 epel 为阿里镜像
backup_yum_repo_epel() {
    echo "更换 epel yum 源为阿里镜像 ..."
    local EPOLL_REPO="/etc/yum.repos.d/epel.repo"
    local EPOLL_REPO_ALI_URL="http://mirrors.aliyun.com/repo/epel-7.repo"

    if [ -f ${EPOLL_REPO} ]; then
        mv ${EPOLL_REPO} ${EPOLL_REPO}.$(file_time).backup
        curl ${EPOLL_REPO_ALI_URL} -o ${EPOLL_REPO}
    else
        curl ${EPOLL_REPO_ALI_URL} -o ${EPOLL_REPO}
    fi
}
backup_yum_repo_ius() {
    echo "更换 ius 源为阿里 ....."
    local IUS_ALI_YUM="/etc/yum.repos.d/ius_ali.repo"
    if [ -f ${IUS_ALI_YUM} ]; then
        mv ${IUS_ALI_YUM} ${IUS_ALI_YUM}.$(file_time).backup
    fi
    cat >${IUS_ALI_YUM} <<EOF
[ius]
name = IUS for Enterprise Linux 7 - \$basearch
baseurl = https://mirrors.aliyun.com/ius/7/\$basearch/
enabled = 1
repo_gpgcheck = 0
gpgcheck = 1
gpgkey = https://mirrors.aliyun.com/ius/RPM-GPG-KEY-IUS-7
EOF
}

backup_yum_repo_nginx() {
    echo "创建 nginx yum 源 ..."
    local NGINX_YUM_REPO_FILE="/etc/yum.repos.d/nginx.repo"
    if [ -f ${NGINX_YUM_REPO_FILE} ]; then
        mv ${NGINX_YUM_REPO_FILE} ${NGINX_YUM_REPO_FILE}.$(file_time).backup
    fi
    cat >${NGINX_YUM_REPO_FILE} <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
}
# 自定义的镜像
backup_yum_repo_mysql() {
    echo "创建 mysql yum 源 ..."
    local MYSQL_REPO="/etc/yum.repos.d/mysql_custom_yum.repo"
    local MYSQL_BASE_DIR="${APP_INSTALL_BASE_DIR}/mysql8"
    local MYSQL_TAR="${MYSQL_BASE_DIR}/mysql8.tar"
    # 自建本地 yum 源
    local MYSQL_YUM_REPO_DIR="${MYSQL_BASE_DIR}/repo"
    # 本地 yum 源仓库不存在下载
    if [ ! -d ${MYSQL_BASE_DIR} ]; then
        mkdir -p ${MYSQL_BASE_DIR}
    fi

    # 本地没有 mysql bundle,下载
    if [ ! -f ${MYSQL_TAR} ]; then
        echo "下载 mysql 安装包 ...."
        curl ${MYSQL_TAR_URL} -o ${MYSQL_TAR}
    fi

    # 删除本地 yum 源
    if [ -d ${MYSQL_YUM_REPO_DIR} ]; then
        rm -fr ${MYSQL_YUM_REPO_DIR}
    fi

    mkdir -p ${MYSQL_YUM_REPO_DIR}
    tar -xf ${MYSQL_TAR} -C ${MYSQL_YUM_REPO_DIR}
    createrepo ${MYSQL_YUM_REPO_DIR}
    # 备份更新 msyql yum 源文件
    if [ -f ${MYSQL_REPO} ]; then
        mv ${MYSQL_REPO} ${MYSQL_REPO}.$(file_time).backup
    fi
    # 生成文件信息
    cat >${MYSQL_REPO} <<EOF
[mysql-custom]
name=mysql-custom
baseurl=file://${MYSQL_YUM_REPO_DIR}/
gpgcheck=0
enabled=1
EOF
}

install_mysql() {
    # 是否安装了 mysql
    echo "安装 mysql ..."
    mysqld --version 1>/dev/null 2>&1
    if [ "x$?" == "x0" ]; then
        echo "系统已经安装了 mysql,版本信息为 :"
        mysqld --version
    else
        yum install ${MYSQL_INSTALL_YUM} -y
        mysqld --version >/dev/null 2>&1
        [ "x$?" = "x0" ] && echo "安装 MySQL 成功" || "安装 MYSQL 失败"
        # 设置开机启动
        systemctl enable mysqld
        # 启动 mysql
        systemctl restart mysqld
        # 修改用户名密码
        local password=$(grep 'temporary password' /var/log/mysqld.log | awk -F ': ' '{print $2}')
        echo "密码为: ${MYSQL_ROOT_PASSWORD_AT_FILE}"
        echo "${password}" >${MYSQL_ROOT_PASSWORD_AT_FILE}
        echo "密码写入到: ${MYSQL_ROOT_PASSWORD_AT_FILE}"
    fi

}

install_nginx() {
    echo "安装 nginx ..."
    nginx -v 1>/dev/null 2>&1
    if [ "x$?" = "x0" ]; then
        echo "系统已经安装了 nginx,版本信息为: "
        echo "$(nginx -v)"
    else
        yum install ${NGINX_YUM} -y
        nginx -v 1>/dev/null 2>&1
        if [ "x$?" = "x0" ]; then
            echo "安装 nginx 成功,安装的版本为: "
            echo "$(nginx -v)"
            # 设置 nginx 开机启动
            systemctl enable nginx
            # 启动 nginx
            systemctl restart nginx
        else
            echo "安装 nginx 失败"
        fi
    fi
}

# 更换镜像资源
change_yum_mirror() {
    backup_yum_repo_centos_base
    backup_yum_repo_epel
    backup_yum_repo_ius
    backup_yum_repo_nginx
    backup_yum_repo_mysql
    yum makecache
    # 需要安装这个源
    yum install epel-release -y
}

# 单独安装 java
install_java() {
    # java 安装的基础路径
    local JAVA_BASE_DIR="${APP_INSTALL_BASE_DIR}/jdk-180"
    local JAVA_TAR="${JAVA_BASE_DIR}/java.tar"
    JDK_TYPE=$(java -version 2>&1 | sed '1!d' | sed -e 's/"//g' | awk '{print $1}')
    if [ "x${JDK_TYPE}" == "xjava" ]; then
        JAVA_MESSAGE=$(java -version 2>&1 | sed '1!d' | sed -e 's/"//g' | awk '{print $0}')
        echo "系统已经安装 java , 版本为 ${JAVA_MESSAGE},本次忽略安装 java"
    else
        # java 目录如果存在删除
        if [ -d ${JAVA_BASE_DIR} ]; then
            mv ${JAVA_BASE_DIR} ${JAVA_BASE_DIR}_$(file_time)_backup
        fi
        mkdir -p ${JAVA_BASE_DIR}
        echo "下载 java ...."
        curl ${JAVA_TAR_GZ_URL} -o ${JAVA_TAR}
        tar -xf ${JAVA_TAR} -C ${JAVA_BASE_DIR}/ --strip-components=1
        rm -fr /user/bin/java*

        ln -sf ${JAVA_BASE_DIR}/bin/java* /usr/bin/

        AVA_MESSAGE=$(java -version 2>&1 | sed '1!d' | sed -e 's/"//g' | awk '{print $0}')
        java -version 2>&1
        [ "x$?" = "x0" ] && echo "本次安装 java 版本为 ${JAVA_MESSAGE}" || echo "安装 java 失败"
    fi
}

# 单独安装 maven
install_maven() {
    local MAVEN_BASE_DIR="${APP_INSTALL_BASE_DIR}/maven3"
    local MAVEN_TAR="${MAVEN_BASE_DIR}/maven3.tar"
    # 本地依赖包的安装位置
    local MAVEN_LOCAL_REPO="${MAVEN_BASE_DIR}/local_repo"
    # 判断是否安装了 maven
    mvn -v 1>/dev/null 2>&1
    if [ "x$?" = "x0" ]; then
        local MESSAGE=$(mvn -v | sed -n '/Maven/p')
        echo "系统已经安装了 maven ,版本信息为: "
        echo "${MESSAGE}"
    else
        # maven 目录如果存在则备份
        if [ -d ${MAVEN_BASE_DIR} ]; then
            mv ${MAVEN_BASE_DIR} ${MAVEN_BASE_DIR}_$(file_time)_backup
        fi

        mkdir -p ${MAVEN_BASE_DIR}
        mkdir -p ${MAVEN_LOCAL_REPO}
        echo "下载 maven ..."
        curl ${MAVEN_TAR_GZ_URL} -o ${MAVEN_TAR}
        tar -xf ${MAVEN_TAR} -C ${MAVEN_BASE_DIR}/ --strip-components=1
        ln -sf ${MAVEN_BASE_DIR}/bin/mvn* /usr/bin/
        mvn -v 1>/dev/null 2>&1
        if [ "x$?" = "x0" ]; then
            local SHEO_MESSAGE=$(mvn -v | sed -n '/Maven/p')
            echo "系统已经安装了 maven ,版本信息为: "
            echo "${SHEO_MESSAGE}"
            echo "修改 maven 下载依赖库的镜像为阿里 maven 镜像"
            cat >${MAVEN_BASE_DIR}/conf/settings.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>
        ${MAVEN_LOCAL_REPO}
    </localRepository>
    <mirrors>
        <mirror>
            <id>aliyunmaven</id>
            <mirrorOf>*</mirrorOf>
            <name>阿里云公共仓库</name>
            <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
    </mirrors>

</settings>
EOF
        else
            echo "安装 maven 失败"
            exit 1
        fi
    fi
}
# 安装 git
install_git() {
    git --version >/dev/null 2>&1
    if [ "x$?" = "x0" ]; then
        echo "系统已经安装 git 了,本次不安装 git"
    else
        yum install ${GIT_LOCAL_YUM} -y
        git --version >/dev/null 2>&1
        [ "x$?" = "x0" ] && echo "git 安装成功" || echo "git 安装失败"
    fi
}

# 安装 java 和 maven
install_java_and_maven() {
    # 安装 java 环境
    java -version 1>/dev/null 2>&1

    if [ "x$?" = "x0" ]; then
        JDK_TYPE=$(java -version | sed '1!d' | sed -e 's/"//g' | awk '{print $1}')
        if [ "xopenjdk" = "x${JDK_TYPE}" ]; then
            # 删除 openjdk
            echo "系统安装的 openjdk ,将会被删除"
        else
            install_java
        fi
    else
        install_java
    fi
    install_maven
}

# 安装 nodejs 和 yarn
install_nodejs_and_yarn() {
    node -v 1>/dev/null 2>&1
    if [ "x$?" = "x0" ]; then
        echo "系统已经安装 nodejs , 版本为: $(node -v),本次忽略安装 nodejs"
    else
        # nodejs 没有安装,安装 nodejs
        local NODEJS_DIR="${APP_INSTALL_BASE_DIR}/nodejs"
        local NODEJS_TAR="${NODEJS_DIR}/nodejs.tar"
        if [ -d ${NODEJS_DIR} ]; then
            mv ${NODEJS_DIR} ${NODEJS_DIR}_$(file_time)_backup
        fi
        # 创建目录 /opt/nodejs 目录
        mkdir -p ${NODEJS_DIR}
        curl -sL ${NODE_TAR_GZ_URL} -o ${NODEJS_TAR}
        tar -xf ${NODEJS_TAR} -C ${NODEJS_DIR}/ --strip-components=1

        if [ -f ${NODEJS_DIR}/bin/node ]; then
            \cp -s --remove-destination ${NODEJS_DIR}/bin/node /usr/bin
        fi
        echo "本次安装了 nodejs,版本为: $(node -v)"
    fi

    yarn -v 1>/dev/null 2>&1
    # 存在 yarn 不安装
    if [ "x$?" = "x0" ]; then
        echo "系统已经安装 yarn , 版本为 $(yarn -v) , 本次忽略安装 yarn"
    else
        local YARN_BASE_DIR="${APP_INSTALL_BASE_DIR}/yarn"
        local YARN_TAR="${NODEJS_DIR}/yarn.tar"

        if [ -d ${YARN_BASE_DIR} ]; then
            mv ${YARN_BASE_DIR} ${YARN_BASE_DIR}_$(file_time)_backup
        fi

        mkdir -p ${YARN_BASE_DIR}
        curl -sL ${YARN_TAR_GZ_URL} -o ${YARN_TAR}
        tar -xf ${YARN_TAR} -C ${YARN_BASE_DIR}/ --strip-components=1

        if [ -f ${YARN_BASE_DIR}/bin/yarn ]; then
            \cp -s --remove-destination ${YARN_BASE_DIR}/bin/yarn /usr/bin
        fi
        yarn config set registry ${YARN_REGISTRY} -g
        echo "本次安装了 yarn,版本为: $(yarn -v)"
    fi
}
change_yum_mirror
install_nginx
install_nodejs_and_yarn
install_java_and_maven
install_mysql
install_git
