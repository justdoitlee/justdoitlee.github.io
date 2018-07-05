---
title: Java反射学习总结（一)
date: 2017-02-18 21:12:54
categories: Java二三事
tags: 
	- 反射
---

Java提供的反射机制允许我们在运行时期动态加载类，检测和修改它本身状态或行为，要举反射机制的一个实例的话，就是在整合开发环境中所提供的方法提示或者类的检查工具，另外像jsp中的javabean自动收集请求也用到了反射，还有我们经常用的框架也可以看到反射机制的使用，这样可以达到动态加载使用者自己定义的类的目的。
<!--more-->
在我们拿到一个类时，即使对它一无所知，但是其实他本身就包括了很多信息，Java在需要使用某个类时才会将类加载，并在jvm中以一个**java.lang.Class**的实例存在，从Class实例开始，我们可以获取类的信息。


**Class类的加载**

Java在真正需要使用一个类的时候才会进行加载，而不是在程序启动时加载所有的类，因为大多数人都只使用到应用程序的部分资源，在需要某些功能时在加载某些资源，这样可以让系统的资源运用更有效率。

一个java.lang.Class代表了Java程序中运行时加载类或者接口的实例，也可以用来表达enum（枚举），annotation（注解），数组，基本数据类型；Class类没有public构造方法，Class是由jvm自动生成的，每当一个类被加载时，jvm就会自动生成一个Class实例。

我们还可以通过Object的getClass()方法来取得每一个对象对应Class实例，或者通过"class"常量，在取得Class实例之后，操作Class实例上的一些方法来取得类的基本信息，例如：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/3
 */
public class ClassDemo {
    public static void main(String[] args) {
        String name = "justdoitlee";
        Class stringClass = name.getClass();
        System.out.println("类名称：" +
                stringClass.getName());
        System.out.println("是否为接口：" +
                stringClass.isInterface());
        System.out.println("是否为基本数据类型：" +
                stringClass.isPrimitive());
        System.out.println("是否为数组：" +
                stringClass.isArray());
        System.out.println("父类名称：" +
                stringClass.getSuperclass().getName());
    }
}

```
执行结果：

```
类名称：java.lang.String
是否为借口：false
是否为基本数据类型：false
是否为数组：false
父类名称：java.lang.Object

Process finished with exit code 0

```
这里简单的的使用 getClass() 方法来取得 String 类的 Class 实例，并从中得到 String 的一些基本信息。

当然，我们也可以直接使用下面的方式来取得String类的Class对象：

```
Class stringClass = String.class;
```

Java在真正需要类时才会加载这个类，所谓的**真正需要**通常指的是要使用指定的类生成对象时，或者使用指定要加载的类时，例如使用Class.forName()加载类，或者使用ClassLoader的loadClass()加载类，声明类并不会导致类的加载，可以使用一个小测试来验证。

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/3
 */
public class TestClass {
    static {
        System.out.println("类被加载");
    }
}

```

在上面我们定义了一个静态代码块，假设在类第一次被加载时会执行静态代码块（说假设是因为，可以设置加载类时不执行静态代码块，使Class生成对象时才执行静态代码块），看输出信息可以看出类何时被加载(如下LoadClassTest)。

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/3
 */
public class LoadClassTest {
    public static void main(String[] args) {
        TestClass test = null;
        System.out.println("声明TestClass");
        test = new TestClass();
        System.out.println("生成TestClass实例");
    }
}


```

输出：

```
声明TestClass
类被加载
生成TestClass实例

Process finished with exit code 0
```
从执行结果可以看出，声明类并不会导致TestClass被加载，而是在使用new生成对象时才会被加载类。

Class的信息是在编译时期就被加入至.class文件的，这是Java执行时期被辨别（RTTI，Run-Time Type Information或Run-Time Type Identification）的一种方式，在编译时期编译器会先检查对应的.class文件，而执行时期jvm在使用类时，会先检查对应的Class是否已经被加载，如果没有加载，则会寻找对应的,class文件并加载，一个类在jvm中只会有一个Class实例，每个类的实例都会记得自己是由哪个Class实例所生成，我们可以使用getClass()或.class来取得Class实例。

另外，在Java中，数组对象也有对应的Class实例，这个对象是由具有相同元素与维度的数组所共用，而基本类型像是 boolean, byte, char, short, int, long, float, double 以及关键字 void（以前都不知道有这个呢！！），也都具有对应的Class对象，我们还可以用类常量（Class literal）来获取这些对象。

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class ClassDemo2 {
    public static void main(String[] args) {
        System.out.println(boolean.class);
        System.out.println(void.class);

        int[] iarr = new int[10];
        System.out.println(iarr.getClass().toString());

        double[] darr = new double[10];
        System.out.println(darr.getClass().toString());
    }
}
```
输出：

```
boolean
void
class [I
class [D

Process finished with exit code 0
```
在Java中 数组确实是以对象的形式存在的，其对应的类都是有jvm自动生成的，当我们是用toString()来显示数组对象的描述时，[表示为数组类型，并且加上一个类型代表字，上面的I表示是一个Int的数组，d是一个double数组。

这里就先讲一下Class类的加载吧，后面的再总结。


