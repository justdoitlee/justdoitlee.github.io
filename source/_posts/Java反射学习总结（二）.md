---
title: Java反射学习总结（二）
date: 2017-02-18 21:14:04
categories: Java二三事
tags: 
	- 反射
---
**使用 Class.forName() 加载类**

在一些应用中，我们无法事先知道使用者将会加载什么类，而必须让使用者指定类名类加载类，我们就可以用Class的静态forName()方法来实现动态加载类，如下：
<!--more-->
```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class ForNameDemo {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);
            System.out.println("类名：" +
                    c.getName());
            System.out.println("是否为接口：" +
                    c.isInterface());
            System.out.println("是否为基本类型：" +
                    c.isPrimitive());
            System.out.println("是否为数组：" + c.isArray());
            System.out.println("父类名：" +
                    c.getSuperclass().getName());
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("没有指定的类名");
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定类");
        }
    }
}

```

输出:

```
java ForNameDemo java.util.String
类名：java.util.Scanner
是否为接口：false
是否为基本类型：false
是否为数组：false
父类名：java.lang.Object
```
Class的静态方法forName()方法有两个版本，上面所示的是指定类名版本，还一个版本可以让我们指定类名，加载时是否执行静态代码块，指定类的加载器（Class loader）:

```
static Class forName(String name, boolean initialize, ClassLoader loader)

```
<a href="http://justdoitlee.com/javafan-she-xue-xi-bi-ji/" target="_blank">
上一篇</a>写到过，假设在加载类的时候，如果类中有定义静态代码块则会执行它，我们可以使用forName的第二个版本，将initialize设为false，如果在加载类时并不会马上执行静态代码块的代码，而会在使用类实例对象时才执行静态代码块，我们可以做一下测试：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class TestClass2 {
        static {
            System.out.println("[执行静态代码块]");
        }
}

```
在这里我们只定义了静态代码块显示一段信息，来观察静态代码块何时被执行。先用第一个版本来测试：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class ForNameDemoV1 {
    public static void main(String[] args) {
        try {
            System.out.println("加载TestClass2");
            Class c = Class.forName("TestClass2");

            System.out.println("TestClass2声明");
            TestClass2 test = null;

            System.out.println("TestClass2实例对象");
            test = new TestClass2();
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定的类");
        }
    }
}

```
输出：

```
加载TestClass2
[执行静态代码块]
TestClass2声明
TestClass2实例对象

Process finished with exit code 0
```
可以从结果看出，第一个版本的forName()方法在加载类之后，会马上执行静态代码块，再看看第二种结果怎么样：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class ForNameDemoV2 {
    public static void main(String[] args) {
        try {
            System.out.println("加载TestClass2");
            Class c = Class.forName(
                    "CoreJava.day_2.TestClass2",
                    false, // 加载类时不执行静态代码块代码
                    Thread.currentThread().getContextClassLoader());

            System.out.println("TestClass2声明");
            TestClass2 test = null;

            System.out.println("TestClass2实例对象");
            test = new TestClass2();
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定的类");
        }
    }
}

```
输出：
```
加载TestClass2
TestClass2声明
TestClass2实例对象
[执行静态代码块]

Process finished with exit code 0
```
由于在第二个版本的forName()方法中，把initialize设为了false，所以加载类时并不会马上执行静态代码块，而会在类实例对象时才去执行静态代码块代码，第二个版本的forName()方法需要一个类加载器（Class loader）。