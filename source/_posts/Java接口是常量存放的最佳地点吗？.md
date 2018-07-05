---
title: Java接口是常量存放的最佳地点吗？
date: 2017-02-18 21:18:07
categories: Java二三事
tags: 
	- 接口
	- 常量
---
今天偶然看到接口中不能包含**实例域**或**静态方法**，但是却可以包含**常量**。<br>
其实在之前，就知道这么回事，但是一直只是当做知道而已，现在回过头来巩固基础，觉得有必要多想想。
<!--more-->
首先，由于java的接口中声明的字段在编译时会自动加上static final的修饰符，即声明为常量。因而接口通常是存放常量的最佳地点，因为这样可以省去很多修饰符嘛，然而在java的实际应用时却会产生一些问题。<br>

问题的起因个人觉得有两个:<br>
第一，是我们所使用的常量并不是一成不变的，而是相对于变量不能赋值改变。例如我们在一个项目初期定义常量π＝3.14，而由于计算精度的提高我们可能会重新定义π＝3.14159，此时整个项目对此常量的引用都应该做出改变。<br>
第二，java是动态语言。与c++之类的静态语言不同,java对一些字段的引用可以在运行期动态进行，这种灵活性是java这样的动态语言的一大优势。也就使得我们在java项目中有时部分内容的改变不用重新编译整个项目，而只需编译改变的部分重新发布就可以改变整个应用。

例如，有一个interface A，一个class B，代码如下：

```
public interface A{
	String name = "bright";
}

public class B{
	public static void main(String[] args){
		System.out.println("Class A's name = " + A.name);
	}
}
```
编译A和B。<br>
运行，输入java B，显然结果如下：
```
Class A's name = bright
```
我们现在修改A如下：
```
public interface A{
	String name = "bright sea";
}
```
编译A后重新运行B，输入java B，注意：结果如下
```
Class A's name = bright
```
为什么不是"Class A's name = bright sea"？让我们使用jdk提供的反编译工具javap反编译B.class看个究竟，输入：javap -c B ，结果如下：

```
Compiled from B.java
public class B extends java.lang.Object {
    public B();
    public static void main(java.lang.String[]);
}
Method B()
   0 aload_0
   1 invokespecial #1 <Method java.lang.Object()>
   4 return
Method void main(java.lang.String[])
   0 getstatic #2 <Field java.io.PrintStream out>
   3 ldc #3 <String "Class A's name = bright">
   5 invokevirtual #4 <Method void println(java.lang.String)>
   8 return
```
注意到标号3的代码了吗？由于引用了一个static final 的字段，编译器已经将interface A中name的内容编译进了class B中，而不是对interface A中的name的引用。因此除非我们重新编译class B，interface A中name发生的变化无法在class B中反映。如果这样去做那么java的动态优势就消失殆尽。<br>

解决方案，有两种解决方法。<br>
第一种方法是不再使用常量，将所需字段放入class中声明，并去掉final修饰符。但这种方法存在一定的风险，由于不再是常量着因而在系统运行时有可能被其他类修改其值而发生错误，也就违背了我们设置它为常量的初衷，因而不推荐使用。<br>
第二种方法，将常量放入class中声明，使用class方法来得到此常量的值。为了保持对此常量引用的简单性，我们可以使用一个静态方法。我们将A.java和B.java修改如下：
```
public class A{
	private static final String name = "bright";
	public static String getName(){
		return name;
	}
}

public class B{
	public static void main(String[] args){
		System.out.println("Class A's name = " + A.getName());
	}
}
```
同样我们编译A和B。运行class B，输入java B，显然结果如下：
Class A's name = bright
现在我们修改A如下：
```
public class A{
	private static final String name = "bright";
	public static String getName(){
		return name;
	}
}
```
我们再次编译A后重新运行B，输入java B：结果如下
```
Class A's name = bright sea
```
终于得到了我们想要的结果，我们可以再次反编译B看看class B的改变，输入
javap -c B,结果如下：
```
Compiled from B.java
public class B extends java.lang.Object {
    public B();
    public static void main(java.lang.String[]);
}
Method B()
   0 aload_0
   1 invokespecial #1 <Method java.lang.Object()>
   4 return
Method void main(java.lang.String[])
   0 getstatic #2 <Field java.io.PrintStream out>
   3 new #3 <Class java.lang.StringBuffer>
   6 dup
   7 invokespecial #4 <Method java.lang.StringBuffer()>
  10 ldc #5 <String "Class A's name = ">
  12 invokevirtual #6 <Method java.lang.StringBuffer append(java.lang.String)>
  15 invokestatic #7 <Method java.lang.String getName()>
  18 invokevirtual #6 <Method java.lang.StringBuffer append(java.lang.String)>
  21 invokevirtual #8 <Method java.lang.String toString()>
  24 invokevirtual #9 <Method void println(java.lang.String)>
  27 return
```
注意标号10至15行的代码，class B中已经变为对A class的getName()方法的引用，当常量name的值改变时我们只需对class A中的常量做修改并重新编译，无需编译整个项目工程我们就能改变整个应用对此常量的引用，即保持了java动态优势又保持了我们使用常量的初衷，因而方法二是一个最佳解决方案。