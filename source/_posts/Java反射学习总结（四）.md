---
title: Java反射学习总结（四）
date: 2017-02-18 21:15:55
categories: Java二三事
tags: 
	- 反射
---
**类加载器**

Java在需要使用类的时候，才会将类加载，Java的类加载是由类加载器（Class loader）来完成的。
当我们在命令模式下执行java xxx指令后，Java执行程序会尝试找到jre安装的所在目录，然后找到jvm.dll（假设在jre目录下的bin\client下），接着启动jvm并进行初始化操作，接着会产生bootstrap loader，bootstrap loader则会加载 extended loader，并设定 extended loader的parent为bootstrap loader，接着bootstrap loader会加载system loader，并将system loader的parent设为 extended loader。
<!--more-->
bootstrap loader通常是由c写的， extended loader是由Java写的，实际这个对应着sun.misc.Launcher\$ExtClassLoader（Launcher 中的内部类）；system loader 是由 Java写的，实际对应sun.misc. Launcher\$AppClassLoader（Launcher 中的内部类）。



**流程如下图：**
![这里写图片描述](http://img.blog.csdn.net/20161205220032526)


Bootstrap Loader 会查找系统参数 sun.boot.class.path 中指定位置的类，假设是 JRE classes 下之文件，或 lib 目录下 .jar 文件中（例如 rt.jar）的类并加载，我们可以使用 System.getProperty("sun.boot.class.path") 来显示 sun.boot.class.path 中指定的路劲，例如在我的终端显示的是以下的路劲：

```
/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/resources.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/rt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/sunrsasign.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/jsse.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/jce.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/charsets.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/jfr.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/classes

```

Extended Loader（sun.misc.Launcher$ExtClassLoader）是由 Java 写的，会查找系统参数java.ext.dirs 中指定位置的类，假设是 JRE 目录下的 lib\ext\classes 目录下的 .class 文件，或 lib\ext 目录下的 .jar 文件中（例如 rt.jar）的类并加载，我们可以使用 System.getProperty("java.ext.dirs") 来显示指定的路劲:

```
/Users/lizhi/Library/Java/Extensions:/Library/Java/JavaVirtualMachines/jdk1.8.0_65.jdk/Contents/Home/jre/lib/ext:/Library/Java/Extensions:/Network/Library/Java/Extensions:/System/Library/Java/Extensions:/usr/lib/java

```
System Loader（sun.misc.Launcher$AppClassLoader）是由 Java 写的，会查找系统参 java.class.path 中指定位置的类，也就是 Classpath 所指定的路径，假设是目前工作路径下的 .class 文件，我们可以使用 System.getProperty("java.class.path") 来显示 java.class.path 中指定的路径，在使用 java 执行程序时，我们也可以加上 -cp 來覆盖原有的 Classpath 设置，例如：

```
java –cp ./classes SomeClass
```
Bootstrap Loader 会在 JVM 启动之后生成，之后它会加载 Extended Loader 并将其 parent 设为 Bootstrap Loader，然后Bootstrap Loader 再加载 System Loader 并将其 parent 设为 ExtClassLoader，接着System Loader 开始加载我们指定的类，在加载类时，每个类加载器会先将加载类的任务讲给他的parent，如果 parent 找不到，才由自己负责加载，所以在加载类时，会以 Bootstrap Loader→Extended Loader→System Loader 的顺序开查找类，如果都找不到，就会抛出 NoClassDefFoundError。

类加载器在 Java 中是以 java.lang.ClassLoader 形式存在，每一个类被加载后，都会有一个 Class 的实例来代表，而每个 Class 的实例都会记得自己是由哪个 ClassLoader 加载的，可以由 Class 的 getClassLoader() 取得加载该类的 ClassLoader，而从 ClassLoader 的 getParent() 方法可以取得自己的 parent。

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class SomeClass {
    public static void main(String[] args) {
        // 建立SomeClass实例
        SomeClass some = new SomeClass();
        // 取得SomeClass的Class实例
        Class c = some.getClass();
        // 取得ClassLoader
        ClassLoader loader = c.getClassLoader();
        System.out.println(loader);
        // 取得父ClassLoader
        System.out.println(loader.getParent());
        // 再取得父ClassLoader
        System.out.println(loader.getParent().getParent());
    }
}

```

输出：

```
sun.misc.Launcher$AppClassLoader@60e53b93
sun.misc.Launcher$ExtClassLoader@66d3c617
null

Process finished with exit code 0
```
CoreJava.day_2.SomeClass 是个自定义类，我们在目前的目录下执行程序，首先 AppClassLoader 会将加载类的任务交給 ExtClassLoader，而 ExtClassLoader 将会把加载类的任务交给 Bootstrap Loader，由于Bootstrap Loader 在它的路径（sun.boot.class.path）下找不到类，所以由 ExtClassLoader 来尝试查找，而 ExtClassLoader 在它的路径设置（java.ext.dirs）下也找不到类，所以由 AppClassLoader 来尝试查找，AppClassLoader 最后在 Classpath（java.class.path）设置下找到指定的类并加载。

在输出中可以看到，加载 SomeClass 的 ClassLoader 是 AppClassLoader，而 AppClassLoader 的 parent 是 ExtClassLoader，而 ExtClassLoader 的 parent 是 null，null 并不是表示 ExtClassLoader 没有设置 parent，而是因为 Bootstrap Loader 通常由 C 写的，在 Java 中并没有一个类来表示它，所以才会显示为null。

如果把 SomeClass 的 .class 文件移至 JRE 目录下的 lib\ext\classes下，并重新（任何目录下）执行程序，我们可以看到：

```
null
Exception in thread "main" java.lang.NullPointerException
        at CoreJava.day_2.SomeClass.main(SomeClass.java:13)

```
由于 SomeClass 这次可以在 Bootstrap Loader 的设置路径下找到，所以会由 Bootstrap Loader 来加载 SomeClass 类，Bootstrap Loader 通常由 C 写的，在 Java 中没有一个实际类来表示，所以显示为 null，因为表示为null，所以再由 null 上尝试调用 getParent() 方法就会抛出 NullPointerException 异常。

取得 ClassLoader 的实例之后，我们可以使用它的 loadClass() 方法来加载类，使用 loadClass() 方法加载类时，不会执行静态代码块，静态代码块的执行会等到真正使用类时来建立实例：
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
<br>
```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class ForNameDemoV3 {
    public static void main(String[] args) {
        try {
            System.out.println("加载TestClass2");
            ClassLoader loader = ForNameDemoV3.class.getClassLoader();
            Class c = loader.loadClass("CoreJava.day_2.TestClass2");

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
可以看出，loadClass() 不会在加载类时执行静态代码块，而会在使用类new对象时才执行静态代码块代码。