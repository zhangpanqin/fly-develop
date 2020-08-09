## 文件操作

### 文件常用操作

```bash
# 创建 Mflyyou.txt
touch Mflyyou.txt

# 强制删除目录，-r:递归删除，-f:强制
rm -fr 目录名

# 创建硬链接
ln 源文件 目标文件

# 创建软连接
ln -s 源文件 目标文件

# 查看文件内容，显示行号。q退出
cat file | nl | less

# 监控一个文件的生长,-n:指定从倒数几行
tail -f -n 10 Mflyyou.txt

# 查看一个文件内容，对出现的行数进行计数,sort 必须加；
# uniq 报告重复或省略的行，-c 在行前面加上出现的次数，-u 只显示唯一的不重复行数，-i忽略大小写
cat Mflyyou.txt | sort | uniq -c

# 查看内容行数
cat Mflyyou.txt | wc -l

# 查找文件的路径
find ./ -name "*张*"
```

### 文件内容行排序

Mflyyou.txt 内容

```txt
1:6
3:4
11:5
2:2
6:1
4:0
```

```bash
sort
-t  # 指定排序时所用的栏位分隔字符
-n  # 依照数值的大小排序
-r  # 以相反的顺序来排序
-k  # 指定域
# 对文件内容行倒叙排列
sort -r aa.txt

# 将文件内容中的行，看书数字排序
sort -n aa.txt

# 指定文件内容分隔，根据特定的域排序
sort -t : -nr -k 2 aa.txt
```



### 查看文件的 md5

```bash
# 查看一个文件的 md5 值，mac 下使用 md5 Mflyyou.txt
md5sum Mflyyou.txt
```

### 批量转换文件的内容的编码

```bash
# 安装内容编码转换程序
yum install -y enca

# 查看文件的内容编码及换行符
enca fileName

# 执行编码转换
# 将当前目录下的文件编码转换为 UTF-8
enca -x UTF-8 *
```

### 转换文件的换行符

```bash
# yum install dos2unix
# windows 换行符转换为 unix 换行符.默认不转换二进制程序
dos2unix filename
# linux 换行符转换为 windows 换行符
unix2dos filename
```

### 批量转换文件名称的编码

```bash
# 将 GBK 的编码的名称转换为 UTF-8,时机只是测试，没有生效
# -f 指定原源码格式，-t目标编码格式
convmv -f GBK -t UTF-8 *.txt
# 在匹配到的文件上执行转换
convmv -f GBK -t UTF-8 --notest *.txt
```



## 系统

```bash
top

# 查看系统内存
free -m

# 监控某个命令, -n 指定间隔的秒数 
watch -n 2 uptime

# 查看命令的目录，源码及使用手册位置
whereis command
# 查看执行的命令所在目录
which command

# 后台运行一个程序
nohup cmd &

# 查看执行命令的历史记录
history
```



## SSH

```bash
 # 执行远程主机上命令，运行了远程主机上的 /run.sh 脚本
 ssh -i /Users/zhangpanqin/.ssh/test_local_server root@10.211.55.8 /run.sh
```



## 定时任务

```bash
# 安装定时任务
yum install crontabs
# 开机启动
systemctl enable crond
# 查看服务启动状态
systemctl status crond
# 启动 crond 定时任务
systemctl start crond
# 重启
systemctl restart crond
# 重新加载配置文件
systemctl reload crond
systemctl stop crond
#  列出定时任务
crontab -l
# 删除用户的定时任务
crontab -r
# 编辑用户的定时任务，存在 /var/spool/cron/ 对应的用户名为对应用户的定时任务
crontab -e 
# >/dev/null 2>&1 定时任务不会触发邮件接收
# * * * * * /run-cron.sh >/dev/null 2>&1
```



## 判断是否是 root

```bash
#!/bin/bash

# 判断是不是管理员操作,sudo 运行的时候是 root
if [ "$(whoami)" != "root" ]; then
    echo "please run this script as root !"
    exit 1
fi

USER_ID=$(id -u)

if [ "x${USER_ID}" = "x0" ]; then
    echo "start install apps ....."
else
    echo "please exec as root"
    exit 1
fi
```



## 添加单行或多行内容到文本

```bash
#!/bin/bash
# 自定义文本 END OF FILE 
echo "abcd" >a.txt

# <<EOF 定义文件的结束符
cat >a.txt <<EOF
AA111
BB222
CC333
EOF
```



## 日期

```bash
#!/bin/bash

# 获取当前日期   2020-07-18 14:35:06
NowTime=$(/bin/date +%Y-%m-%d' '%H:%M:%S)
echo ${NowTime}

# 返回时间 2020-08-05-10-28-29
file_time() {
    echo $(date +%Y-%m-%d-%H-%M-%S)
}

# 返回时间戳,1970 到现在
file_timestamp() {
    echo $(date +%s)
}
```



## 程序安装

### yum

`/etc/yum.conf` 配置文件

` /etc/yum.repos.d/` 镜像源配置文件

`   /var/cache/yum/` 镜像缓存位置

yum 源中配置的 `$basearch`  和  `$releasever` 值是什么

```bash
# distroverpkg 对应 rpm 包的信息中可以看到
cat /etc/yum.conf

# 查看 distroverpkg 对应 rpm 包的信息 Version 对应 $releasever Architecture 对应 $basearch
rpm -qi centos-release
```



`yum install` 默认安装某个包

```bash
# 查看一个包的描述信息及概要信息
yum info nginx.

# 查看 yum 中都有什么版本的包
yum search --showduplicates nginx
# 查看属于哪个 yum 源
yum list --showduplicates nginx

# 下载依赖包，不安装
yum install --downloadonly --downloaddir=./test 1:nginx-1.8.1-1.el7.ngx.x86_64
```





### rpm

```bash
# 查找安装了关于 nginx 哪些 rpm 包
rpm -qa | grep nginx

# 查看安装的 rpm 包的概要信息
rpm -qi nginx
rpm -qi nginx-1.18.0-1.el7.ngx.x86_64

# 查看 rpm 包安装哪些文件到哪些目录下
rpm -ql nginx-1.18.0-1.el7.ngx.x86_64

# 卸载安装的某个程序
rpm -e 包名

# 查询文件属于的安装程序
rpm -qf 系统文件名 

# 校验安装的包中的文件是否被修改
rpm -V 包名

# 升级
rpm -Uvh 包全名

# 解压 rpm 包到指定当前目录
rpm2cpio xxx.rpm | cpio -div
```



### 镜像网站

[阿里镜像站](https://developer.aliyun.com/mirror/)

[华为镜像站](https://mirrors.huaweicloud.com/)

[清华镜像站](https://mirrors.tuna.tsinghua.edu.cn/)

