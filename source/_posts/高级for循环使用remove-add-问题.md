---
title: 高级for循环使用remove/add 问题
date: 2017-02-18 21:43:31
categories: Java二三事
tags: 
	- Java
---
今天在高级for循环中用了一下remove发现报错，写了个demo测试看：
```
 List<String> a = new ArrayList<String>();
 a.add("1");
 a.add("2");
 for (String temp : a) {
     if("1".equals(temp)){
         a.remove(temp);
} }
```
<!--more-->
此时代码是没有问题的，运行正常；但是把"1".equals(temp)换成"2".equals(temp)之后，问题就出来了！

```
Exception in thread "main" java.util.ConcurrentModificationException
	at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:901)
	at java.util.ArrayList$Itr.next(ArrayList.java:851)
	at main.exam.ForeachTest.main(ForeachTest.java:15)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:497)
	at com.intellij.rt.execution.application.AppMain.main(AppMain.java:147)
```

 报了这么一堆异常。


自己想了想画了个图：

![这里写图片描述](http://img.blog.csdn.net/20161229172604530)

看图就明白了，**该list每当删除一个元素时，集合的size方法的值都会减小1,这将直接导致集合中元素的索引重新排序**，进一步说，就是剩余所有元素的索引值都减1，正如上图所示，而for循环语句的局部变量i仍然在递增，这将导致删除操作发生跳跃。从而导致上述代码还有删除的问题。

所以<font color="red">不要在 foreach 循环里进行元素的 remove/add 操作。remove 元素请使用 Iterator 方式，如果并发操作，需要对 Iterator 对象加锁。</font>如下：

```
Iterator<String> it = a.iterator(); while(it.hasNext()){
String temp = it.next(); if(删除元素的条件){
        it.remove();
       }
}
```

