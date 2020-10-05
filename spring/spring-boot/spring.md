## Spring 原理

### 请求参数转换

```java
// 不加 convert 转换，只有 sexDTO=BOY 的时候才可以转换成功，否则会报错
@GetMapping(value = "/convert")
public String convert(QuerySexDTO request){
    System.out.println(sexDTO);
    return "success";
}

@Getter
@ToString
public enum SexDTO {

    BOY(1),Girl(2);

    private Integer code;
    SexDTO(Integer code){
        this.code=code;
    }
}

@Data
public class QuerySexDTO {
    private SexDTO sexDTO;
}
```

[工厂模式参数转换](https://github.com/wanguzhang/fly-springboot/tree/master/spring-interface/src/main/java/com/fly/spring/convert)



### 循环依赖

```text
基于构造函数的的注入不能解决循环依赖.
@Component
public class ServiceB {
//    @Autowired
    private ServiceA serviceA;

    @Autowired
    public ServiceB(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}

基于属性 Field 的循环依赖可以调节.
Spring 只解决 scope 为 singleton 的循环依赖
```

### spring 父子上下文
```text
通过父子上下文，隔离bean
```

### 排除注解扫描的类
```java
// 排除自定义注解标记的类
@ComponentScan(excludeFilters = { @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = Avoid.class)})
```

### 接口返回改变状态码

```java
// ResponseEntity 也可以让它作为返回值
@GetMapping("test2")
@ResponseStatus(HttpStatus.CREATED)
public RetUtil<UserDemo> test2(@Valid UserDemo userDemo) {
    return RetUtil.success(userDemo);
}
```

### Bean 的装配
- 使用 @Component 派生别的注解
- 使用 @import 导入配置类，或实现了 ImportSelector的类
- SpringFactoriesLoader 加载类添加到 ApplicationContext

### Spring Bean 初始化
`类构造方法`->`Aware 接口方法`->`@PostConstruct`->`InitializingBean.afterPropertiesSet`->`BeanPostProcessor.postProcessBeforeInitialization` ->`BeanPostProcessor.postProcessAfterInitialization` ->`@PreDestroy 标记的方法`->`DisposableBean.destroy`

### SpringBoot 结合 IDEA 切换激活环境 

![Spring Bean 加载](http://oss.mflyyou.cn/blog/20201005232353.png?author=zhangpanqin)

### SpringBoot 初始化 Servlet
```java
没有使用 spi 加载 ServletContainerInitializer 实现类
TomcatStarter 主要逻辑，实现 ServletContextInitializer 可扩展
```

### SpringBoot 集成 Tomcat 
```java
ServletWebServerFactoryAutoConfiguration
```
![配置环切换](http://oss.mflyyou.cn/blog/20201005232358.png?author=zhangpanqin)

### 打包

[maven-assembly-plugin 打包](http://springcloud.cn/view/423)

### 零拷贝技术
![](http://oss.mflyyou.cn/blog/20201005232406.jpg?author=zhangpanqin)
```text
零拷贝:通常是指计算机在网络上发送文件时，不需要将文件内容拷贝到用户空间（User Space）而直接在内核空间（Kernel Space）中传输到网络的方式。
零拷贝只是为了减少CPU的占用，让CPU做更多真正业务上的事.
在Java中依靠MappedByteBuffer进行mmap映射
```

### Aop

```
AbstractPointcutAdvisor
```

- Pointcut
- Advice



### Ioc 

设计就是将 bean 储存在 map 中。

每个 bean 都会有其 BeanDefinition 描述信息，类似于 java 中 Class 类对类描述。

根据 BeanDefinition 创建 bean。


BeanDefinitionRegistry 可以注册 BeanDefinition。



```java
// 实现这个 BeanDefinitionRegistryPostProcessor 接口，可以自定义一些 BeanDefinition 注入到 BeanFactory 中去。
@Component
public class MyBeanDefinitionRegistryPostProcessor implements BeanDefinitionRegistryPostProcessor {
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
       // -----org.springframework.beans.factory.support.DefaultListableBeanFactory
        System.out.println("-----"+registry);
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        // -----org.springframework.beans.factory.support.DefaultListableBeanFactory
        System.out.println("-----"+beanFactory);
    }
}
```



AbstractApplicationContext.refresh 处理创建逻辑。


AnnotationConfigServletWebServerApplicationContext 私有属性 beanFactory （DefaultListableBeanFactory）



```java
BeanFactoryPostProcessor 的执行时机，在所有的 bean 的 BeanDefinition 定义之后，bean 初始化之前 执行。
```