---
title: HashMap面试题总结！
date: 2017-02-18 21:39:13
categories: Java二三事
tags:
	- Java
	- 集合
---
**HashTable和HashMap的区别有哪些？**

HashMap和Hashtable都实现了Map接口，但决定用哪一个之前先要弄清楚它们之间的分别。主要的区别有：线程安全性，同步(synchronization)，以及速度。

理解HashMap是Hashtable的轻量级实现（非线程安全的实现，hashtable是非轻量级，线程安全的），都实现Map接口，主要区别在于：
<!--more-->
1、由于HashMap非线程安全，在只有一个线程访问的情况下，效率要高于HashTable

2、HashMap允许将null作为一个entry的key或者value，而Hashtable不允许。

3、HashMap把Hashtable的contains方法去掉了，改成containsValue和containsKey。因为contains方法容易让人引起误解。

4、Hashtable继承自陈旧的Dictionary类，而HashMap是Java1.2引进的Map 的一个实现。

5、Hashtable和HashMap扩容的方法不一样，HashTable中hash数组默认大小11，扩容方式是 old*2+1。HashMap中hash数组的默认大小是16，而且一定是2的指数，增加为原来的2倍，没有加1。

6、两者通过hash值散列到hash表的算法不一样，HashTbale是古老的除留余数法，直接使用hashcode，而后者是强制容量为2的幂，重新根据hashcode计算hash值，在使用hash 位与 （hash表长度 – 1），也等价取膜，但更加高效，取得的位置更加分散，偶数，奇数保证了都会分散到。前者就不能保证。

7、另一个区别是HashMap的迭代器(Iterator)是fail-fast迭代器，而Hashtable的enumerator迭代器不是fail-fast的。所以当有其它线程改变了HashMap的结构（增加或者移除元素），将会抛出ConcurrentModificationException，但迭代器本身的remove()方法移除元素则不会抛出ConcurrentModificationException异常。但这并不是一个一定发生的行为，要看JVM。这条同样也是Enumeration和Iterator的区别。
<li>fail-fast和iterator迭代器相关。如果某个集合对象创建了Iterator或者ListIterator，然后其它的线程试图“结构上”更改集合对象，将会抛出ConcurrentModificationException异常。但其它线程可以通过set()方法更改集合对象是允许的，因为这并没有从“结构上”更改集合。但是假如已经从结构上进行了更改，再调用set()方法，将会抛出IllegalArgumentException异常。</li>

<li>结构上的更改指的是删除或者插入一个元素，这样会影响到map的结构。</li>

<li>该条说白了就是在使用迭代器的过程中有其他线程在结构上修改了map，那么将抛出ConcurrentModificationException，这就是所谓fail-fast策略。</li>
<br>
**为什么HashMap是线程不安全的，实际会如何体现？**

第一，如果多个线程同时使用put方法添加元素

假设正好存在两个put的key发生了碰撞(hash值一样)，那么根据HashMap的实现，这两个key会添加到数组的同一个位置，这样最终就会发生其中一个线程的put的数据被覆盖。

第二，如果多个线程同时检测到元素个数超过数组大小*loadFactor

这样会发生多个线程同时对hash数组进行扩容，都在重新计算元素位置以及复制数据，但是最终只有一个线程扩容后的数组会赋给table，也就是说其他线程的都会丢失，并且各自线程put的数据也丢失。且会引起死循环的错误。

具体细节上的原因，可以参考：[不正当使用HashMap导致cpu 100%的问题追究](http://ifeve.com/hashmap-infinite-loop/)

<br>
**能否让HashMap实现线程安全，如何做？**

1、直接使用Hashtable，但是当一个线程访问HashTable的同步方法时，其他线程如果也要访问同步方法，会被阻塞住。举个例子，当一个线程使用put方法时，另一个线程不但不可以使用put方法，连get方法都不可以，效率很低，现在基本不会选择它了。

2、HashMap可以通过下面的语句进行同步：

```
Collections.synchronizeMap(hashMap);
```

3、直接使用JDK 5 之后的 ConcurrentHashMap，如果使用Java 5或以上的话，请使用ConcurrentHashMap。

<br>
**Collections.synchronizeMap(hashMap);又是如何保证了HashMap线程安全？**

直接分析源码吧

```
// synchronizedMap方法
public static <K,V> Map<K,V> synchronizedMap(Map<K,V> m) {
       return new SynchronizedMap<>(m);
   }
// SynchronizedMap类
private static class SynchronizedMap<K,V>
       implements Map<K,V>, Serializable {
       private static final long serialVersionUID = 1978198479659022715L;
 
       private final Map<K,V> m;     // Backing Map
       final Object      mutex;        // Object on which to synchronize
 
       SynchronizedMap(Map<K,V> m) {
           this.m = Objects.requireNonNull(m);
           mutex = this;
       }
 
       SynchronizedMap(Map<K,V> m, Object mutex) {
           this.m = m;
           this.mutex = mutex;
       }
 
       public int size() {
           synchronized (mutex) {return m.size();}
       }
       public boolean isEmpty() {
           synchronized (mutex) {return m.isEmpty();}
       }
       public boolean containsKey(Object key) {
           synchronized (mutex) {return m.containsKey(key);}
       }
       public boolean containsValue(Object value) {
           synchronized (mutex) {return m.containsValue(value);}
       }
       public V get(Object key) {
           synchronized (mutex) {return m.get(key);}
       }
 
       public V put(K key, V value) {
           synchronized (mutex) {return m.put(key, value);}
       }
       public V remove(Object key) {
           synchronized (mutex) {return m.remove(key);}
       }
       // 省略其他方法
   }
```

从源码中看出 synchronizedMap()方法返回一个SynchronizedMap类的对象，而在SynchronizedMap类中使用了synchronized来保证对Map的操作是线程安全的，故效率其实也不高。

<br>
**为什么HashTable的默认大小和HashMap不一样？**

前面分析了，Hashtable 的扩容方法是乘2再+1，不是简单的乘2，故hashtable保证了容量永远是奇数，结合之前分析hashmap的重算hash值的逻辑，就明白了，因为在数据分布在等差数据集合(如偶数)上时，如果公差与桶容量有公约数 n，则至少有(n-1)/n 数量的桶是利用不到的，故之前的hashmap 会在取模（使用位与运算代替）哈希前先做一次哈希运算，调整hash值。这里hashtable比较古老，直接使用了除留余数法，那么就需要设置容量起码不是偶数（除（近似）质数求余的分散效果好）。而JDK开发者选了11。

<font color="red">感觉针对Java的hashmap和hashtable面试，或者理解，到这里就可以了，具体就是多写代码实践。</font>