---
title: '@Async异步调用实践'
date: 2020-01-02 15:06:15
categories: Java二三事
tags:
	- Java
	- 多线程
---

异步调用对应的是同步调用，同步调用可以理解为按照定义的顺序依次执行，有序性；异步调用在执行的时候不需要等待上一个指令调用结束就可以继续执行。

我们将在创建一个 Spring Boot 工程来说明。具体工程可以参考github代码 [github](https://github.com/JustDoItLee/demo/tree/master/demo/async)

<!-- more -->

pom 依赖如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.2.2.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.demo.async</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
            <exclusions>
                <exclusion>
                    <groupId>org.junit.vintage</groupId>
                    <artifactId>junit-vintage-engine</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
            <exclusions>
                <exclusion>
                    <artifactId>spring-boot-starter-logging</artifactId>
                    <groupId>org.springframework.boot</groupId>
                </exclusion>
            </exclusions>
        </dependency>
        <!-- logback -->
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-access</artifactId>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
        </dependency>
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-core</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.2</version>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>

```

启动类如下：

```java
@SpringBootApplication
public class AsyncApplication {

    public static void main(String[] args) {
        SpringApplication.run(AsyncApplication.class, args);
    }

}
```

定义线程池

```java
package com.demo.async.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * @classname: AsyncExecutorConfig
 * @description:
 * @author: Ricardo
 * @create: 2020-01-02 15:22
 **/

/**
 * 异步线程池
 */
@Configuration
@EnableAsync
public class AsyncExecutorConfig {

    /**
     * Set the ThreadPoolExecutor's core pool size.
     */
    private int corePoolSize = 8;
    /**
     * Set the ThreadPoolExecutor's maximum pool size.
     */
    private int maxPoolSize = 16;
    /**
     * Set the capacity for the ThreadPoolExecutor's BlockingQueue.
     */
    private int queueCapacity = 200;

    private String threadNamePrefix = "AsyncExecutor-";

    @Bean("taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(corePoolSize);
        executor.setMaxPoolSize(maxPoolSize);
        executor.setQueueCapacity(queueCapacity);
        executor.setKeepAliveSeconds(60);
        executor.setThreadNamePrefix(threadNamePrefix);

        // rejection-policy：当pool已经达到max size的时候，如何处理新任务
        // CALLER_RUNS：不在新线程中执行任务，而是有调用者所在的线程来执行
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

}
```

代码中我们通过 ThreadPoolTaskExecutor 创建了一个线程池。参数含义如下所示：

- corePoolSize：线程池创建的核心线程数
- maxPoolSize：线程池最大线程池数量，当任务数超过corePoolSize以及缓冲队列也满了以后才会申请的线程数量。
- setKeepAliveSeconds： 允许线程空闲时间60秒，当maxPoolSize的线程在空闲时间到达的时候销毁。
- ThreadNamePrefix：线程的前缀任务名字。
- RejectedExecutionHandler：当线程池没有处理能力的时候，该策略会直接在 execute 方法的调用线程中运行被拒绝的任务；如果执行程序已关闭，则会丢弃该任务

 

 使用实战

```java
package com.demo.async.service;

import com.demo.async.task.AsyncTask;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

/**
 * @classname: OrderService
 * @description:
 * @author: Ricardo
 * @create: 2020-01-02 15:24
 **/
@Slf4j
@Service
public class OrderService {
    public static Random random = new Random();


    @Autowired
    private AsyncTask asyncTask;

    public void doShop() {
        try {
            createOrder();
            // 调用有结果返回的异步任务
            Future<String> pay = asyncTask.pay();
            if (pay.isDone()) {
                try {
                    String result = pay.get();
                    log.info("异步任务返回结果{}", result);
                } catch (ExecutionException e) {
                    e.printStackTrace();
                }
                asyncTask.vip();
                asyncTask.sendSms();
            }
            otherJob();
        } catch (InterruptedException e) {
            log.error("异常", e);
        }
    }

    public void createOrder() {
        log.info("开始做任务1：下单成功");
    }

    /**
     * 错误使用，不会异步执行：调用方与被调方不能在同一个类。主要是使用了动态代理，同一个类的时候直接调用，不是通过生成的动态代理类调用
     */
    @Async("taskExecutor")
    public void otherJob() {
        log.info("开始做任务4：物流");
        long start = System.currentTimeMillis();
        try {
            Thread.sleep(random.nextInt(10000));
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        long end = System.currentTimeMillis();
        log.info("完成任务4，耗时：" + (end - start) + "毫秒");
    }

}
```



异步任务服务类

```java
package com.demo.async.task;

import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Component;

import java.util.Random;
import java.util.concurrent.Future;

/**
 * @classname: AsyncTask
 * @description:
 * @author: Ricardo
 * @create: 2020-01-02 15:25
 **/
@Component
@Slf4j
public class AsyncTask {
    public static Random random = new Random();


    @Async("taskExecutor")
    public void sendSms() throws InterruptedException {
        log.info("开始做任务2：发送短信");
        long start = System.currentTimeMillis();
        Thread.sleep(random.nextInt(10000));
        long end = System.currentTimeMillis();
        log.info("完成任务1，耗时：" + (end - start) + "毫秒");
    }

    @Async("taskExecutor")
    public Future<String> pay() throws InterruptedException {
        log.info("开始做异步返回结果任务2：支付");
        long start = System.currentTimeMillis();
        Thread.sleep(random.nextInt(10000));
        long end = System.currentTimeMillis();
        log.info("完成任务2，耗时：" + (end - start) + "毫秒");
        return new AsyncResult<>("会员服务完成");
    }

    /**
     * 返回结果的异步调用
     *
     * @throws InterruptedException
     */
    @Async("taskExecutor")
    public void vip() throws InterruptedException {
        log.info("开始做任务5：会员");
        long start = System.currentTimeMillis();
        Thread.sleep(random.nextInt(10000));
        long end = System.currentTimeMillis();
        log.info("开始做异步返回结果任务5，耗时：" + (end - start) + "毫秒");
    }
}
```



单元测试

```java
package com.demo.async;

import com.demo.async.service.OrderService;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = AsyncApplication.class)
class AsyncApplicationTests {

    @Test
    void contextLoads() {
    }

    @Autowired
    private OrderService orderService;

    @Test
    public void testAsync() {
        orderService.doShop();
        try {
            Thread.currentThread().join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

}
```

结果

```
2020-01-02 15:28:52.392  INFO 35807 --- [           main] com.demo.async.service.OrderService      : 开始做任务1：下单成功
2020-01-02 15:28:52.399  INFO 35807 --- [           main] com.demo.async.service.OrderService      : 开始做任务4：物流
2020-01-02 15:28:52.404  INFO 35807 --- [AsyncExecutor-1] com.demo.async.task.AsyncTask            : 开始做异步返回结果任务2：支付
2020-01-02 15:28:53.420  INFO 35807 --- [           main] com.demo.async.service.OrderService      : 完成任务4，耗时：1020毫秒
2020-01-02 15:28:55.495  INFO 35807 --- [AsyncExecutor-1] com.demo.async.task.AsyncTask            : 完成任务2，耗时：3091毫秒
```

可以看到有的线程的名字就是我们线程池定义的前缀，说明使用了线程池异步执行。其中我们示范了一个错误的使用案例 **otherJob()**，并没有异步执行。

原因：

**spring 在扫描bean的时候会扫描方法上是否包含@Async注解，如果包含，spring会为这个bean动态地生成一个子类（即代理类，proxy），代理类是继承原来那个bean的。此时，当这个有注解的方法被调用的时候，实际上是由代理类来调用的，代理类在调用时增加异步作用。然而，如果这个有注解的方法是被同一个类中的其他方法调用的，那么该方法的调用并没有通过代理类，而是直接通过原来的那个 bean 也就是 this. method，所以就没有增加异步作用，我们看到的现象就是@Async注解无效。**