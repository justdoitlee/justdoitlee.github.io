---
title: 系统学习Spring（二）——装配Bean
date: 2017-05-10 12:42:32
categories: Java二三事
tags:
	- Spring
	- 框架
---
任何一个成功的应用都是由多个为了实现某个业务目标而相互协作的组件构成的，这些组件必须相互了解、能够相互协作完成工作。<!--more-->
例如，在一个在线购物系统中，订单管理组件需要与产品管理组件以及信用卡认证组件协作；这些组件还需要跟数据库组件协作从而进行数据库读写操作。
在Spring应用中，对象无需自己负责查找或者创建与其关联的其他对象，由容器负责将创建各个对象，并创建各个对象之间的依赖关系。
通俗的来说，Spring就是一个工厂，Bean就是Spring工厂的产品，对于Spring工厂能够生产那些产品，这个取决于领导的决策，也就是配置文件中配置。
因此，**对于开发者来说，我们需要关注的只是告诉Spring容器需要创建哪些bean以及如何将各个bean装配到一起**。**对于Spring来说，它要做的就是根据配置文件来创建Bean实例，并调用Bean实例的方法完成“依赖注入”**。

<h2>Bean的定义</h2>
<li>   < beans/>是Sring配置文件的根节点
<li> 一个< beans/>节点里面可以有多个<bean>节点
在定义Bean的时候，通常要指定两个属性：id和class。其中id用来指明bean的标识符，这个标识符具有唯一性，Spring对bean的管理以及bean之间这种依赖关系都需要这个属性；而class指明该bean的具体实现类，这里不能是接口（可以是接口实现类）全路径包名.类名。

```
//一个Bean的配置
    <bean id="bean" class="实现类" />  
```
或者
```
@Component("bean")
public class Bean {
  ...
}
```
当我们用XML配置了这个bean的时候，该bean实现类中必须有一个无参构造器，故Spring底层相当于调用了如下代码：
```
bean = new 实现类（）;
```
如果在bean的配置文件中，通过构造注入如：
```
	<bean id="bean" class="实现类" />  
        <constructor-arg value="bean"/>  
    </bean>  
```
那么Spring相当于调用了
```
	Bean bean = new 实现类（"bean"）;
```
<h2>Spring的配置方法</h2>
Spring容器负责创建应用中的bean，并通过DI维护这些bean之间的协作关系。作为开发人员，你应该负责告诉Spring容器需要创建哪些bean以及如何将各个bean装配到一起。Spring提供三种装配bean的方式：

<li>基于XML文件的显式装配
<li>基于Java文件的显式装配
<li>隐式bean发现机制和自动装配

绝大多数情况下，开发人员可以根据个人品味选择这三种装配方式中的一种。Spring也支持在同一个项目中混合使用不同的装配方式。

《Spring实战》的建议是：尽可能使用自动装配，越少写显式的配置文件越好；当你必须使用显式配置时（例如，你要配置一个bean，但是该bean的源码不是由你维护），尽可能使用类型安全、功能更强大的基于Java文件的装配方式；最后，在某些情况下只有XML文件中才又你需要使用的名字空间时，再选择使用基于XML文件的装配方式。

<h2>自动装配Bean</h2>

Spring通过两个角度来实现自动装配：
<li>组件扫描，Spring会自动发现应用上下文中所创建的bean
<li>自动装配，Spring自动满足bean之间的依赖

《Spring实战》中用了一个例子来说明，假设你需要实现一个音响系统，该系统中包含CDPlayer和CompactDisc两个组件，Spring将自动发现这两个bean，并将CompactDisc的引用注入到CDPlayer中。

首先创建CD的概念——CompactDisc接口，如下所示：
```
package soundsystem;

/**
 * @author 李智
 * @date 2017/5/9
 */
public interface CompactDisc {
    void play();
}

```
CompactDisc接口的作用是将CDPlayer与具体的CD实现解耦合，即面向接口编程。这里还需定义一个具体的CD实现，如下所示：
```
package soundsystem;

import org.springframework.stereotype.Component;

/**
 * @author 李智
 * @date 2017/5/9
 */
@Component
public class SgtPeppers implements CompactDisc {
    private String title = "Sgt.Pepper's Lonely Hearts Club Band";
    private String artist = "The Beatles";

    public void play() {
        System.out.println("Playing" + title + "by" + artist);
    }
}
```
这里最重要的是@Component注解，它告诉Spring需要创建SgtPeppers bean。除此之外，还需要启动自动扫描机制，有两种方法：基于XML配置文件；基于Java配置文件，代码如下（二选一）：
```
//这是XML配置
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="soundsystem"/>
</beans>
```
或
```
//这是Java配置
package soundsystem;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * @author 李智
 * @date 2017/5/9
 */
@Configuration
@ComponentScan()
public class CDPlayerConfig {
}
```
在这个Java配置文件中有两个注解值得注意：@Configuration表示这个.java文件是一个配置文件；@ComponentScan表示开启Component扫描，Spring将会设置该目录以及子目录下所有被@Component注解修饰的类。

自动配置的另一个关键注解是@Autowired，基于之前的两个类和一个Java配置文件，可以写个测试
```
package com.spring.sample.soundsystem;

import com.spring.sample.config.SoundSystemConfig;
import org.junit.Assert;import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author 李智
 * @date 2017/5/9
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = SoundSystemConfig.class)
public class SoundSystemTest {
    @Autowired
    private CompactDisc cd;

    @Test
    public void cdShouldNotBeNull() {
        Assert.assertNotNull(cd);
    }
}
```
运行测试，看到绿色就成功了，说明@Autowired注解起作用了：自动将扫描机制创建的CompactDisc类型的bean注入到SoundSystemTest这个bean中。

这里需要注意两个点，一个是junit需要用高级一点的版本，之前用3.8一直有问题，换成4.12之后就好了；还一个是SpringTest的测试包。
```
<dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.12</version>
      <scope>test</scope>
    </dependency>
    <!-- Sprint-test 相关测试包 -->
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-test</artifactId>
      <version>3.2.11.RELEASE</version>
      <exclusions>
        <exclusion>
          <groupId>org.springframework</groupId>
          <artifactId>spring-core</artifactId>
        </exclusion>
      </exclusions>
      <scope>test</scope>
    </dependency>

```

简单得说，自动装配的意思就是让Spring从应用上下文中找到对应的bean的引用，并将它们注入到指定的bean。通过@Autowired注解可以完成自动装配。

例如，考虑下面代码中的CDPlayer类，它的构造函数被@Autowired修饰，表明当Spring创建CDPlayer的bean时，会给这个构造函数传入一个CompactDisc的bean对应的引用。

```
package soundsystem;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * @author 李智
 * @date 2017/5/9
 */
@Component
public class CDPlayer implements MediaPlay {
    private CompactDisc cd;

    @Autowired
    public CDPlayer(CompactDisc cd) {
        this.cd = cd;
    }

    public void play() {
        cd.play();
    }
}
```
还有别的实现方法，例如将@Autowired注解作用在setCompactDisc()方法上:

```
@Autowired
public void setCd(CompactDisc cd) {
    this.cd = cd;
}
```
或者是其他名字的方法上，例如：
```
@Autowired
public void insertCD(CompactDisc cd) {
    this.cd = cd;
}
```
更简单的用法是，可以将@Autowired注解直接作用在成员变量之上，我们开发一般都是直接这么用的吧，例如：
```
@Autowired
private CompactDisc cd;
```

只要对应类型的bean有且只有一个，则会自动装配到该属性上。如果没有找到对应的bean，应用会抛出对应的异常，如果想避免抛出这个异常，则需要设置**@Autowired(required=false)**。不过，在应用程序设计中，应该谨慎设置这个属性，因为这会使得你必须面对**NullPointerException**的问题。

如果存在多个同一类型的bean，则Spring会抛出异常，表示装配有歧义，解决办法有两个：
（1）通过@Qualifier注解指定需要的bean的ID；
（2）通过@Resource注解指定注入特定ID的bean；

现在我们验证一下上述代码，通过下列代码，可以验证：CompactDisc的bean已经注入到CDPlayer的bean中，同时在测试用例中是将CDPlayer的bean注入到当前测试用例。

```
import static org.junit.Assert.*;

import org.junit.Rule;
import org.junit.Test;
import org.junit.contrib.java.lang.system.StandardOutputStreamLog;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import soundsystem.CDPlayerConfig;
import soundsystem.CompactDisc;
import soundsystem.MediaPlay;

/**
 * @author 李智
 * @date 2017/5/9
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = CDPlayerConfig.class)
//@ContextConfiguration(locations = {"classpath:/applicationContext.xml"})
public class CDPlayerTest {
    @Rule
    public final StandardOutputStreamLog log = new StandardOutputStreamLog();
    @Autowired
    private CompactDisc cd;
    @Autowired
    private MediaPlay player;

    @Test
    public void cdShouldNotBeNull() {
        assertNotNull(cd);
    }

    @Test
    public void play() {
        player.play();
        assertEquals("Playing" + "Sgt.Pepper's Lonely Hearts Club Band" + "by" + "The Beatles\n", log.getLog());
    }
}

```
这里可以使用<code> public final Logger log = LoggerFactory.getLogger(CDPlayerTest.class);</code>来替代<code> public final StandardOutputStreamLog log = new StandardOutputStreamLog();</code>，要使用StandardOutputStreamLog，需要添加Jar包如下：

```
<dependency>
      <groupId>com.github.stefanbirkner</groupId>
      <artifactId>system-rules</artifactId>
      <version>1.16.0</version>
    </dependency>
```

<h2>基于Java配置文件装配Bean</h2>
Java配置文件不同于其他用于实现业务逻辑的Java代码，因此不能将Java配置文件业务逻辑代码混在一起。一般都会给Java配置文件新建一个单独的package，实际上之前就用了Java配置的。

```
@Configuration
@ComponentScan(basePackageClasses = {CDPlayer.class, DVDPlayer.class})
public class SoundSystemConfig {
}
```
@Configuration注解表示这个类是配置类，之前我们是通过@ComponentScan注解实现bean的自动扫描和创建，这里我们重点是学习如何显式创建bean，因此首先将**@ComponentScan(basePackageClasses = {CDPlayer.class, DVDPlayer.class})**这行代码去掉。

我们先通过@Bean注解创建一个Spring bean，该bean的默认ID和函数的方法名相同，即sgtPeppers。例如：

```
@Bean
public CompactDisc sgtPeppers() {
    return new SgtPeppers();
}
//或注明id
@Bean(name = "lonelyHeartsClub")
public CompactDisc sgtPeppers() {
    return new SgtPeppers();
}

```
可以利用Java语言的表达能力，实现类似工厂模式的代码如下：

```
@Bean
public CompactDisc randomBeatlesCD() {
    int choice = (int)Math.floor(Math.random() * 4);

    if (choice == 0) {
        return new SgtPeppers();
    } else if (choice == 1) {
        return new WhiteAlbum();
    } else if (choice == 2) {
        return new HardDaysNight();
    } else if (choice == 3) {
        return new Revolover();
    }
}
```
然后在JavaConfig中的属性注入：

```
@Bean
public CDPlayer cdPlayer() {
    return new CDPlayer(sgtPeppers());
}
```
看起来是函数调用，实际上不是：由于sgtPeppers()方法被@Bean注解修饰，所以Spring会拦截这个函数调用，并返回之前已经创建好的bean——确保该SgtPeppers bean为单例。

```
@Bean
public CDPlayer cdPlayer() {
    return new CDPlayer(sgtPeppers());
}

@Bean
public CDPlayer anotherCDPlayer() {
    return new CDPlayer(sgtPeppers());
}
```
如上代码所示：如果把sgtPeppers()方法当作普通Java方法对待，则cdPlayerbean和anotherCDPlayerbean会持有不同的SgtPeppers实例——结合CDPlayer的业务场景看：就相当于将一片CD同时装入两个CD播放机中，显然这不可能。

默认情况下，Spring中所有的bean都是单例模式，因此cdPlayer和anotherCDPlayer这俩bean持有相同的SgtPeppers实例。

当然，还有一种更清楚的写法：

```
@Bean
public CDPlayer cdPlayer(CompactDisc compactDisc) {
    return new CDPlayer(compactDisc);
}

@Bean
public CDPlayer anotherCDPlayer() {
    return new CDPlayer(sgtPeppers());
}
```
这种情况下，cdPlayer和anotherCDPlayer这俩bean持有相同的SgtPeppers实例，该实例的ID为lonelyHeartsClub。这种方法最值得使用，因为它不要求CompactDisc bean在同一个配置文件中定义——只要在应用上下文容器中即可（不管是基于自动扫描发现还是基于XML配置文件定义）。

<h2>基于XML的配置方法</h2>
在之前Bean的定义有提到过，这里就不复述了。

<h2>混合使用多种配置方法</h2>
之前有提到过，开发过程中也可能使用混合配置，首先明确一点：对于自动配置，它从整个容器上下文中查找合适的bean，无论这个bean是来自JavaConfig还是XML配置。

**在JavaConfig中解析XML配置**

```
//通过@Import注解导入其他的JavaConfig，并且支持同时导入多个配置文件；
@Configuration
@Import({CDPlayerConfig.class, CDConfig.class})
public class SoundSystemConfig {
}

//通过@ImportResource注解导入XML配置文件；
@Configuration
@Import(CDPlayerConfig.class)
@ImportResource("classpath: cd-config.xml")
public class SoundSystemConfig {
}
```
**在XML配置文件中应用JavaConfig**

```
//通过<import>标签引入其他的XML配置文件；
//通过<bean>标签导入Java配置文件到XML配置文件，例如
<bean class="soundsystem.CDConfig" />
```
通常的做法是：无论使用JavaConfig或者XML装配，都要创建一个root configuration，即模块化配置定义；并且在这个配置文件中开启自动扫描机制：<context:component-scan>或者@ComponentScan。

<h2>总结</h2>

由于自动装配几乎不需要手动定义bean，建议优先选择自动装配；如何必须使用显式配置，则优先选择基于Java文件装配这种方式，因为相比于XML文件，Java文件具备更多的能力、类型安全等特点；但是也有一种情况必须使用XML配置文件，即你需要使用某个名字空间（name space），该名字空间只在XML文件中可以使用。

ps:上述例子都是直接用的《Spring实战》