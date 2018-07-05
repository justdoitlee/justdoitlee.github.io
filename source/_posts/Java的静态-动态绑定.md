---
title: Java的静态/动态绑定
date: 2017-02-18 20:57:05
categories: Java二三事
tags: 
	- 静态动态绑定
---
今天看到《Java核心技术I》书上的动态绑定，意思就是当子类和父类存在同一个方法，子类重写了父类的方法，程序在运行时调用方法是调用父类的方法还是子类的重写方法呢？程序会在运行的时候自动选择调用某个方法（根据方法表）。
看完这里不由自主的想到，有动态肯定也就有静态吧，于是去求助了下google，首先看了下什么是**绑定**: 
绑定指的是一个方法的调用与方法所在的类(方法主体)关联起来。对java来说，绑定分为静态绑定和动态绑定；或者叫做前期绑定和后期绑定。
<!--more-->
然后我们分别看看两者之间含义以及差别<br>
**动态绑定**：在运行时根据具体对象的类型进行绑定。若一种语言实现了后期绑定，同时必须提供一些机制，可在运行期间判断对象的类型，并分别调用适当的方法。也就是说，编译器此时依然不知道对象的类型，但方法调用机制能自己去调查，找到正确的方法主体。不同的语言对后期绑定的实现方法是有所区别的。但我们至少可以这样认为：它们都要在对象中安插某些特殊类型的信息。

**动态绑定的过程**：<br>
虚拟机提取对象的实际类型的方法表；-->
虚拟机搜索方法签名；-->
调用方法。

**静态绑定**：在程序执行前方法已经被绑定（也就是说在编译过程中就已经知道这个方法到底是哪个类中的方法），此时由编译器或其它连接程序实现。针对java，可以简单的理解为程序编译期的绑定；这里要特别说明一点，java当中的方法只有final，static，private和构造方法是前期绑定。

**差别**：其实上述解释可以看出很多东西了。<br>
（1）静态绑定发生在编译时期，动态绑定发生在运行时<br>
（2）使用private或static或final修饰的变量或者方法，使用静态绑定。而虚方法（可以被子类重写的方法）则会根据运行时的对象进行动态绑定。<br>
（3）静态绑定使用类信息来完成，而动态绑定则需要使用对象信息来完成。<br>
（4）重载(Overload)的方法使用静态绑定完成，而重写(Override)的方法则使用动态绑定完成。

**下面开始代码测试**：

```
public class Test {
  public static void main(String[] args) {
      String str = new String();
      Lee lee = new Lee();
      lee.say(str);
  }
  static class Lee {
      public void say(Object obj) {
          System.out.println("这是个Object");
      }   
      public void say(String str) {
          System.out.println("这是个String");
      }
  }
}
```
**执行结果**：
```
$ java Test
这是个String
```

在上面的代码中，lee方法存在两个重载的实现，一个是接收Object类型的对象作为参数，另一个则是接收String类型的对象作为参数。而str是一个String对象，所有接收String类型参数的call方法会被调用。而这里的绑定就是在编译时期根据参数类型进行的静态绑定。

**接着我们反编译验证一下**:

```
javap -c Test    
Compiled from "Test.java"
public class CoreJava.day_2.Test {
  public CoreJava.day_2.Test();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: new           #2                  // class java/lang/String
       3: dup
       4: invokespecial #3                  // Method java/lang/String."<init>":()V
       7: astore_1
       8: new           #4                  // class CoreJava/day_2/Test$Lee
      11: dup
      12: invokespecial #5                  // Method CoreJava/day_2/Test$Lee."<init>":()V
      15: astore_2
      16: aload_2
      17: aload_1
      18: invokevirtual #6                  // Method CoreJava/day_2/Test$Lee.call:(Ljava/lang/String;)V
      21: return
}

```

看到了这一行18: invokevirtual #6                  // Method CoreJava/day_2/Test$Lee.call:(Ljava/lang/String;)V确实是发生了静态绑定，确定了调用了接收String对象作为参数的say方法。


**现在可以改写一下**：

```
public class Test{
  public static void main(String[] args) {
      String str = new String();
      Lee lee = new SecLee();
      lee.say(str);
  }
  
  static class Lee {
      public void say(String str) {
          System.out.println("这是个String");
      }
  }
  
  static class SecLee extends Lee {
      @Override
      public void say(String str) {
          System.out.println("这是第二李的String");
      }
  }
}
```

**结果为**：

```
$ java Test
这是第二李的String
```

上面，用SecLee继承了Lee，并且重写了say方法。我们声明了一个Lee类型的变量lee，但是这个变量指向的是他的子类SecLee。根据结果可以看出，其调用了SecLee的say方法实现，而不是Lee的say方法。这一结果的产生的原因是因为在运行时发生了动态绑定，在绑定过程中需要确定调用哪个版本的say方法实现。

**再看看反编译的结果**：

```
javap -c Test
警告: 二进制文件Test包含CoreJava.day_2.Test
Compiled from "Test.java"
public class CoreJava.day_2.Test {
  public CoreJava.day_2.Test();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: new           #2                  // class java/lang/String
       3: dup
       4: invokespecial #3                  // Method java/lang/String."<init>":()V
       7: astore_1
       8: new           #4                  // class CoreJava/day_2/Test$SecLee
      11: dup
      12: invokespecial #5                  // Method CoreJava/day_2/Test$SecLee."<init>":()V
      15: astore_2
      16: aload_2
      17: aload_1
      18: invokevirtual #6                  // Method CoreJava/day_2/Test$Lee.say:(Ljava/lang/String;)V
      21: return
}
```
正如上面的结果，18: invokevirtual #6                  // Method CoreJava/day_2/Test Lee.say:(Ljava/lang/String;)V这里是TestLee.say而非Test$SecLee.say，因为编译期无法确定调用子类还是父类的实现，所以只能丢给运行时的动态绑定来处理。

既然重写测试了，**那我们再试试重载**：

下面的例子更复杂！Lee类中存在say方法的两种重载，更复杂的是SecLee集成Lee并且重写了这两个方法。其实这种情况是上面两种情况的复合情况。
下面的代码首先会发生静态绑定，确定调用参数为String对象的say方法，然后在运行时进行动态绑定确定执行子类还是父类的say实现。

```
public class Test {
  public static void main(String[] args) {
      String str = new String();
      Lee lee = new SecLee();
      lee.say(str);
  }
  
  static class Lee {
      public void say(Object obj) {
          System.out.println("这是Object");
      }
      
      public void say(String str) {
          System.out.println("这是String");
      }
  }
  
  static class SecLee extends Lee {
      @Override
      public void say(Object obj) {
          System.out.println("这是第二李的Object");
      }
      
      @Override
      public void say(String str) {
          System.out.println("这是第二李的String");
      }
  }
}
```
**结果**:

```
$ java Test
这是第二李的String
```
结果在意料之中，就不多说了。

那么问题来了，<font color=red>**非动态绑定不可么？**</font>
其实某些方法的绑定也可以由静态绑定实现，比如说：

```
public static void main(String[] args) {
      String str = new String();
      final Lee lee = new SecLee();
      lee.say(str);
}
```
可以看出，这里lee持有SecLee的对象并且lee变量为final，立即执行了say方法，编译器理论上通过足够的分析代码，是可以知道应该调用SecLee的say方法。

**结论：**
由于动态绑定需要在运行时确定执行哪个版本的方法实现或者变量，比起静态绑定起来要耗时，所以正如书上所说的，有些程序员认为，除非有足够的理由使用多态性，应该把所有的方法都声明为final，private或者static进行修饰。我觉得这个有点偏激了，具体使用仁者见仁，智者见智吧。