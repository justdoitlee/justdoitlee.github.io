---
title: 系统学习Spring(三)——Bean的高级装配
date: 2017-05-15 16:50:55
categories: Java二三事
tags:
	- Spring
	- 框架
---
在软件开发中，常常设置不同的运行环境：开发环境、预发环境、性能测试环境和生产环境等等。

不同的环境下，应用程序的配置项也不同，例如数据库配置、远程服务地址等。<!--more-->以数据库配置为例子，在开发环境中你可能使用一个嵌入式的内存数据库，并将测试数据放在一个脚本文件中。例如，在一个Spring的配置类中，可能需要定义如下的bean：

```
@Bean(destroyMethod = "shutdown")
public DataSource dataSource() {
    return new EmbeddedDatabaseBuilder()
            .addScript("classpath:schema.sql")
            .addScript("classpath:test-data.sql")
            .build();
}
```
使用EmbeddedDatabaseBuilder这个构建器可以建立一个内存数据库，通过指定路径下的schema.sql文件中的内容可以建立数据库的表定义，通过test-data.sql可以准备好测试数据。

开发环境下可以这么用，但是在生产环境下不可以。在生产环境下，你可能需要从容器中使用JNDI获取DataSource对象，这中情况下，对应的创建代码是：

```
@Bean
public DataSource dataSource() {
    JndiObjectFactoryBean jndiObjectFactoryBean =
             new JndiObjectFactoryBean();
    jndiObjectFactoryBean.setJndiName("jdbc/myDS");
    jndiObjectFactoryBean.setResourceRef(true);
    jndiObjectFactoryBean.setProxyInterface(javax.sql.DataSource.class);
    return (DataSource) jndiObjectFactoryBean.getObject();
}
```
使用JNDI管理DataSource对象，很适合生产环境，但是对于日常开发环境来说太复杂了。

另外，在QA环境下你也可以选择另外一种DataSource配置，可以选择使用普通的DBCP连接池，例如：

```
@Bean(destroyMethod = "close")
public DataSource dataSource() {
    BasicDataSource dataSource = new BasicDataSource();
    dataSource.setUrl("jdbc:h2:tcp://dbserver/~/test");
    dataSource.setDriverClassName("org.h2.Driver");
    dataSource.setUsername("sa");
    dataSource.setPassword("password");
    dataSource.setInitialSize(20);
    dataSource.setMaxActive(30);
    return dataSource;
}

```
上述三种办法可以为不同环境创建各自需要的javax.sql.DataSource实例，这个例子很适合介绍不同环境下创建bean，那么有没有一种办法：只需要打包应用一次，然后部署到不同的开发环境下就会自动选择不同的bean创建策略。一种方法是创建三个独立的配置文件，然后利用Maven profiles的预编译命令处理在特定的环境下打包哪个配置文件到最终的应用中。这种解决方法有一个问题，即在切换到不同环境时，需要重新构建应用——从开发环境到测试环境没有问题，但是从测试环境到生产环境也需要重新构建则可能引入一定风险。

Spring提供了对应的方法，使得在环境切换时不需要重新构建整个应用。

<h2>配置profile beans</h2>
Spring提供的方法不是在构件时针对不同的环境决策，而是在运行时，这样，一个应用只需要构建一次，就可以在开发、QA和生产环境运行。

在Spring 3.1之中，可以使用@Profile注解来修饰JavaConfig类，当某个环境对应的profile被激活时，就使用对应环境下的配置类。

在Spring3.2之后，则可以在函数级别使用@Profile注解（是的，跟@Bean注解同时作用在函数上），这样就可以将各个环境的下的bean定义都放在同一个配置类中，还是以之前的例子：

利用注解配置

```
package com.spring.sample.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType;
import org.springframework.jndi.JndiObjectFactoryBean;
import javax.sql.DataSource;

@Configuration
public class DataSourceConfig {
    @Bean(destroyMethod = "shutdown")
    @Profile("dev")
    public DataSource embeddedDataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .addScript("classpath:schema.sql")
                .addScript("classpath:test-data.sql")
                .build();
    }
    @Bean
    @Profile("prod")
    public DataSource dataSource() {
        JndiObjectFactoryBean jndiObjectFactoryBean =
                new JndiObjectFactoryBean();
        jndiObjectFactoryBean.setJndiName("jdbc/myDS");
        jndiObjectFactoryBean.setResourceRef(true); 
        jndiObjectFactoryBean.setProxyInterface(javax.sql.DataSource.class);
        return (DataSource) jndiObjectFactoryBean.getObject();
    }
}
```
除了被@Profile修饰的其他bean，无论在什么开发环境下都会被创建。

利用XML文件配置

和在JavaConfig的用法一样，可以从文件级别定义环境信息，也可以将各个环境的bean放在一个XML配置文件中。

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:jdbc="http://www.springframework.org/schema/jdbc"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:jee="http://www.springframework.org/schema/jee"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/jdbc http://www.springframework.org/schema/jdbc/spring-jdbc.xsd">

       <beans profile="dev">
              <jdbc:embedded-database id="dataSource">
                     <jdbc:script location="classpath:schema.sql"/>
                     <jdbc:script location="classpath:test-data.sql"/>
              </jdbc:embedded-database>
       </beans>

       <beans profile="qa">
              <bean id="dataSource"
                    class="org.apache.commons.dbcp.BasicDataSource"
                    destroy-method="close"
                    p:url="jdbc:h2:tcp://dbserver/~/test"
                    p:driverClassName="org.h2.Driver"
                    p:username="sa"
                    p:password="password"
                    p:initialSize="20"
                    p:maxActive="30" />
       </beans>

       <beans profile="prod">
              <jee:jndi-lookup id="dataSource"
                               jndi-name="jdbc/MyDatabase"
                               resource-ref="true"
                               proxy-interface="javax.sql.DataSource"/>
       </beans>
</beans>
```
上述三个javax.sql.DataSource的bean，ID都是dataSource，但是在运行的时候只会创建一个bean。

<h2>激活profiles</h2>
Spring提供了spring.profiles.active和spring.profiles.default这两个配置项定义激活哪个profile。如果应用中设置了spring.profiles.active选项，则Spring根据该配置项的值激活对应的profile，如果没有设置spring.profiles.active，则Spring会再查看spring.profiles.default这个配置项的值，如果这两个变量都没有设置，则Spring只会创建没有被profile修饰的bean。

有下列几种方法设置上述两个变量的值：
<li>DispatcherServlet的初始化参数
<li>web应用的上下文参数(context parameters)
<li>JNDI项
<li>环境变量
<li>JVM系统属性
<li>在集成测试类上使用@ActiveProfiles注解

开发人员可以按自己的需求设置spring.profiles.active和spring.profiles.default这两个属性的组合。

我推荐在web应用的web.xml文件中设置spring.profiles.default属性——通过设置DispatcherServlet的初始参数和<context-param>标签。

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath*:applicationContext.xml</param-value>
  </context-param>

    <context-param>
        <param-name>spring.profiles.default</param-name>
        <param-value>dev</param-value>
    </context-param>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <servlet>
        <servlet-name>appServletName</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>        <init-param>
            <param-name>spring.profiles.default</param-name>
            <param-value>dev</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>appServletName</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```
按照上述方法设置spring.profiles.default属性，任何开发人员只需要下载源码就可以在开发环境中运行程序以及测试。

然后，当应用需要进入QA、生产环境时，负责部署的开发者只需要通过系统属性、环境变量或者JNDI等方法设置spring.profiles.active属性即可，因为spring.profiles.active优先级更高。

另外，在运行集成测试时，可能希望运行跟生产环境下相同的配置；但是，如果配置重需要的beans被profiles修饰的，则需要在跑单元测试之前激活对应的profiles。

Spring提供了@ActiveProfiles注解来激活指定的profiles，用法如下：

<h2>Conditional beans</h2>
假设你希望只有在项目中引入特定的依赖库时、或者只有当特定的bean已经被创建时、或者是设置了某个环境变量时，某个bean才被创建。

Spring 4之前很难实现这种需求，不过在Spring 4中提出了一个新的注解——@Conditional，该注解作用于@Bean注解修饰的方法上，通过判断指定的条件是否满足来决定是否创建该bean。

举个例子，工程中有一个MagicBean，你希望只有当magic环境变量被赋值时才创建MagicBean，否则该Bean的创建函数被忽略。

```
@Bean
@Conditional(MagicExistsCondition.class)
public MagicBean magicBean() {
    return new MagicBean();
}
```
这个例子表示：只有当MagicExistsCondition类已经存在时，才会创建MagicBean。

@Conditional注解的源码列举如下：

```
package org.springframework.context.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.context.annotation.Condition;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD})
public @interface Conditional {
    Class<? extends Condition>[] value();
}
```
可以看出，传入@Conditional注解的类一定要实现Condition接口，该接口提供matchs()方法——如果matches()方法返回true，则被@Conditional注解修饰的bean就会创建，否则对应的bean不会创建。

在这个例子中，MagicExistsCondition类应该实现Condition接口，并在matches()方法中实现具体的判断条件，代码如下所示：

```
package com.spring.sample.config;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;

public class MagicExistsCondition implements Condition {
    public boolean matches(ConditionContext conditionContext, AnnotatedTypeMetadata annotatedTypeMetadata) {
        Environment env = conditionContext.getEnvironment();
        return env.containsProperty("magic"); //检查magic环境变量是否被设置
    }
}
```
上述代码中的matchs()方法简单且有效：它首先获取环境变量，然后再判断环境变量中是否存在magic属性。在这个例子中，magic的值是多少并不重要，它只要存在就好。

MagicExistsCondition的matchs()方法是通过ConditionContext获取了环境实例。matchs()方法的参数有两个：ConditionContext和AnnotatedTypeMetadata，分别看下这两个接口的源码：

```
//ConditionContext
public interface ConditionContext {
    BeanDefinitionRegistry getRegistry();
    ConfigurableListableBeanFactory getBeanFactory();
    Environment getEnvironment();
    ResourceLoader getResourceLoader();
    ClassLoader getClassLoader();
}
```
利用ConditionContext接口可做的事情很多，列举如下：

<li>通过getRegistry()方法返回的BeanDefinitionRegistry实例，可以检查bean的定义；
<li>通过getBeanFactory()方法返回的ConfigurableListableBeanFactory实例，可以检查某个bean是否存在于应用上下文中，还可以获得该bean的属性；
<li>通过getEnvironment()方法返回的Environment实例，可以检查指定环境变量是否被设置，还可以获得该环境变量的值；
<li>通过getResourceLoader()方法返回的ResourceLoader实例，可以得到应用加载的资源包含的内容；
<li>通过getClassLoader()方法返回的ClassLoader实例，可以检查某个类是否存在。

```
//AnnotatedTypeMetadata
public interface AnnotatedTypeMetadata {
    boolean isAnnotated(String var1);
    Map<String, Object> getAnnotationAttributes(String var1);
    Map<String, Object> getAnnotationAttributes(String var1, boolean var2);
    MultiValueMap<String, Object> getAllAnnotationAttributes(String var1);
    MultiValueMap<String, Object> getAllAnnotationAttributes(String var1, boolean var2);
}

```

通过isAnnotated()方法可以检查@Bean方法是否被指定的注解类型修饰；通过其他方法可以获得修饰@Bean方法的注解的属性。

从Spring 4开始，@Profile注解也利用@Conditional注解和Condition接口进行了重构。作为分析@Conditional注解和Condition接口的另一个例子，我们可以看下在Spring 4中@Profile注解的实现。

```
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD})
@Documented
@Conditional({ProfileCondition.class})
public @interface Profile {
    String[] value();
}
```
可以看出，@Profile注解的实现被@Conditional注解修饰，并且依赖于ProfileCondition类——该类是Condition接口的实现。如下列代码所示，ProfileCondition利用ConditionContext和AnnotatedTypeMetadata两个接口提供的方法进行决策。

```
class ProfileCondition implements Condition {
    ProfileCondition() {
    }

    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        if(context.getEnvironment() != null) {
            MultiValueMap attrs = metadata.getAllAnnotationAttributes(Profile.class.getName());
            if(attrs != null) {
                Iterator var4 = ((List)attrs.get("value")).iterator();

                Object value;
                do {
                    if(!var4.hasNext()) {
                        return false;
                    }
                    value = var4.next();
                } while(!context.getEnvironment().acceptsProfiles((String[])((String[])value)));

                return true;//传给@Profile注解的参数对应的环境profiles已激活
            }
        }

        return true; //默认为true
    }
}

```
可以看出，这代码写得不太好理解:ProfileCondition通过AnnotatedTypeMetadata实例获取与@Profile注解相关的所有注解属性；然后检查每个属性的值（存放在value实例中），对应的profiles别激活——即context.getEnvironment().acceptsProfiles(((String[]) value))的返回值是true，则matchs()方法返回true。

Environment类提供了可以检查profiles的相关方法，用于检查哪个profile被激活：

<li>String[] getActiveProfiles()——返回被激活的profiles数组；
<li>String[] getDefaultProfiles()——返回默认的profiles数组；
<li>boolean acceptsProfiles(String... profiles)——如果某个profiles被激活，则返回true。

<h2>处理自动装配的歧义</h2>
在一文中介绍了如何通过自动装配让Spring自动简历bean之间的依赖关系——自动装配非常有用，通过自动装配可以减少大量显式配置代码。不过，自动装配（autowiring）要求bean的匹配具备唯一性，否则就会产生歧义，从而抛出异常。

举个例子说明自动装配的歧义性，假设你有如下自动装配的代码：

```
@Autowired
public void setDessert(Dessert dessert) {
    this.dessert = dessert;
}
```
Dessert是一个接口，有三个对应的实现：

```
@Component
public class Cake implements Dessert { ... }
@Component
public class Cookies implements Dessert { ... }
@Component
public class IceCream implements Dessert { ... }
```
因为上述三个类都被@Component注解修饰，因此都会被component-scanning发现并在应用上下文中创建类型为Dessert的bean；然后，当Spring试图为setDessert()方法装配对应的Dessert参数时，就会面临多个选择；然后Spring就会抛出异常——NoUniqueBeanDefinitionException。

虽然在实际开发中并不会经常遇到这种歧义性，但是它确实是个问题，幸运的是Spring也提供了对应的解决办法。

<h3> @Primary指定优先bean</h3>
在定义bean时，可以通过指定一个优先级高的bean来消除自动装配过程中遇到的歧义问题。

在上述例子中，可以选择一个最重要的Bean，用@Primary注解修饰：

```
@Component
@Primary
public class IceCream implements Dessert { ... }
```
如果你没有使用自动扫描，而是使用基于Java的显式配置文件，则如下定义@Bean方法：

```
@Bean
@Primary
public Dessert iceCream() {
  return new IceCream();
}
```
如果使用基于XML文件的显式配置，则如下定义：

```
<bean id="iceCream"
             class="com.dasserteater.IceCream"
             primary="true" />
```
不论哪种形式，效果都一样：告诉Spring选择primary bean来消除歧义。不过，当应用中指定多个Primary bean时，Spring又不会选择了，再次遇到歧义。Spring还提供了功能更强大的歧义消除机制——@Qualifiers注解。

<h3>@Qualifier指定bean的ID</h3>
@Qualifier注解可以跟@Autowired或@Inject一起使用，指定需要导入的bean的ID，例如，上面例子中的setDessert()方法可以这么写：

```
@Autowired
@Qualifier("iceCream")
public void setDessert(Dessert dessert) {
    this.dessert = dessert;
}
```
每个bean都具备唯一的ID，因此此处彻底消除了歧义。

如果进一步深究，@Qualifier("iceCream")表示以"iceCream"字符串作为qualifier的bean。每个bean都有一个qualifier，内容与该bean的ID相同。因此，上述装配的实际含义是：setDessert()方法会装配一个以"iceCream"为qualifier的bean，只不过碰巧是该bean的ID也是iceCream。

以默认的bean的ID作为qualifier非常简单，但是也会引发新的问题：如果将来对IceCream类进行重构，它的类名发生改变（例如Gelato）怎么办？在这种情况下，该bean对应的ID和默认的qualifier将变为"gelato"，然后自动装配就会失败。

问题的关键在于：你需要指定一个qualifier，该内容不会受目标类的类名的限制和影响。

**开发者可以给某个bean设定自定义的qualifier**，形式如下：

```
@Component
@Qualifier("cold")
public class IceCream implements Dessert { ... }
```
然后，在要注入的地方也使用"cold"作为qualifier来获得该bean：

```
@Autowired
@Qualifier("cold")
public void setDessert(Dessert dessert) {
    this.dessert = dessert;
}
```
即使在JavaConfig中，也可以使用@Qualifier指定某个bean的qualifier，例如：

```
@Bean
@Qualifier("cold")
public Dessert iceCream() {
  return new IceCream();
}
```
在使用自定义的@Qualifier值时，最好选择一个含义准确的名词，不要随意使用名词。在这个例子中，我们描述IceCream为"cold"bean，在装配时，可以读作：给我来一份cold dessert，恰好指定为IceCream。类似的，我们把Cake叫作"soft"，把Cookies*叫作"crispy"。


**使用自定义的qualifiers优于使用基于bean的ID的默认qualifier**，但是当你有多个bean共享同一个qualifier时，还是会有歧义。例如，假设你定义一个新的Dessertbean：

```
@Component
@Qualifier("cold")
public class Popsicle implements Dessert { ... }
```
现在你又有两个"cold"为qualifier的bean了，再次遇到歧义：最直白的想法是多增加一个限制条件，例如IceCream会成为下面的定义：

```
@Component
@Qualifier("cold")
@Qualifier("creamy")
public class IceCream implements Dessert { ... }
```
而Posicle类则如下定义：

```
@Component
@Qualifier("cold")
@Qualifier("fruity")
public class Popsicle implements Dessert { ... }
```
在装配bean的时候，则需要使用两个限制条件，如下：

```
@Bean
@Qualifier("cold")
@Qualifier("creamy")
public Dessert iceCream() {
  return new IceCream();
}
```
这里有个小问题：Java 不允许在同一个item上加多个相同类型的注解（Java 8已经支持），但是这种写法显然很啰嗦。

解决办法是：通过定义自己的qualifier注解，例如，可以创建一个@Cold注解来代替@Qualifier("cold")：

```
@Target({ElementType.CONSTRUCTOR, ElementType.FIELD,
                  ElementType.METHOD, ElementType.TYPE})
@Rentention(RetentionPolicy.RUNTIME)
@Qualifier
public @interface Cold { }
```
可以创建一个@Creamy注解来代替@Qualifier("creamy")：

```
@Target({ElementType.CONSTRUCTOR, ElementType.FIELD,
                  ElementType.METHOD, ElementType.TYPE})
@Rentention(RetentionPolicy.RUNTIME)
@Qualifier
public @interface Creamy { }
```
这样，就可以使用@Cold和@Creamy修饰IceCream类，例如：

```
@Component
@Cold
@Creamy
public class IceCream implements Dessert { ... }
```
类似的，可以使用@Cold和@Fruity修饰Popsicle类，例如：

```
@Component
@Cold
@Fruity
public class Popsicle implements Dessert { ... }
```
最后，在装配的时候，可以使用@Cold和@Creamy限定IceCream类对应的bean：

```
@Autowired
@Cold
@Creamy
public void setDessert(Dessert dessert) {
    this.dessert = dessert;
}
```

<h2>bean的作用域</h2>
默认情况下，Spring应用上下文中的bean都是单例对象，也就是说，无论给某个bean被多少次装配给其他bean，都是指同一个实例。

大部分情况下，单例bean很好用：如果一个对象没有状态并且可以在应用中重复使用，那么针对该对象的初始化和内存管理开销非常小。

但是，有些情况下你必须使用某中可变对象来维护几种不同的状态，因此形成非线程安全。在这种情况下，把类定义为单例并不是一个好主意——该对象在重入使用的时候可能遇到线程安全问题。

Spring定义了几种bean的作用域，列举如下：

<li>Singleton——在整个应用中只有一个bean的实例；
<li>Prototype——每次某个bean被装配给其他bean时，都会创建一个新的实例；
<li>Session——在web应用中，在每次会话过程中只创建一个bean的实<li>例；
Request——在web应用中，在每次http请求中创建一个bean的实例。
Singleton域是默认的作用域，如前所述，对于可变类型来说并不理想。我们可以使用@Scope注解——和@Component或@Bean注解都可以使用。

例如，如果你依赖component-scanning发现和定义bean，则可以用如下代码定义prototype bean：

```
@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class Notepad{ ... }
```
除了使用SCOPE_PROTOTYPE字符串指定bean的作用域，还可以使用@Scope("prototype")，但使用ConfigurableBeanFactory.SCOPE_PROTOTYPE更安全，不容易遇到拼写错误。

另外，如果你使用JavaConfig定义Notepad的bean，也可以给出下列定义：

```
@Bean
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public Notepad notepad() {
    return new Notepad();
}
```
如果你使用xml文件定义Notepad的bean，则有如下定义：

```
<bean id="notepad"
            class="com.myapp.Notepad"
            scope="prototype" />

```
无论你最后采取上述三种定义方式的哪一种定义prototype类型的bean，每次Notepad被装配到其他bean时，都会重新创建一个新的实例。

<h3>request和session作用域</h3>
在Web应用中，有时需要在某个request或者session的作用域范围内共享同一个bean的实例。举个例子，在一个典型的电子商务应用中，可能会有一个bean代表用户的购物车，如果购物车是单例对象，则所有的用户会把自己要买的商品添加到同一个购物车中；另外，如果购物车bean设置为prototype，则在应用中某个模块中添加的商品在另一个模块中将不能使用。

对于这个例子，使用session scope更合适，因为一个会话（session）唯一对应一个用户，可以通过下列代码使用session scope:

```
@Bean
@Scope(value=WebApplicationContext.SCOPE_SESSION,
                proxyMode=ScopedProxyMode.INTERFACES)
public ShoppingCart cart() { ... }
```
在这里你通过value属性设置了WebApplicationContext.SCOPE_SESSION，这告诉Spring为web应用中的每个session创建一个ShoppingCartbean的实例。在整个应用中会有多个ShoppingCart实例，但是在某个会话的作用域中ShoppingCart是单例的。

这里还用proxyMode属性设置了ScopedProxyMode.INTERFACES值，这涉及到另一个问题：把request/session scope的bean装配到singleton scope的bean时会遇到。首先看下这个问题的表现。

假设在应用中需要将ShoppingCartbean装配给单例StoreServicebean的setter方法：

```
@Component
public class StoreService {

    @Autowired
    public void setShoppingCart(ShoppingCart shoppingCart) {
        this.shoppingCart = shoppingCart;
    }
    ...
}
```
因为StoreService是单例bean，因此在Spring应用上下文加载时该bean就会被创建。在创建这个bean时 ，Spring会试图装配对应的ShoppingCartbean，但是这个bean是session scope的，目前还没有创建——只有在用户访问时并创建session时，才会创建ShoppingCartbean。

而且，之后肯定会有多个ShoppingCartbean：每个用户一个。理想的情景是：在需要StoreService操作购物车时，StoreService能够和ShoppingCartbean正常工作。

针对这种需求，Spring应该给StoreServicebean装配一个ShoppingCartbean的代理，如下图所示。代理类对外暴露的接口和ShoppingCart中的一样，用于告诉StoreService关于ShoppingCart的接口信息——当StoreService调用对应的接口时，代理采取延迟解析策略，并把调用委派给实际的session-scoped ShoppingCartbean。

<img src="http://upload-images.jianshu.io/upload_images/44770-c117d67ea67a9f2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" height="300px"/>

Scoped proxies enable deferred injected of request- and session-coped beans
因为ShoppingCart是一个接口，因此这里工作正常，但是，如果ShoppingCart是具体的类，则Spring不能创建基于接口的代理。这里必须使用CGLib创建class-based的bean，即使用ScopedProxyMode.TARGET_CLASS指示代理类应该基础自目标类。

这里使用session scope作为例子，在request scope中也有同样的问题，当然解决办法也相同。

<h3> 在XML文件中定义scoped代理</h3>
如果你在xml配置文件中定义session-scoped或者request-scoped bean，则不能使用@Scope注解以及对应的proxyMode属性。<bean>元素的scope属性可以用来指定bean的scope，但是如何指定代理模式？

可以使用Spring aop指定代理模式：

```
<bean id="cart"
            class="com.myapp.ShoppingCart"
            scope="session"
      <aop: scoped-proxy />
</bean>
```
<aop: scoped-proxy>在XML配置方式扮演的角色与proxyMode属性在注解配置方式中的相同，需要注意的是，这里默认使用CGLIB库创建代理，因此，如果需要创建接口代理，则需要设置proxy-target-class属性为false:

```
<bean id="cart"
            class="com.myapp.ShoppingCart"
            scope="session"
      <aop: scoped-proxy proxy-target-class="false" />
</bean>
```
为了使用<aop: scoped-proxy>元素，需要在XML配置文件中定义Spring的aop名字空间：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="htttp://www.springframework.org/schema/beans"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xmlns:aop="http://www.springframework.org/schema/aop"
              xsi:schemaLocations="
                   http://www.springframework.org/schema/aop
                   http://www.springframework.org/schema/aop/spring-aop.xsd
                   http://www.springframework.org/schema/beans
                   http://www.springframework.org/schema/beans/spring-beans.xsd">
    ........
```
<h2>运行时值注入</h2>
一般而言，讨论依赖注入和装配时，我们多关注的是如何（how）实现依赖注入（构造函数、setter方法），即如何建立对象之间的联系。

依赖注入的另一个方面是何时（when）将值装配给bean的属性或者构造函数。在装配bean—依赖注入的本质一文中，我们执行了很多值装配的任务，例如有如下代码：

```
@Bean
public CompactDisc sgtPeppers() {
    return new BlankDisc(
             "Sgt. Pepper's Lonely Hearts Club Band",
             "The Beatles");
}
```
这种硬编码的方式有时可以，有时却需要避免硬编码——在运行时决定需要注入的值。Spring提供以下两种方式实现运行时注入：

<li>Property placeholders
<li>he Spring Expression Language(SpEL)

<h3>注入外部的值</h3>
在Spring中解析外部值的最好方法是定义一个配置文件，然后通过Spring的环境实例获取配置文件中的配置项的值。例如，下列代码展示如何在Spring 配置文件中使用外部配置项的值。

```
package com.spring.sample.config;

import com.spring.sample.soundsystem.CompactDisc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

@Configuration
@PropertySource("classpath:/app.properties")
public class ExpressiveConfig {
        @Autowired
        Environment env; 

       @Bean
        public CompactDisc disc() {
              return new BlankDisc(env.getProperty("disc.title"),
                env.getProperty("disc.artist"));
    }
}
```
这里，@PropertySource注解引用的配置文件内容如下：

```
disc.title=Sgt. Pepper's Lonely Hearts Club Band
disc.artist=The Beatles
```
属性文件被加载到Spring的Environment实例中，然后通过getProperty()方法解析对应配置项的值。

**在Environment类中，getProperty()方法有如下几种重载形式**：
<li>String getProperty(String var1);
<li>String getProperty(String var1, String var2);
<li><T> T getProperty(String var1, Class<T> var2);
<li><T> T getProperty(String var1, Class<T> var2, T var3);

前两个方法都是返回String值，利用第二个参数，可以设置默认值；后两个方法可以指定返回值的类型，举个例子：假设你需要从连接池中获取连接个数，如果你使用前两个方法，则返回的值是String，你需要手动完成类型转换；但是使用后两个方法，可以由Spring自动完成这个转换：

```
int connection = env.getProperty("db.connection.count", Integer.class, 30)
```
除了getProperty()方法，还有其他方法可以获得配置项的值，如果不设置默认值参数，则在对应的配置项不存在的情况下对应的属性会配置为null，如果你不希望这种情况发生——即要求每个配置项必须存在，则可以使用getRequiredProperty()方法：

```
@Bean
public CompactDisc disc() {
    return new BlankDisc(
            env.getRequiredProperty("disc.title"),
            env.getRequiredProperty("disc.artist"));
}
```
在上述代码中，如果disc.title或者disc.artist配置项不存在，Spring都会抛出IllegalStateException异常。

如果你希望检查某个配置项是否存在，则可以调用containsProperty()方法：<code>boolean titleExists = env.containsProperty("disc.title");</code>。如果你需要将一个属性解析成某个类，则可以使用getPropertyAsClass()方法：<code>Class<CompactDisc> cdClass = env.getPropertyAsClass("disc.class", CompactDisc.class);</code>

**在Spring中，可以使用${ ... }将占位符包裹起来**，例如，在XML文件中可以定义如下代码从配置文件中解析对应配置项的值：

```
<bean id="sgtPeppers"
             class="soundsystem.BlankDisc"
             c:_title="${disc.title}"
             c:_artist="${disc.artist}" />
```
如果你使用component-scanning和自动装配创建和初始化应用组件，则可以使用@Value注解获取配置文件中配置项的值，例如BlankDisc的构造函数可以定义如下：

```
public BlankDisc(
            @Value("${disc.title}") String title,
            @Value("${disc.artist}") String artist) {
      this.title = title;
      this.artist = artist;
}
```
为了使用占位符的值，需要配置PropertyPlaceholderConfigerbean或者PropertySourcesPlaceholderConfigurerbean。从Spring 3.1之后，更推荐使用PropertySourcesPlaceholderConfigurer，因为这个bean和Spring 的Environment的来源一样，例子代码如下：

```
@Bean
public static PropertySourcesPlaceholderConfigurer placeholderConfigurer() {
    return new PropertySourcesPlaceholderConfigurer();
}
```
如果使用XML配置文件，则通过<context:property-placeholder>元素可以获得PropertySourcesPlaceholderConfigurerbean：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:context="http://www.springframework.org/schema/context"       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">
       <context:property-placeholder location="classpath:/app.properties" />
</beans>

```
<h3>使用SpEL装配</h3>
Spring 3引入了Spring Expression Language（SpEL），这是一种在运行时给bean的属性或者构造函数参数注入值的方法。

SpEL有很多优点，简单列举如下：

<li>可以通过bean的ID引用bean；
<li>可以调用某个对象的方法或者访问它的属性；
<li>支持数学、关系和逻辑操作；
<li>正则表达式匹配；
<li>支持集合操作
在后续的文章中，可以看到SpEL被用到依赖注入的其他方面，例如在Spring Security中，可以使用SpEL表达式定义安全限制；如果在Spring MVC中使用Thymeleaf模板，在模板中可以使用SpEL表达式获取模型数据。
SpEL是一门非常灵活的表达式语言，在这里不准备花大量篇幅来涵盖它的所有方面，可以通过一些例子来感受一下它的强大能力。

首先，SpEL表达式被#{ ... }包围，跟placeholders中的${ ... }非常像，最简单的SpEL表达式可以写作<code>#{1}</code>。在应用中，你可能回使用更加有实际含义的SpEL表达式，例如<code>#{T(System).currentTimeMillis()}</code>——这个表达式负责获得当前的系统时间，而T()操作符负责将java.lang.System解析成类，以便可以调用currentTimeMillis()方法。

SpEL表达式可以引用指定ID的bean或者某个bean的属性，例如下面这个例子可以获得ID为sgtPeppers的bean的artist属性的值：<code>#{sgtPeppers.artist}</code>；也可以通过<code>#{systemProperties['disc.title']}</code>引用系统属性。

上述这些例子都非常简单，我们接下来看下如何在bean装配中使用SpEL表达式，之前提到过，如果你使用component-scanning和自动装配创建应用组件，则可以使用@Value注解获得配置文件中配置项的值；除了使用placeholder表达式，还可以使用SpEL表达式，例如BlankDisc的构造函数可以按照下面这种方式来写：

```
public BlankDisc(
            @Value("#{systemProperties['disc.title']}") String title,
            @Value("#{systemProperties['disc.artist']}") String artist) {
      this.title = title;
      this.artist = artist;
}
```
SpEL表达式可以表示整数值，也可以表示浮点数、String值和Boolean值。例如可以使用#{3.14159}表式浮点数3.14159，并且还支持科学计数法——<code>#{9.87E4}</code>表示98700；<code>#{'Hello'}</code>可以表示字符串值、<code>#{false}</code>可以表示Boolean值。

单独使用字面值是乏味的，一般不会使用到只包含有字面值的SpEL表达式，不过在构造更有趣、更复杂的表达式时支持字面值这个特性非常有用。

SpEL表达式可以通过bean的ID引用bean，例如<code>#{sgtPeppers}</code>；也可以引用指定bean的属性，例如<code>#{sgtPeppers.artist}</code>；还可以调用某个bean的方法，例如#<code>{artistSelector.selectArtist()}</code>表达式可以调用artistSelector这个bean的selectArtist()方法。

SpEL表达式也支持方法的连续调用，例如#<code>{artistSelector.selectArtist().toUpperCase()}</code>,为了防止出现NullPointerException异常，最好使用类型安全的操作符，例如#<code>{artistSelector.selectArtist()?.toUpperCase()}</code>。?.操作符在调用右边的函数之前，会确保左边的函数返回的值不为null。

在SpEL中能够调用类的方法或者常量的关键是T()操作符，例如通过<code>T(java.lang.Math)</code>可以访问Math类中的方法和属性——<code>#{(java.lang.Math).random()}</code>和<code>#{T(java.lang.Math).PI}</code>。

在操作文本字符串时，最常用的是检查某个文本是否符合某种格式。SpEL通过matches操作符支持正则表达式匹配。例如：<code>#{admin.email matches '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com'}</code>可以检查admin.email表示的邮件地址是否正确。

通过SpEL表达式还可以操作集合和数组，例如<code>#{jukebox.songs[4].title}</code>这个表达式可以访问jukebox的songs数组的第5个元素。

也可以实现更复杂的功能：随机选择一首歌——<code>#{jukebox.songs[T(java.lang.Math).random() * jukebox.songs.size()].title}</code>。

SpEL提供了一个选择操作符——<code>.?[]</code>，可以获得某个集合的子集，举个例子，假设你获得jukebox中所有artist为Aerosmith的歌，则可以使用这个表达式：<code>#{jukebox.songs.?[artist eq 'Aerosmith']}</code>。可以看出，<code>.?[]</code>操作符支持在[]中嵌套另一个SpEL表达式。

SpEL还提供了其他两个选择操作符：<code>.^[]</code>用于选择第一个匹配的元素；<code>.$[]</code>用于选择最后一个匹配的元素。

最后，SpEL还提供了一个提取操作符：<code>.![]</code>，可以根据指定的集合新建一个符合某个条件的新集合，例如<code>#{jukebox.songs.![title]}</code>可以将songs的title都提取出来构成一个新的字符串集合。

OK，SpEL的功能非常强大，但是这里需要给开发人员提个醒：别让你的SpEL表达式过于智能。你的表达式越智能，就越难对它们进行单元测试，因此，尽量保证你的SpEL表达式简单易理解。

<h2>总结</h2>
首先我们介绍了通过Spring的profiles解决多环境部署的问题，通过在运行时根据代表指定环境的profile选择性创建某个bean，Spring可以实现无需重新构建就可以在多个环境下部署同一个应用。

Profiles bean是运行时创建bean的一种解决方案，不过Spring 4提供了一个更普遍的解决方案：利用@Conditional注解和Condition接口实现条件性创建bean。

我们还介绍了两种机制来解决自动装配时可能遇到的歧义性问题：primary beans和qualifiers。尽管定义一个primary bean非常简单，但它仍然有局限，因此我们需要利用qualifier缩小自动装配的bean的范围，而且，我们也演示了如何创建自己的qualifiers。

尽管大多数Spring bean是单例对象，但是在某些情况下具备其他作用域的对象更加合适。Spring 应用中可以创建singletons、prototypes、request-scoped或session-scoped。在使用request-scoped或者session-scoped类型的bean时，还需要解决将非单例对象注入到单例对象时遇到的问题——利用代理接口或代理类。

最后，我们也介绍了Spring表达式语言（SpEL），利用SpEL可以实现在运行时给bean注入值。

