### RocketMq 架构

![image-20200209075603500](http://oss.mflyyou.cn/blog/20201005231811.png?author=zhangpanqin)

Broker 中 Topic 主题中，默认配置 四个队列。发送的消息会返回在那个队列。

### 消息类型

- 普通消息
- 有序消息
- 延时消息
- 事务消息

### 生产者发送方式

- 同步发送（sysnc）
- 异步发送（async）
- 单向消息（OneWay）

### 消费者拉取方式

- Pull

```txt
消费者主动去 Broker 拉取消息
```

- Push

```txt
生产者推送消息到 Broker , Broker 主动告知消费者
```

### 事务消息

![](http://oss.mflyyou.cn/blog/20201005231820.jpg?author=zhangpanqin)

### 消息存储

![image-20200209092617563](http://oss.mflyyou.cn/blog/20201005231825.png?author=zhangpanqin)

![image-20200209093320316](http://oss.mflyyou.cn/blog/20201005231834.png?author=zhangpanqin)
![image-20200209093320316](pic/消息存储.jpg)
![image-20200209093320316](http://oss.mflyyou.cn/blog/20201005231839.jpg?author=zhangpanqin)

 