---
title: JVM虚拟机关于“不使用的对象手动赋值为null”的理解
date: 2017-02-18 16:03:12
categories: Java二三事
tags: 
	- Java
	- Jvm
	- 对象
---
今天逛博客,看到了一个关于<code>一个对象有没有必要手动赋值为null</code>的问题，捋了捋思路，决定写个测试代码来实践一下。
<!--more--><br><br>
百说不如一用，直接上代码:<br>
```
public class Test1 {

	public static void main(String[] args) {
		byte[] bytes = new byte[64 * 1024 * 1024];//作用就是向内存中填充一个10MB的对象
		System.gc();//手动执行GC操作
	}

}
```
运行程序前，可以将JVM参数设置为如下:<br>
-verbose:gc<br>
-XX:+PrintGCDetails<br>
控制台部分输出结果如下:<br>
```
[GC (System.gc()) [PSYoungGen: 3932K->744K(76288K)] 69468K->66288K(251392K), 0.0016500 secs] [Times: user=0.00 sys=0.03, real=0.00 secs] 
[Full GC (System.gc()) [PSYoungGen: 744K->0K(76288K)] [ParOldGen: 65544K->66145K(175104K)] 66288K->66145K(251392K), [Metaspace: 3169K->3169K(1056768K)], 0.0101306 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
```

根据ParOldGen: 65544K->66145K(175104K)可以看出，bytes对象并没有因为没有使用而被gc回收。
<br>
```
public class Test2 {
	/**
	 * -verbose:GC
	 * -XX:+PrintGCDetails
	 * @param args
	 */
	public static void main(String[] args) {
		{
	           byte[] bytes = new byte[64 * 1024 * 1024];
		}
		System.gc();
	}

}
```
控制台输出结果如下:
```
[GC (System.gc()) [PSYoungGen: 3932K->776K(76288K)] 69468K->66320K(251392K), 0.0013737 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (System.gc()) [PSYoungGen: 776K->0K(76288K)] [ParOldGen: 65544K->66145K(175104K)] 66320K->66145K(251392K), [Metaspace: 3169K->3169K(1056768K)], 0.0063873 secs] [Times: user=0.00 sys=0.00, real=0.01 secs] 
Heap
 PSYoungGen      total 76288K, used 655K [0x000000076b500000, 0x0000000770a00000, 0x00000007c0000000)
  eden space 65536K, 1% used [0x000000076b500000,0x000000076b5a3ee8,0x000000076f500000)
  from space 10752K, 0% used [0x000000076f500000,0x000000076f500000,0x000000076ff80000)
  to   space 10752K, 0% used [0x000000076ff80000,0x000000076ff80000,0x0000000770a00000)
 ParOldGen       total 175104K, used 66145K [0x00000006c1e00000, 0x00000006cc900000, 0x000000076b500000)
  object space 175104K, 37% used [0x00000006c1e00000,0x00000006c5e987b8,0x00000006cc900000)
 Metaspace       used 3176K, capacity 4494K, committed 4864K, reserved 1056768K
  class space    used 346K, capacity 386K, committed 512K, reserved 1048576K
```
可以看出，根据gc日志[ParOldGen: 65544K->66145K(175104K)] ，gc依然没有回收bytes对象，哪怕已经不在方法区了，我们再次修改代码。
```
public class Test3 {
	/**
	 * -verbose:GC
	 * -XX:+PrintGCDetails
	 * @param args
	 */
	public static void main(String[] args) {
		{
			byte[] bytes = new byte[64 * 1024 * 1024];
		}
		int i = 1;
		System.gc();
	}

}
```
gc日志输出如下:
```
[GC (System.gc()) [PSYoungGen: 3932K->776K(76288K)] 69468K->66320K(251392K), 0.0014193 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
[Full GC (System.gc()) [PSYoungGen: 776K->0K(76288K)] [ParOldGen: 65544K->609K(175104K)] 66320K->609K(251392K), [Metaspace: 3169K->3169K(1056768K)], 0.0076485 secs] [Times: user=0.02 sys=0.00, real=0.01 secs] 
Heap
 PSYoungGen      total 76288K, used 655K [0x000000076b500000, 0x0000000770a00000, 0x00000007c0000000)
  eden space 65536K, 1% used [0x000000076b500000,0x000000076b5a3ee8,0x000000076f500000)
  from space 10752K, 0% used [0x000000076f500000,0x000000076f500000,0x000000076ff80000)
  to   space 10752K, 0% used [0x000000076ff80000,0x000000076ff80000,0x0000000770a00000)
 ParOldGen       total 175104K, used 609K [0x00000006c1e00000, 0x00000006cc900000, 0x000000076b500000)
  object space 175104K, 0% used [0x00000006c1e00000,0x00000006c1e987a8,0x00000006cc900000)
 Metaspace       used 3176K, capacity 4494K, committed 4864K, reserved 1056768K
  class space    used 346K, capacity 386K, committed 512K, reserved 1048576K
```
见证奇迹的时候到，[ParOldGen: 65544K->609K(175104K)]，竟然被回收了！这是为什么？当创建bytes对象的时候，那是因为当我们创建bytes对象的时候，局部变量表中当然有bytes的引用，哪怕我们没有使用，但GC roots依然存在着和bytes对象的关联。根据test2和代码test3，我们大概可以猜到如果不操作局部变量表，那么GC roots依然会保留，所以test2依然没有回收，但是到了test3，就回收了。好吧，再来一个无用的测试，我们手动赋值为null看看结果。
<br>
```
public class TestMain {
	/**
	 * -verbose:GC
	 * -XX:+PrintGCDetails
	 * @param args
	 */
	public static void main(String[] args) {
		byte[] bytes = new byte[64 * 1024 * 1024];
		//do something
		bytes = null;
		System.gc();
	}

}
```
其实都能想到，果然被gc干掉了……当然这只是一个实验，总结性的话就不说了，反正我也说不来，不过实践出真理！

