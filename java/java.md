## Java

虚拟文件系统。shell 输入 ls 看到的目录树实际不是在一个磁盘分区中。`df` 查看目录分区。这个目录树就是虚拟文件系统。

```txt
-:普通文件
d:目录
s:socket
l:链接。软连接，硬链接
```



文件描述符

0：标准输入

1：标准输出

2：报错输出



linux 重定向 和 管道流



内存页。

磁盘数据和内存页数据不一致为脏页，内核会将脏页（刷盘时机通过参数配置）刷盘。

FileOutPutStream(每次写入都会切换内核态，将数据写入到内核。) 和 BufferOutStream （8KB ,写入 8KB 才会调用系统调用，切换内核态，将数据写入到内核空间）







## Queue

|                    | add                                                   | offer                                     | put                                            |
| ------------------ | ----------------------------------------------------- | ----------------------------------------- | ---------------------------------------------- |
| ArrayBlockingQueue | 调用 offer,如果添加成功返回 true,队列满的话，抛出异常 | 队列没满，插入成功，满的话，直接返回false | 插入元素，队列满的话，会等待队列不满的时候插入 |
|                    | take                                                  |                                           |                                                |
|                    |                                                       |                                           |                                                |



## Spi

![image-20200217073413007](http://oss.mflyyou.cn/blog/20201005231934.png?author=zhangpanqin)

```java
ServiceLoader<Spi1> printerLoader = ServiceLoader.load(Spi1.class);
for (Spi1 printer : printerLoader) {
    printer.log1();
}
```

##Jvm

### 运行时数据划分

![rundata](http://oss.mflyyou.cn/blog/20201005231939.jpg?author=zhangpanqin)

### Jvm 参数

```txt
//常见参数
-Xms1024m 初始堆大小 
-Xmx1024m 最大堆大小  一般将xms和xmx设置为相同大小，防止堆扩展，影响性能。
-Xss 设置虚拟机栈的大小
-Xmn 设置年轻代大小
-XX:NewRatio=n 设置年轻代和年老代的比值。n 为3,表示年轻代与年老代比值为1:3
-XX:SurvivorRatio=n 年轻代中Eden区与一个Survivor区的比值。n 为 8，标识eden:s0:s1=8:1:1
-XX:+HeapDumpOnOutOfMemoryError OOM时自动保存堆文件


-XX:+UseParallelGC:设置并行收集器 
-XX:+UseParalledlOldGC:设置并行年老代收集器 
-XX:+UseConcMarkSweepGC:设置并发收集器

//垃圾回收统计信息 
-XX:+PrintGC 
-XX:+PrintGCDetails 
-XX:+PrintGCTimeStamps 
```
```bash
java -jar -server -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=128m -Xms1024m -Xmx1024m -Xmn256m -Xss512k -XX:SurvivorRatio=8 -XX:+UseConcMarkSweepGC newframe-1.0.0.jar
```



```txt
-XX:-UseParallelGC
-XX:-UseParallelOldGC
-XX:-HeapDumpOnOutOfMemoryError
-XX:-PrintGCDetails
-XX:-PrintGCTimeStamps

// 查看所有默认 jvm 参数
java -XX:+PrintFlagsFinal -version

// 查看 JVM 正在使用的参数
java -XX:+PrintCommandLineFlags -version

// 设置
-XX:HeapDumpPath=./dump/oom.dump

// 初始堆大小
-Xms20m

// 最大堆大小
-Xmx20m

// 新生代大小(默认为堆的三分之一)
-Xmn 20m

// 老年代/新生代
XX:NewRatio=2


// eden/survivor
-XX:SurvivorRatio=8

// 跟踪类加载
-XX:+TraceClassLoading

// 日志位置
-Xloggc:log/gc.log
```





## 工程部署

### 启动项目

```bash
#!/bin/bash
BASE_DIR=`cd $(dirname $0)/..; pwd`
JAVA_OPT="-server -Xms2g -Xmx2g -Xmn1g -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"

if [ ! -d "${BASE_DIR}/logs" ]; then
  mkdir ${BASE_DIR}/logs
fi

# check the start.out log output file
if [ ! -f "${BASE_DIR}/logs/start.out" ]; then
  touch "${BASE_DIR}/logs/start.out"
fi
# start
echo "$JAVA ${JAVA_OPT}" > ${BASE_DIR}/logs/start.out 2>&1 &
nohup java -jar ${JAVA_OPT} jail-2.0-0.0.1-SNAPSHOT.jar --server.port=8888 > ${BASE_DIR}/logs/start.out 2>&1 &
```

### 关闭项目

```bash
#!/bin/bash
PID=`ps -ef | grep jail-2.0-0.0.1-SNAPSHOT.jar | grep -v grep | awk '{ print $2 }'`
if [ -z "$PID" ] ; then
    echo "No server running"
    exit -1;
fi

echo "Server $PID is running..."

kill $PID

echo "Send shutdown request to server (${PID}) OK"
```

### 参考示例

```bash
#!/bin/bash

# Spring-Boot 常规启动脚本，基于HotSpot Java8
# 使用方式：xx.sh [start|stop|restart|status|dump]
# 将Spring-Boot Jar包和此脚本放在同一目录下，之后配置APP_NAME/PROFILE即可

cd `dirname $0`
# 应用名（boot jar包名）
APP_NAME=scheduler

# Spring-Boot环境名（profiles）
PROFILE=test

JAR_NAME=$APP_NAME\.jar
PID=$APP_NAME\.pid
APP_HOME=`pwd`
LOG_PATH=$APP_HOME/logs
GC_LOG_PATH=$LOG_PATH/gc
DEBUG_FLAG=$2

if [ ! -d $LOG_PATH ]; then
    mkdir $LOG_PATH
fi

if [ ! -d $GC_LOG_PATH ]; then
    mkdir $GC_LOG_PATH
fi

# DUMP父目录
DUMP_DIR=$LOG_PATH/dump
if [ ! -d $DUMP_DIR ]; then
    mkdir $DUMP_DIR
fi

# DUMP目录前缀
DUMP_DATE=`date +%Y%m%d%H%M%S`

# DUMP目录
DATE_DIR=$DUMP_DIR/$DUMP_DATE
if [ ! -d $DATE_DIR ]; then
    mkdir $DATE_DIR
fi


# GC日志参数
GC_LOG_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$GC_LOG_PATH/gc-%t.log"

# OOM Dump内存参数
DUMP_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LOG_PATH"

# JVM DEBUG参数，用于调试，默认不开启

# ClassLoader和Method Compile日志，用于调试
COMPILE_LOADER_OPTS="-XX:+TraceClassLoading -XX:+TraceClassUnloading -XX:-PrintCompilation"

# 远程调试参数
REMOTE_DEBUG_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"

# DEBUG参数
DEBUG_OPTS="$COMPILE_LOADER_OPTS $REMOTE_DEBUG_OPTS"

# 至于Garbage Collector，虽然Java8已经支持G1了，但是不一定必须用，CMS在默认场景下也是一个优秀的回收器
GC_OPTS="-XX:+UseConcMarkSweepGC"

OTHER_OPTS="-Djava.security.egd=file:/dev/./urandom"

# JVM 启动参数，如无特殊需求，推荐只配置堆+元空间
JVM_OPTIONS="-server -Xms2g -Xmx2g -XX:MetaspaceSize=256m $GC_OPTS $GC_LOG_OPTS $DUMP_OPTS $OTHER_OPTS"

#使用说明，用来提示输入参数
usage() {
    echo "Usage: sh [run_script].sh [start|stop|restart|status|dump]"
    exit 1
}

#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep $APP_HOME/$JAR_NAME|grep -v grep|awk '{print $2}' `
  #如果不存在返回1，存在返回0     
  if [ -z "${pid}" ]; then
   return 1
  else
    return 0
  fi
}

#启动方法
start(){
  is_exist
  if [ $? -eq "0" ]; then 
    echo "--- ${JAR_NAME} is already running PID=${pid} ---" 
  else 
      if [ "$DEBUG_FLAG" = "debug" ]; then
        JVM_OPTIONS="$JVM_OPTIONS $DEBUG_OPTS"
        echo -e "\033[33m Warning: currently running in debug mode! This mode enables remote debugging, printing, compiling, and other information \033[0m"
    fi
      echo "JVM_OPTIONS : "
      echo "$JVM_OPTIONS"
    nohup java -jar $JVM_OPTIONS -Dspring.profiles.active=$PROFILE $APP_HOME/$JAR_NAME >/dev/null 2>&1 &
    echo $! > $PID
    echo "--- start $JAR_NAME successed PID=$! ---" 
   fi
  }

#停止方法
stop(){
  #is_exist
  pidf=$(cat $PID)
  #echo "$pidf"  
  echo "--- app PID = $pidf begin kill $pidf ---"
  kill $pidf
  rm -rf $PID
  sleep 2
  is_exist
  if [ $? -eq "0" ]; then 
    echo "--- app 2 PID = $pid begin kill -9 $pid  ---"
    kill -9  $pid
    sleep 2
    echo "--- $JAR_NAME process stopped ---"  
  else
    echo "--- ${JAR_NAME} is not running ---"
  fi  
}

#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "--- ${JAR_NAME} is running PID is ${pid} ---"
  else
    echo "--- ${JAR_NAME} is not running ---"
  fi
}

dump(){
  is_exist
  if [ $? -eq "0" ]; then 
    echo -e "Dumping the $JAR_NAME ...\c"
    do_dump
  else 
    echo "--- ${JAR_NAME} is not running ---"
   fi
 }

#重启
restart(){
  stop
  start
}

do_dump(){
    jstack $pid > $DATE_DIR/jstack-$pid.dump 2>&1
    echo -e ".\c"
    jinfo $pid > $DATE_DIR/jinfo-$pid.dump 2>&1
    echo -e ".\c"
    jstat -gcutil $pid > $DATE_DIR/jstat-gcutil-$pid.dump 2>&1
    echo -e ".\c"
    jstat -gccapacity $pid > $DATE_DIR/jstat-gccapacity-$pid.dump 2>&1
    echo -e ".\c"
    jmap $pid > $DATE_DIR/jmap-$pid.dump 2>&1
    echo -e ".\c"
    jmap -heap $pid > $DATE_DIR/jmap-heap-$pid.dump 2>&1
    echo -e ".\c"
    jmap -histo $pid > $DATE_DIR/jmap-histo-$pid.dump 2>&1
    echo -e ".\c"
    jmap -dump:format=b,file=jmap-dump-$pid.bin $pid
    echo -e ".\c"
    if [ -r /usr/sbin/lsof ]; then
    /usr/sbin/lsof -p $pid > $DATE_DIR/lsof-$pid.dump
    echo -e ".\c"
    fi

    if [ -r /bin/netstat ]; then
    /bin/netstat -an > $DATE_DIR/netstat.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/iostat ]; then
    /usr/bin/iostat > $DATE_DIR/iostat.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/mpstat ]; then
    /usr/bin/mpstat > $DATE_DIR/mpstat.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/vmstat ]; then
    /usr/bin/vmstat > $DATE_DIR/vmstat.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/free ]; then
    /usr/bin/free -t > $DATE_DIR/free.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/sar ]; then
    /usr/bin/sar > $DATE_DIR/sar.dump 2>&1
    echo -e ".\c"
    fi
    if [ -r /usr/bin/uptime ]; then
    /usr/bin/uptime > $DATE_DIR/uptime.dump 2>&1
    echo -e ".\c"
    fi

    echo "OK!"
    echo "DUMP: $DATE_DIR"
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "status")
    status
    ;;
  "restart")
    restart
    ;;
  "dump")
    dump
  ;;
  *)
    usage
    ;;
esac
exit 0
```

