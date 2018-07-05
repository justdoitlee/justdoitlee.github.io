---
title: 系统学习Spring（一）
date: 2017-05-09 16:57:59
categories: Java二三事
tags:
	- Spring
	- 框架
---
对于Java开发者来说，这是一个好的时代。<!--more-->

在过去的20年中，Java经历了好的时候，也经历了坏的时候。尽管有一些粗糙的地方，比如：Applets、 
EJB、JDO和无数的日志框架，Java有丰富多样的历史，有很多企业已经建立的平台。其中，spring一直 
都是其中最重要的组成部分。

在早期，Spring被创建用于替代笨重的Java企业技术，比如EJB。相比于EJB，Spring提供了一个更加精 
简的编程模型。它提供了简单Java对象（POJO）更大的权力，相对于EJB及其他Java企业规范。

随着时间的推移，EJB及Java企业规范2.0版本本身也提供了一个简单的POJO模型。现在，EJB的一些概 
念，如DI和AOP都来自于Spring。

尽管现在J2EE（即总所周知的JEE）能够赶上Spring，但是Spring从未停止演进。即使是现在，Spring开始进步的时候， 
J2EE都是开始在探索，而不是创新。移动开发、社交API的集成、NoSql数据库、云计算和大数据，仅仅是Spring创新 
的一些方面。而且未来，Spring会继续发展。

就像我说的，对于Java程序员来说，这是一个好的时代。 
																
**摘自《Spring实战》**

顾名思义，Spring就是为了简化我们Java开发而来的，而Spring主要还是围绕着两个点：一个DI（依赖注入），一个AOP（面向切面），或者说IOC（控制反转）和AOP（面向切面）。

>IOC主要的实现方式有两种：依赖查找，依赖注入
依赖注入是一种更可取的方式

<h2>依赖注入——Injecting Dependencies</h2>
刚接触时，DI这个词刚听起来觉得是害怕的，它可能是相当复杂的编程技术或者设计模式。但事实证明，DI一点都不像 ，它听起来那么难。通过在应用中使用DI，你会发现你的应用程序变淡简单、容易理解并且易于测试。
那么DI是怎么工作的呢？一个正常的应用程序都是有两个或者更多个相互协作的类组合起来的。传统上，每个对象都会保存它所以来的对象的引用。这个会导致高度耦合并且难于测试。

例如：
```
package knights;

public class DamselRescuingKnight implements Knight{
    private RescueDamselQuest quest;

    public DamselRescuingKnight(){
        this.quest = new RescueDamselQuest();
    }
    public void embarkOnQuest(){
        quest.embark();
    }
}
```
如上所示，骑士创建了一个少女需要营救的请求（RescueDamselQuest）在它自己的构造函数中。这个会使骑士与少女请求绑定到一起，这严重限制了骑士的能力。如果一个少女需要营救，那没有问题。但是如果一头巨龙需要被杀死，那么骑士什么都做不了，只能坐在旁边观看。

所以耦合是一个特别难以拓展的问题，一方面，耦合的代码难于测试、难于重用、难以理解并且他经常导致“打地鼠”的Bug行为（一种修改一个Bug通常会引起其他新的一个甚至更多的新bug的行为）。另一方面，一定数量的耦合代码是必须的，完全不耦合的代码将什么事情都不做。为了去做一些有用的事情，类需要知道彼此。耦合是必须的，但是必须被小心的管理。

因此使用DI，对象在创建的时候被一些确定系统对象坐标的第三方去给予出其依赖，对象不需要去创建或者获取其依赖，像下图描述的那样，依赖被注入进了需要他们的对象。

所以针对上面的问题，我们修改了代码：
```
//一个灵活的骑士

package knights;

public class BraveKnight implements Knight {
    private Quest quest;

    public BraveKnight(Quest quest) {
        this.quest = quest;
    }

    @Override
    public void embarkOnQuest() {
        quest.embark();
    }
}
```
就像在上面看到的一样，BraveKnight不像DamselRescuingKnight 一样创建自己的Quest，而是在构造函数的参数中传入Quest，这样的DI就是著名的构造函数注入（Constructor injection）。

更重要的是，那个Quest只是一个接口，所有实现该接口的实现都可以传入。所以BraveKnight可以处理不同的 需求。

关键点就是BraveKnight没有跟任何特定的Quest进行绑定。它不在乎是什么样的请求，只要该请求实现了Quest接口就可以。这个就是DI的好处–松耦合。如果一个对象的依赖只是一个接口，那么你可以将他的实 现从一个换成另外一个。

既然你BraveKnight对象可以处理任何你想传递给他的Quest对象，假设你想传递一个杀死巨龙的Quest，那么 你可以传递一个SlayDragonQuest给他是合适的。
```
public class SlayDragonQuest implements Quest {
    private PrintStream stream;

    public SlayDragonQuest(PrintStream stream) {
        this.stream = stream;
    }

    @Override
    public void embark() {
        stream.println("Embarking on quest to slay the dragon");
    }
}
```

就像你所看到的一样，SlayDragonQuest实现了Quest接口，使得它适合BraveKnight。

应用组件之间创建关联的行为通常称为布线或者装配（wiring）。在Spring中，组件之间的装配方式有很多种，但是一个通常的方式是使用XML。接下来的清单展示了一个简单的Spring配置文件–knights.xml，它将一个SlayDragonQuest、BraveKnight和一个PrintStream装配起来。

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="knight" class="com.springinaction.knights.BraveKnight">
        <!--quest注入quest的Bean-->
        <constructor-arg ref="quest"/>
    </bean>
    <!--创建Quest-->
    <bean id="quest" class="com.springinaction.knights.SlayDragonQuest">
        <constructor-arg value="#{$(System).out}"/>
    </bean>
</beans>
```

这里，BraveKnight和SlayDragonQuest被声明为Bean，在BraveKnight Bean中，通过传递一个Quest的引用作为构造函数的参数。同时，SlayDragonQuest使用Spring表达式语言传递一个System.out的构造函数参数给SlayDragonQuest对象。如果XML配置文件不适合你的口味，你可以使用Java方式进行配置。如下：
```
@Configuration
public class KnightConfig {
    @Bean
    public Knight knight() {
        return new BraveKnight(quest());
    }

    @Bean
    public Quest quest() {
        return new SlayDragonQuest(System.out);
    }
}
```

不管使用xml还是java，依赖注入的好处都是一样的。尽管BraveKnight依赖Quest，但是它不需要知道具体是什么Quest，同样的SlayDragonQuest也不需要知道具体的PrintStream类型。在Spring中，仅仅通过配置使得所有的片段组装在一起。这个就使得可以去改变他们之间的依赖关系而不需要去修改类的实现。

<h2>AOP——Aspect-OrientedProgramming</h2>
虽然DI可以使得你的应用程序组件之间是松耦合的，但是AOP可以使得你可以在你应用程序中去捕获Bean的功能。

AOP通常被定义为分离软件关注点的一种技术。系统通常由一些具有特定功能的组件组成。但是，通常这些组件也附带一些除了核心功能之外的一些功能。系统服务，如日志记录、事务管理和安全性，通常会在每个组件中都是需要的。这些系统服务通常被称为横切关注点（cross-cutting concerns），因为他们会在系统中切割多个组件。

通过传递这些横切关注点，你会提供你应用程序的复杂性：

<li>代码重复。这就意味着你如果修改其中一个功能，你修改需要许多的组件。即使你把关注点抽象为一个单独的模块，这样对你组件的影响是一个单一的方法，该方法调用也会在多个地方重复。
<li>你的组件中充斥这与它核心功能不一致的代码。如添加一个条目到一个地址簿中，我们应该只关心如何添加地址，而不是关心是否安全或者是否具有事务一致性。

AOP可以模块化这些服务，并且通过声明式的方式应用这些服务，这将导致组件更加具有凝聚力，并且组件专注于自己特定的功能，对可能涉及的系统服务完全不知情。简单来说，就是让POJO始终保持扁平。

下面一个例子来演示分离核心功能与系统服务：
```
public class Minstrel {
    private PrintStream stream;

    public Minstrel(PrintStream stream) {
        this.stream = stream;
    }

    //called before quest
    public void singleBeforeQuest() {
        stream.println("Fa la la, the knight is so brave");
    }

    //called after quest
    public void singleAfterQuest() {
        stream.println("Tee hee hee, the brave knight did embark on a quest");
    }
}
```

就像你看到的一样，Minstrel是一个包含两个方法的简单对象，这是简单的，将这个注入进我们之前的代码，如下所示：
```
public class BraveKnight implements Knight {
    private Quest quest;
    private Minstrel minstrel;

    public BraveKnight(Quest quest, Minstrel minstrel) {
        this.quest = quest;
        this.minstrel = minstrel;
    }

    public void embarkOnQuest() {
        minstrel.singleBeforeQuest();
        quest.embark();
        minstrel.singleAfterQuest();
    }
}
```

现在，你需要做的就是在Spring的配置文件中加入Ministrel的构造函数参数。但是，等等….

好像看起来不对，这个真的是骑士本身关注的吗？骑士应该不必要做这个工作。毕竟，这是一个歌手的工作，歌颂骑士的努力，为什么其实一直在提醒歌手呢？

另外，由于骑士必须知道歌手，你被迫传递歌手给骑士，这个不仅使骑士的代码复杂，而且让我很困惑，当我需要一个骑士而没有一个歌手的时候，如果Ministrel为null，在代码中还得进行非空判断，简单的BraveKnight代码开始变得复杂。但是使用AOP，你可以宣布歌手必须歌唱骑士的任务，并且，释放骑士，直接处理歌手的方法。

在Spring配置文件中，你需要做的就是将歌手声明为一个切面。如下：
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/aop
       http://www.springframework.org/schema/aop/spring-aop.xsd">
    <bean id="knight" class="com.springinaction.knights.BraveKnight">
        <!--quest注入quest的Bean-->
        <constructor-arg ref="quest"/>
    </bean>
    <!--创建Quest-->
    <bean id="quest" class="com.springinaction.knights.SlayDragonQuest">
        <constructor-arg value="#{T(System).out}"/>
    </bean>

    <!--定义歌手的Bean-->
    <bean id="ministrel" class="com.springinaction.knights.Minstrel">
        <constructor-arg value="#{T(System).out}"/>
    </bean>

    <aop:config>
        <aop:aspect ref="ministrel">
            <!--定义切点-->
            <aop:pointcut id="embark" expression="execution(* *.embarkOnQuest(..))"/>
            <!--定义前置通知-->
            <aop:before pointcut-ref="embark" method="singleBeforeQuest"/>
            <!--定义后置通知-->
            <aop:after method="singleAfterQuest" pointcut-ref="embark"/>
        </aop:aspect>
    </aop:config>
</beans>
```

使用Spring的AOP配置一个Ministrel作为切面，在切面里面，定义一个切点，然后定义前置通知（before advice）和后置通知（after advice）。在两个例子中，pointcut-ref属性都使用了一个embark的引用，这个切点是通过pointcut元素定义的，它表明通知应该应用在什么地方，表达式的语法遵循AspectJ的切点表达式语法。

首先，Ministrel始终是一个POJO，没有任何说明他是用来作为切面的。作为一个切面是通过Spring配置文件实现的。其次，也是最重要的，Ministrel可以应用到BraveKnight而不需要BraveKnight直接调用它，实际上，BraveKnight根本不知道Ministrel的存在。

需要指出的是，你可以使用Spring的魔法使得Ministrel作为一个切面，但是Ministrel必须首先是一个Spring的Bean，关键的就是你可以使用任何Spring Bean作为切面，而且可以将其注入其他的Bean中。

**这些基础的理论都是从《Spring实战第四版》一书中记录下来的，以后的学习中，将会掺杂以自己视角来写。**

**ps:其实之前有写过Spring的一些理解，但是开发过程中还是发现很多细节都不理解不明白，因为之前Spring的学习都是基于开发过程中边做边学，所以决定从头开始系统的学习。**







