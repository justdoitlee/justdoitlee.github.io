---
title: JVM常量池及字符串==比较分析
date: 2017-02-18 20:06:42
categories: Java二三事
tags: 
	- Java
	- 字符串
	- 常量池
---
java中的常量池技术，是为了方便快捷地创建某些对象而出现的，当需要一个对象时，就可以从池中取一个出来（如果池中没有的话就创建一个），这样在我们需要重复创建相等变量节省了很多时间。<br>
&nbsp;&nbsp;常量池其实也就是一个内存空间，不同于使用new关键字创建的对象所在的堆空间。String类是java中用的比较多的类，同样为了创建String对象的方便，该类也实现了常量池的技术。<br>
<!--more-->
在讲述常量池之前，我们有必要先说说<font color=red>JVM运行时数据区的内存模型</font>。<br>
JVM运行时数据区的内存模型由五部分组成:<br>
1.方法区 
2.堆
3.JAVA栈
4.PC寄存器
5.本地方法栈

例如对于```String s = "haha"``` ,它的虚拟机指令：
```
0:   ldc     #16; //String haha    
2:   astore_1 
3:   return
```

从上面的ldc指令的执行过程可以得出：s的值是来自被拘留String对象（由解析该入口的进程产生）的引用，即可以理解为是从被拘留String对象的引用复制而来的，故我个人的理解是s的值是存在栈当中。上面是对于s值得分析，接着是对于"haha"值的分析,我们知道，对于String s = "haha" 其中"haha"值在JAVA程序编译期就确定下来了的。简单一点说，就是haha的值在程序编译成class文件后，就在class文件中生成了。执行JAVA程序的过程中，第一步是class文件生 成，然后被JVM装载到内存执行。那么JVM装载这个class到内存中，其中的haha这个值，在内存中是怎么为其开辟空间并存储在哪个区域中呢？

&nbsp;&nbsp;首先我们不妨先来了解一下JVM常量池这个结构,这里我查询了一些资料,在资料中这样描述**常量池**:<br>
虚拟机必须为每个被装载的类型维护一个常量池。常量池就是该类型所用到常量的一个有序集和，包括直接常量（string,integer和 floating point常量）和对其他类型，字段和方法的符号引用。对于String常量，它的值是在常量池中的。而JVM中的常量池在内存当中是以表的形式存在的，对于String类型，有一张固定长度的CONSTANT_String_info表用来存储文字字符串值，注意：该表只存储文字字符串值，不存储符号引用。说到这里，对常量池中的字符串值的存储位置应该有一个比较明了的理解了。

下面讲讲**八种基本类型的包装类和对象池**

Java中基本类型的包装类的大部分都实现了常量池技术，这些类是 Byte,Short,Integer,Long,Character,Boolean,另外两种浮点数类型的包装类则没有实现。另外 Byte,Short,Integer,Long,Character这5种整型的包装类也只是在对应值小于等于127时才可使用对象池，也即对象不负责创建和管理大于127的这些类的对象。一些对应的测试代码：
```
public class Test {
    public static void main(String[] args) {
//5种整形的包装类Byte,Short,Integer,Long,Character的对象，
//在值小于127时可以使用常量池
        Integer i1 = 127;
        Integer i2 = 127;
        Sstem.out.println(i1 == i2); //输出true  
//值大于127时，不会从常量池中取对象
        Integer i3 = 128;
        Integer i4 = 128;
        System.out.println(i3 == i4); //输出false  
//Boolean类也实现了常量池技术
        Boolean bool1 = true;
        Boolean bool2 = true;
        System.out.println(bool1 == bool2); //输出true  
//浮点类型的包装类没有实现常量池技术
        Double d1 = 1.0;
        Double d2 = 1.0;
        System.out.println(d1 == d2); //输出false  
    }
}
```
**对Integer对象的代码补充**
```
 public static Integer valueOf(int i) {
        final int offset = 128;
        if (i >= -128 && i <= 127) {
            return IntegerCache.cache[i + offset];
        }
        return new Integer(i);
    }
```
当你直接给一个Integer对象一个int值的时候，其实它调用了valueOf方法，然后你赋的这个值很特别，是128，那么没有进行cache方法，相当于new了两个新对象。所以问题中定义a、b的两句代码就类似于：

```
Integer a = new Integer(128);

Integer b = new Integer(128);
```
这个时候再问你，输出结果是什么？你就知道是false了。如果把这个数换成127，再执行：

```
Integer a = 127;

Integer b = 127;

System.out.println(a == b);

结果就是：true
```
进行对象比较时最好还是使用equals，便于按照自己的目的进行控制。这里引出equals()和= =,equals比较的是字符串字面值即比较内容,==比较引用。

**看一下IntegerCache这个类里面的内容：**
```
private static class IntegerCache {
        private IntegerCache() {
        }

        static final Integer cache[] = new Integer[-(-128) + 127 + 1];

        static {
            for (int i = 0; i < cache.length; i++)
                cache[i] = new Integer(i - 128);
        }
    }
```
由于cache[]在IntegerCache类中是静态数组，也就是只需要初始化一次，即static{......}部分，所以，如果Integer 对象初始化时是-128~127的范围，就不需要再重新定义申请空间，都是同一个对象---在IntegerCache.cache中，这样可以在一定程度上提高效率。

**针对String方面的补充**

在同包同类下,引用自同一String对象.<br>
在同包不同类下,引用自同一String对象.<br>
在不同包不同类下,依然引用自同一String对象.<br>
在编译成.class时能够识别为同一字符串的,自动优化成常量,所以也引用自同一String对象.<br>
在运行时创建的字符串具有独立的内存地址,所以不引用自同一String对象.<br>
String的intern()方法会查找在常量池中是否存在一份equal相等的字符串,<br>
如果有则返回一个引用,没有则添加自己的字符串进入常量池，注意：只是字符串部分。 所以这时会存在2份拷贝，常量池的部分被String类私有并管理，自己的那份按对象生命周期继续使用。

在介绍完JVM常量池的相关概念后，接着谈开始提到的"haha"的值的内存分布的位置。对于haha的值，实际上是在class文件被JVM装载到内存 当中并被引擎在解析ldc指令并执行ldc指令之前，JVM就已经为haha这个字符串在常量池的CONSTANT_String_info表中分配了空 间来存储haha这个值。既然haha这个字符串常量存储在常量池中，根据《深入JAVA虚拟机》书中描述：常量池是属于类型信息的一部分，类型信息也就 是每一个被转载的类型，这个类型反映到JVM内存模型中是对应存在于JVM内存模型的方法区中，也就是这个类型信息中的常量池概念是存在于在方法区中，而 方法区是在JVM内存模型中的堆中由JVM来分配的。所以，haha的值是应该是存在堆空间中的。

而对于```String s = new String("haha")``` ,它的JVM指令：<br>

```
0:   new     #16; //class String 
3:   dup 
4:   ldc     #18; //String haha 
6:   invokespecial   #20; //Methodjava/lang/String."":(Ljava/lang/String;)V 
9:   astore_1 
10:  return
```
<br>
通过上面6个指令，可以看出，String s = new String("haha");中的haha存储在堆空间中，而s则是在操作数栈中。 
上面是对s和haha值的内存情况的分析和理解；那对于String s = new String("haha");语句,到底创建了几个对象呢? 
我的理解：这里"haha"本身就是常量池中的一个对象，而在运行时执行new String()时，将常量池中的对象复制一份放到堆中，并且把堆中的这个对象的引用交给s持有。所以这条语句就创建了2个String对象。如下图所示：<br>
<img src="http://static.open-open.com/lib/uploadImg/20121021/20121021191840_830.jpg">


**String 常量池问题的几个例子：**<br>
【1】
```
String a = "a1"; 
String b = "a" + 1; 
System.out.println((a == b)); //result = true 
String a = "atrue"; 
String b = "a" + "true"; 
System.out.println((a == b)); //result = true 
String a = "a3.4"; 
String b = "a" + 3.4; 
System.out.println((a == b)); //result = true
```
分析：JVM对于字符串常量的"+"号连接，将程序编译期，JVM就将常量字符串的"+"连接优化为连接后的值，拿"a" + 1来说，经编译器优化后在class中就已经是a1。在编译期其字符串常量的值就确定下来，故上面程序最终的结果都为true。<br>

【2】
```
String a = "ab"; 
String bb = "b"; 
String b = "a" + bb; 
System.out.println((a == b)); //result = false
```
分析：JVM对于字符串引用，由于在字符串的"+"连接中，有字符串引用存在，而引用的值在程序编译期是无法确定的，即"a" + bb无法被编译器优化，只有在程序运行期来动态分配并将连接后的新地址赋给b。所以上面程序的结果也就为false。

【3】
```

String a = "ab"; 
final String bb = "b"; 
String b = "a" + bb; 
System.out.println((a == b)); //result = true
```
分析：和[3]中唯一不同的是bb字符串加了final修饰，对于final修饰的变量，它在编译时被解析为常量值的一个本地拷贝存储到自己的常量池中或 嵌入到它的字节码流中。所以此时的"a" + bb和"a" + "b"效果是一样的。故上面程序的结果为true。

【4】
```
String a = "ab"; 
final String bb = getBB(); 
String b = "a" + bb; 
System.out.println((a == b)); //result = false 
private static String getBB() { 
return "b"; 
}
```
分析：JVM对于字符串引用bb，它的值在编译期无法确定，只有在程序运行期调用方法后，将方法的返回值和"a"来动态连接并分配地址为b，故上面程序的结果为false。


通过上面4个例子可以得出得知：<br>
```
String  s  =  "a" + "b" + "c";等价于String s = "abc"

这个就不一样了，最终结果等于:
StringBuffer temp = new StringBuffer();
temp.append(a).append(b).append(c);
String s = temp.toString();
```
由上面的分析结果，可就不难推断出String 采用连接运算符（+）效率低下原因分析，形如这样的代码：
```
 public static void main(String args[]) {
        String s = null;
        for (int i = 0; i < 100; i++) {
            s += "a";
        }
    }
```

每做一次 + 就产生个StringBuilder对象，然后append后就扔掉。下次循环再到达时重新产生个StringBuilder对象，然后 append 字符串，如此循环直至结束。 如果我们直接采用 StringBuilder 对象进行 append 的话，我们可以节省 N - 1 次创建和销毁对象的时间。所以对于在循环中要进行字符串连接的应用，一般都是用StringBuffer或StringBulider对象来进行 append操作。

最后贴一个String对象的intern方法理解和分析，这是今天在群里看到的一个题目，也可以说是这篇博客的印子吧：
```
public class Test {
    private static String a = "ab";
    public static void main(String[] args) {
        String s1 = "a";
        String s2 = "b";
        String s = s1 + s2;
        System.out.println(s == a);//false  
        System.out.println(s.intern() == a);//true  
    }
}
```



