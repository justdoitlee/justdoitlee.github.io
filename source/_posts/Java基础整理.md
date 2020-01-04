---
title: Java基础整理
date: 2019-12-26 14:19:33
categories: Java二三事
tags: 
	- Java
---

#### 1.0 JAVA中的几种基本数据类型是什么，各自占用多少字节。

Java语言提供了八种基本类型。六种数字类型（四个整数型，两个浮点型），一种字符类型，还有一种布尔型。

##### **byte：** 

byte 数据类型是8位、有符号的，以二进制补码表示的整数；最小值是 -128（-2^7）；最大值是 127（2^7-1）；默认值是 0；byte 类型用在大型数组中节约空间，主要代替整数，因为 byte 变量占用的空间只有 int 类型的四分之一；例子：`byte a = 100，byte b = -50`。

##### **short：**

short 数据类型是 16 位、有符号的以二进制补码表示的整数最小值是 -32768（-2^15）；最大值是 32767（2^15 - 1）；Short 数据类型也可以像 byte 那样节省空间。一个short变量是int型变量所占空间的二分之一；默认值是 0；例子：`short s = 1000，short r = -20000`。

##### **int：**

int 数据类型是32位、有符号的以二进制补码表示的整数；最小值是 -2,147,483,648（-2^31）；最大值是 2,147,483,647（2^31 - 1）；一般地整型变量默认为 int 类型；默认值是 0 ；例子：`int a = 100000, int b = -200000`。

##### **long：**

long 数据类型是 64 位、有符号的以二进制补码表示的整数；最小值是 -9,223,372,036,854,775,808（-2^63）；最大值是 9,223,372,036,854,775,807（2^63 -1）；这种类型主要使用在需要比较大整数的系统上；默认值是 0L；例子：` long a = 100000L，Long b = -200000L`。"L"理论上不分大小写，但是若写成"l"容易与数字"1"混淆，不容易分辩。所以最好大写。

##### **float：**

float 数据类型是单精度、32位、符合IEEE 754标准的浮点数；float 在储存大型浮点数组的时候可节省内存空间；默认值是 0.0f；浮点数不能用来表示精确的值，如货币；例子：`float f1 = 234.5f`。

##### **double：**

double 数据类型是双精度、64 位、符合IEEE 754标准的浮点数；浮点数的默认类型为double类型；double类型同样不能表示精确的值，如货币；默认值是 0.0d；例子：`double d1 = 123.4`。

##### **boolean：**

boolean数据类型表示一位的信息；只有两个取值：true 和 false；这种类型只作为一种标志来记录 true/false 情况；默认值是 false；例子：`boolean one = true`。

##### **char：**

char类型是一个单一的 16 位 Unicode 字符；最小值是 \u0000（即为0）；最大值是 \uffff（即为65,535）；char 数据类型可以储存任何字符；例子：`char letter = 'A';`。

<!--more-->

#### 1.1 String类能被继承吗，为什么。

不能

大白话解释就是：String很多实用的特性，比如说“不可变性”，是工程师精心设计的艺术品！艺术品易碎！用final就是拒绝继承，防止世界被熊孩子破坏，维护世界和平！

PS：String基本约定中最重要的一条是immutable，声明String为final 和immutable虽然没有必然关系，但是假如String没有声明为final, 那么StringChilld就有可能是被复写为mutable的，这样就打破了成为共识的基本约定。要知道，String是几乎每个类都会使用的类，特别是作为Hashmap之类的集合的key值时候，mutable的String有非常大的风险。而且一旦发生，非常难发现。声明String为final一劳永逸。

[Why String is Immutable or Final in Java](https://javarevisited.blogspot.com/2010/10/why-string-is-immutable-or-final-in-java.html)

#### 1.2 String，Stringbuffer，StringBuilder的区别。

##### **可变性**

String是不可变的，它使用final关键词修饰

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final char value[];
...................
```

StringBuffer和StringBuilder两者都是继承自AbstractStringBuilder,AbstractStringBuilder也是用字符数组保存char value[]，但是没有用final修饰，所以这两种对象是可变的

```java
public final class StringBuffer
    extends AbstractStringBuilder

abstract class AbstractStringBuilder implements Appendable, CharSequence {
    /**
     * The value is used for character storage.
     */
    char[] value;
```

##### **线程安全性**

String的对象不可变，也就是常量，所以线程安全

StringBuffer重写了AbstractStringBuilder的方法，比如append、insert等并且加了同步锁，所以是线程安全的

```java
@Override
    public synchronized int length() {
        return count;
    }

    @Override
    public synchronized int capacity() {
        return value.length;
    }


    @Override
    public synchronized void ensureCapacity(int minimumCapacity) {
        super.ensureCapacity(minimumCapacity);
    }
```

而StringBuilder就没加同步锁，所以是非线程安全的

##### **性能**

每次修改String的值都会重新生成一个新的String对象，然后再将指针指向新的String对象，StringBuffer和StringBuilder每次都是对象本身进行操作，而不是生成新的对象。StringBuilder的性能会比StringBuffer好一点，不过却要冒多线程不安全的风险

##### **总结**

- 数据量少多用String
- 单线程操作大量数据用StringBuilder
- 多线程操作大量数据用StringBuffer

#### 1.3 ArrayList和LinkedList有什么区别。

ArrayList的实现用的是数组，LinkedList是基于链表，ArrayList适合查找，LinkedList适合增删

##### ArrayList

ArrayList：内部使用数组的形式实现了存储，实现了RandomAccess接口，利用数组的下标进行元素的访问，因此对元素的随机访问速度非常快。

因为是数组，所以ArrayList在初始化的时候，有初始大小10，插入新元素的时候，会判断是否需要扩容，扩容的步长是0.5倍原容量，扩容方式是利用数组的复制，因此有一定的开销；

另外，ArrayList在进行元素插入的时候，需要移动插入位置之后的所有元素，位置越靠前，需要位移的元素越多，开销越大，相反，插入位置越靠后的话，开销就越小了，如果在最后面进行插入，那就不需要进行位移；

##### LinkedList

LinkedList：内部使用双向链表的结构实现存储，LinkedList有一个内部类作为存放元素的单元，里面有三个属性，用来存放元素本身以及前后2个单元的引用，另外LinkedList内部还有一个header属性，用来标识起始位置，LinkedList的第一个单元和最后一个单元都会指向header，因此形成了一个双向的链表结构。

LinkedList是采用双向链表实现的。所以它也具有链表的特点，每一个元素（结点）的地址不连续，通过引用找到当前结点的上一个结点和下一个结点，即插入和删除效率较高，只需要常数时间，而get和set则较为低效。

 LinkedList的方法和使用和ArrayList大致相同，由于LinkedList是链表实现的，所以额外提供了在头部和尾部添加/删除元素的方法，也没有ArrayList扩容的问题了。另外，ArrayList和LinkedList都可以实现栈、队列等数据结构，但LinkedList本身实现了队列的接口，所以更推荐用LinkedList来实现队列和栈。

综上所述，在需要频繁读取集合中的元素时，使用ArrayList效率较高，而在插入和删除操作较多时，使用LinkedList效率较高。

#### 1.4 讲讲类的实例化顺序，比如父类静态数据，构造函数，字段，子类静态数据，构造函数，字段，当new的时候，他们的执行顺序。

初始化顺序：父类static静态变量 > 父类static代码块 > 子类static静态变量 > 子类static代码块 > 父类变量 > 父类实例代码块 > 父类构造函数 > 子类变量 > 子类实例代码块 > 子类构造函数

#### 1.5 用过哪些Map类，都有什么区别，HashMap是线程安全的吗,并发下使用的Map是什么，他们内部原理分别是什么，比如存储方式，hashcode，扩容，默认容量等。

最常用的Map实现类有:HashMap，ConcurrentHashMap（jdk1.8），LinkedHashMap，TreeMap,HashTable；

其中最频繁的是HashMap和ConcurrentHashMap，他们的主要区别是HashMap是非线程安全的。ConcurrentHashMap是线程安全的。并发下可以使用ConcurrentHashMap和HashTable

**1.HashMap**

- 存储原理就是散列表

  散列函数的设计不能太复杂，生成的值要尽可能随机并且均匀分布

  HashMap使用高低16位异或对数组长度取余符合这个规则：

```java
static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

- 散列冲突
  HashMap使用链表解决Hash冲突，相较开放寻址法更加节约内存，而且方便通过其它数据结构进行优化，比如JDK1.8就是使用红黑树优化，防止Hash攻击。
- 动态扩容
  HashMap的默认阈值是0.75，数组长度默认是16，以2的倍数增长，方便取余，美中不足的是，HashMap的扩容是一步到位的，虽然均摊时间复杂度不高，但是可能扩容的那次put会比较慢，可以考虑高效扩容（装载因子触达阈值时，只申请新空间，不搬运数据，之后每插入一个新数据我们从旧散列表拿一个旧数据放到新散列表，可以在新散列表到达阈值前搬运完毕，利用了扩容后装载因子减半的特性。）；



**2.ConcurrentHashMap和hashtable的区别**

- ConcurrentHashMap的hash计算公式：(key.hascode()^ (key.hascode()>>> 16)) & 0x7FFFFFFF

  HashTable的hash计算公式：key.hascode()& 0x7FFFFFFF

- HashTable存储方式都是链表+数组，数组里面放的是当前hash的第一个数据，链表里面放的是hash冲突的数据

  ConcurrentHashMap是数组+链表+红黑树

- 默认容量都是16，负载因子是0.75。就是当hashmap填充了75%的busket是就会扩容，最小的可能性是（16*0.75），一般为原内存的2倍

- 线程安全的保证：HashTable是在每个操作方法上面加了synchronized来达到线程安全，ConcurrentHashMap线程是使用CAS(compore and swap)来保证线程安全的

- ConcurrentHashMap内部原理

  **1.7：** put 加锁

  通过分段加锁 segment，put 数据时通过 hash(key) 得到该元素要添加到的 segment，对 segment 进行加锁，进行再 hash 得到该元素要添加到的桶，遍历桶中的链表，替换或新增节点到桶中。

  **1.8：** put CAS 加锁

  1.8 中仍然有 segment 的定义，但不再有任何结构上的用处，segment 数量与桶数量一致，不依赖于 segment 加锁。

  首先，判断容器是否为空，如果为空则进行初始化，否则重试对 hash(key) 计算得到该 key 存放的桶位置，判断该桶是否为空，为空则利用 CAS 设置新节点，否则使用 synchronized 加锁，遍历桶中数据，替换或新增加节点到桶中，最后判断是否需要转为红黑树，转换之前判断是否需要扩容。



**3.HashMap细节**

构造参数传进的初始化容量是怎么“向上取整”的？
通过 n |= n >>> (1,2,4,8,16)的方式，使得低位全部填满1，最后再+1就是我们说的数组长度是2的幂。

```java
/**
     * Returns a power of two size for the given target capacity.
     */
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

JDK1.8，并发编程不再死循环
旧的HashMap扩容的时候链是反过来的，比如说本来是a->b->c，先取a放到新的数组，再取b放过去就成了b->a，加上c就是c->b->a，可以看见引用反过来了，并发编程的时候，容易造成循环引用，也就是老生常谈的死循环。
到了1.8就不这么干了，通过`(e.hash & oldCap) == 0`去区分扩容后新节点位置可以说是非常精妙了，我是愣了一下才想明白，然后分两条链，顺序的，比如说原来时a->b->c-d，分开之后可能就变成a->c和a->d，这样依赖就不存在循环引用了，而且还最大程度维护了原来的顺序。
不过这个死循环BUG是因为会强占太多CPU资源被重视，而后又被妖魔化，HashMap本来就不是并发编程的容器，用在并发编程上总会有各种各样的问题，所以在这点上研究价值大于实用价值，毕竟没谁会直接在并发编程下怼一个HashMap上去吧。

```java
Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
```

put()操作的伪代码

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

尝试用伪代码表达它的逻辑：

```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {

        if (第一次添加元素)
              扩容成默认的初始大小

        if (如果对应坑位是null)
            直接怼上去;
        else {
           
            if (坑位上的key跟我要加进去的key相同)
                e=那个节点;
            else if (如果下面挂着的是一个课红黑树)
                e = 一顿操作把修改节点返回来，如果是新插入就返回null;
            else {
                for (循环遍历链上的节点) {
                    if (找到最后的空位null) {
                        怼上去;
                        if (如果达到红黑树节点数的临界值) 
                            转换成红黑树;
                        break;
                    }
                    if (没到null之前的某个节点key相同)
                        break;
                    p = e;
                }
            }
            if (如果插入节点是本来就存在的（e!=null）) { // existing mapping for key
                换新值
                把旧值返回去
            }
        }
        操作数+1
        if (扩容检测)
           扩容;
        没有旧值返回null;
    }
```



#### 1.6 JAVA8的ConcurrentHashMap为什么放弃了分段锁，有什么问题吗，如果你来设计，你如何设计。

##### **弃用原因**

通过  JDK 的源码和官方文档看来， 他们认为的弃用分段锁的原因由以下几点：

1. 加入多个分段锁浪费内存空间。
2. 生产环境中， map 在放入时竞争同一个锁的概率非常小，分段锁反而会造成更新等操作的长时间等待。
3. 为了提高 GC 的效率

**PS：关于Segment**

ConcurrentHashMap有3个参数：

1. initialCapacity：初始总容量，默认16
2. loadFactor：加载因子，默认0.75
3. concurrencyLevel：并发级别，默认16

其中并发级别控制了Segment的个数，在一个ConcurrentHashMap创建后Segment的个数是不能变的，扩容过程过改变的是每个Segment的大小。

**PS:关于分段锁**

段Segment继承了重入锁ReentrantLock，有了锁的功能，每个锁控制的是一段，当每个Segment越来越大时，锁的粒度就变得有些大了。

- 分段锁的优势在于保证在操作不同段 map 的时候可以并发执行，操作同段 map 的时候，进行锁的竞争和等待。这相对于直接对整个map同步synchronized是有优势的。
- 缺点在于分成很多段时会比较浪费内存空间(不连续，碎片化); 操作map时竞争同一个分段锁的概率非常小时，分段锁反而会造成更新等操作的长时间等待; 当某个段很大时，分段锁的性能会下降。

##### **新的同步方案**

既然弃用了分段锁， 那么一定由新的线程安全方案， 我们来看看源码是怎么解决线程安全的呢？（源码保留了segment 代码， 但并没有使用，只是为了兼容旧版本）

和hashmap一样,jdk 1.8中ConcurrentHashmap采用的底层数据结构为数组+链表+红黑树的形式。数组可以扩容，链表可以转化为红黑树。

**什么时候扩容？**

- 当前容量超过阈值
- 当链表中元素个数超过默认设定（8个），当数组的大小还未超过64的时候，此时进行数组的扩容，如果超过则将链表转化成红黑树

**什么时候链表转化为红黑树？**

当数组大小已经超过64并且链表中的元素个数超过默认设定（8个）时，将链表转化为红黑树

**put**

首先通过 hash 找到对应链表过后， 查看是否是第一个object， 如果是， 直接用cas原则插入，无需加锁。

```java
Node<K,V> f; int n, i, fh; K fk; V fv;
if (tab == null || (n = tab.length) == 0)
    tab = initTable(); // 这里在整个map第一次操作时，初始化hash桶， 也就是一个table
else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
//如果是第一个object， 则直接cas放入， 不用锁
    if (casTabAt(tab, i, null, new Node<K,V>(hash, key, value)))
        break;                   
}
```

然后， 如果不是链表第一个object， 则直接用链表第一个object加锁，这里加的锁是synchronized，虽然效率不如 ReentrantLock， 但节约了空间，这里会一直用第一个object为锁， 直到重新计算map大小， 比如扩容或者操作了第一个object为止。

```java
synchronized (f) {// 这里的f即为第一个链表的object
    if (tabAt(tab, i) == f) {
        if (fh >= 0) {
            binCount = 1;
            for (Node<K,V> e = f;; ++binCount) {
                K ek;
                if (e.hash == hash &&
                    ((ek = e.key) == key ||
                     (ek != null && key.equals(ek)))) {
                    oldVal = e.val;
                    if (!onlyIfAbsent)
                        e.val = value;
                    break;
                }
                Node<K,V> pred = e;
                if ((e = e.next) == null) {
                    pred.next = new Node<K,V>(hash, key, value);
                    break;
                }
            }
        }
        else if (f instanceof TreeBin) { // 太长会用红黑树
            Node<K,V> p;
            binCount = 2;
            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                           value)) != null) {
                oldVal = p.val;
                if (!onlyIfAbsent)
                    p.val = value;
            }
        }
        else if (f instanceof ReservationNode)
            throw new IllegalStateException("Recursive update");
    }
}
```

**为什么不用ReentrantLock而用synchronized ?**

- 减少内存开销:如果使用ReentrantLock则需要节点继承AQS来获得同步支持，增加内存开销，而1.8中只有头节点需要进行同步。
- 内部优化:synchronized则是JVM直接支持的，JVM能够在运行时作出相应的优化措施：锁粗化、锁消除、锁自旋等等。

#### 1.7 有没有有顺序的Map实现类，如果有，他们是怎么保证有序的。

TreeMap和LinkedHashMap是有序的（TreeMap默认升序，LinkedHashMap则记录了插入顺序）。

**HashMap**:

​        put -> addEntry(新建一个Entry)

​        get

​        getEntry

 

**LinkedHashMap**:

​       put -> addEntry(重写)

​                新建一个Entry,然后将其加入header前

​                e.addBefore(header)

​       get -> 调用HashMap的getEntry - recordAccess(重写)

 

**HashMap的get与getEntry**

```java
final Entry<K,V> getEntry(Object key) {
        int hash = (key == null) ? 0 : hash(key.hashCode());
        for (Entry<K,V> e = table[indexFor(hash, table.length)];
             e != null;
             e = e.next) {
            Object k;
            if (e.hash == hash &&
                ((k = e.key) == key || (key != null && key.equals(k))))
                return e;
        }
        return null;
    }
	
	
	public V get(Object key) {
        if (key == null)
            return getForNullKey();
        int hash = hash(key.hashCode());
        for (Entry<K,V> e = table[indexFor(hash, table.length)];
             e != null;
             e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k)))
                return e.value;
        }
        return null;
    }
```

1. LinkedHashMap概述：

LinkedHashMap是HashMap的一个子类，它**保留插入的顺序**，如果需要输出的顺序和输入时的相同，那么就选用LinkedHashMap。

LinkedHashMap是Map接口的哈希表和链接列表实现，具有可预知的迭代顺序。此实现提供所有可选的映射操作，并**允许使用null值和null键**。此类不保证映射的顺序，特别是它**不保证该顺序恒久不变**。
LinkedHashMap实现与HashMap的不同之处在于，后者维护着一个运行于所有条目的双重链接列表。此链接列表定义了迭代顺序，该迭代顺序可以是插入顺序或者是访问顺序。
注意，此实现不是同步的。如果多个线程同时访问链接的哈希映射，而其中至少一个线程从结构上修改了该映射，则它必须保持外部同步。

 

根据链表中元素的顺序可以分为：**按插入顺序的链表，和按访问顺序(调用get方法)的链表。**  

默认是按插入顺序排序，如果指定按访问顺序排序，那么调用get方法后，会将这次访问的元素移至链表尾部，不断访问可以形成按访问顺序排序的链表。  可以重写removeEldestEntry方法返回true值指定插入元素时移除最老的元素。 

 

2. LinkedHashMap的实现：

对于LinkedHashMap而言，它继承与HashMap、底层使用哈希表与双向链表来保存所有元素。其基本操作与父类HashMap相似，它通过重写父类相关的方法，来实现自己的链接列表特性。下面我们来分析LinkedHashMap的源代码：

**类结构：**

```java
public class LinkedHashMap<K, V> extends HashMap<K, V> implements Map<K, V>  
```

 1) 成员变量：

LinkedHashMap采用的hash算法和HashMap相同，但是它重新定义了数组中保存的元素Entry，该Entry除了保存当前对象的引用外，还保存了其上一个元素before和下一个元素after的引用，从而在哈希表的基础上又构成了双向链接列表。看源代码：

```java
//true表示按照访问顺序迭代，false时表示按照插入顺序
 private final boolean accessOrder;
 /** 
 * 双向链表的表头元素。 
 */  
private transient Entry<K,V> header;  
  
/** 
 * LinkedHashMap的Entry元素。 
 * 继承HashMap的Entry元素，又保存了其上一个元素before和下一个元素after的引用。 
 */  
private static class Entry<K,V> extends HashMap.Entry<K,V> {  
    Entry<K,V> before, after;  
    ……  
}  
```

HashMap.Entry:

```java
static class Entry<K,V> implements Map.Entry<K,V> {
        final K key;
        V value;
        Entry<K,V> next;
        final int hash;

        Entry(int h, K k, V v, Entry<K,V> n) {
            value = v;
            next = n;
            key = k;
            hash = h;
        }
}
```



 2) 初始化：

通过源代码可以看出，在LinkedHashMap的构造方法中，实际调用了父类HashMap的相关构造方法来构造一个底层存放的table数组。如：

```java
public LinkedHashMap(int initialCapacity, float loadFactor) {  
    super(initialCapacity, loadFactor);  
    accessOrder = false;  
}  
```

 HashMap中的相关构造方法：

```java
public HashMap(int initialCapacity, float loadFactor) {  
    if (initialCapacity < 0)  
        throw new IllegalArgumentException("Illegal initial capacity: " +  
                                           initialCapacity);  
    if (initialCapacity > MAXIMUM_CAPACITY)  
        initialCapacity = MAXIMUM_CAPACITY;  
    if (loadFactor <= 0 || Float.isNaN(loadFactor))  
        throw new IllegalArgumentException("Illegal load factor: " +  
                                           loadFactor);  
  
    // Find a power of 2 >= initialCapacity  
    int capacity = 1;  
    while (capacity < initialCapacity)  
        capacity <<= 1;  
  
    this.loadFactor = loadFactor;  
    threshold = (int)(capacity * loadFactor);  
    table = new Entry[capacity];  
    init();  
}  
```

我们已经知道LinkedHashMap的Entry元素继承HashMap的Entry，提供了双向链表的功能。在上述HashMap的构造器中，最后会调用init()方法，进行相关的初始化，这个方法在HashMap的实现中并无意义，只是提供给子类实现相关的初始化调用。   

LinkedHashMap重写了init()方法，在调用父类的构造方法完成构造后，进一步实现了对其元素Entry的初始化操作。

```java
void init() {  
    header = new Entry<K,V>(-1, null, null, null);  
    header.before = header.after = header;  
}  
```

3) 存储：

LinkedHashMap并未重写父类HashMap的put方法，而是重写了父类HashMap的put方法调用的子方法void recordAccess(HashMap m)  ，void addEntry(int hash, K key, V value, int bucketIndex) 和void createEntry(int hash, K key, V value, int bucketIndex)，提供了自己特有的双向链接列表的实现。

**HashMap.put:**

```java
public V put(K key, V value) {
        if (key == null)
            return putForNullKey(value);
        int hash = hash(key.hashCode());
        int i = indexFor(hash, table.length);
        for (Entry<K,V> e = table[i]; e != null; e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
            }
        }

        modCount++;
        addEntry(hash, key, value, i);
        return null;
    }
```

 重写方法：

```java
void recordAccess(HashMap<K,V> m) {
            LinkedHashMap<K,V> lm = (LinkedHashMap<K,V>)m;
            if (lm.accessOrder) {
                lm.modCount++;
                remove();
                addBefore(lm.header);
            }
        }
void addEntry(int hash, K key, V value, int bucketIndex) {  
    // 调用create方法，将新元素以双向链表的的形式加入到映射中。  
    createEntry(hash, key, value, bucketIndex);  
  
    // 删除最近最少使用元素的策略定义  
    Entry<K,V> eldest = header.after;  
    if (removeEldestEntry(eldest)) {  
        removeEntryForKey(eldest.key);  
    } else {  
        if (size >= threshold)  
            resize(2 * table.length);  
    }  
}  
void createEntry(int hash, K key, V value, int bucketIndex) {  
    HashMap.Entry<K,V> old = table[bucketIndex];  
    Entry<K,V> e = new Entry<K,V>(hash, key, value, old);  
    table[bucketIndex] = e;  
    // 调用元素的addBrefore方法，将元素加入到哈希、双向链接列表。  
    e.addBefore(header);  
    size++;  
}  
private void addBefore(Entry<K,V> existingEntry) {  
    after  = existingEntry;  
    before = existingEntry.before;  
    before.after = this;  
    after.before = this;  
}  

```

4) 读取：

LinkedHashMap重写了父类HashMap的get方法，实际在调用父类getEntry()方法取得查找的元素后，再判断当排序模式accessOrder为true时，记录访问顺序，将最新访问的元素添加到双向链表的表头，并从原来的位置删除。由于的链表的增加、删除操作是常量级的，故并不会带来性能的损失。

**HashMap.containsValue:**

```java
public boolean containsValue(Object value) {  
    if (value == null)  
            return containsNullValue();  
  
    Entry[] tab = table;  
        for (int i = 0; i < tab.length ; i++)  
            for (Entry e = tab[i] ; e != null ; e = e.next)  
                if (value.equals(e.value))  
                    return true;  
    return false;  
    }  
 /*查找Map中是否包含给定的value，还是考虑到，LinkedHashMap拥有的双链表，在这里Override是为了提高迭代的效率。 
 */  
public boolean containsValue(Object value) {  
        // Overridden to take advantage of faster iterator  
        if (value==null) {  
            for (Entry e = header.after; e != header; e = e.after)  
                if (e.value==null)  
                    return true;  
        } else {  
            for (Entry e = header.after; e != header; e = e.after)  
                if (value.equals(e.value))  
                    return true;  
        }  
        return false;  
    }  
/*该transfer()是HashMap中的实现：遍历整个表的各个桶位，然后对桶进行遍历得到每一个Entry，重新hash到newTable中， 
 //放在这里是为了和下面LinkedHashMap重写该法的比较， 
 void transfer(Entry[] newTable) { 
        Entry[] src = table; 
        int newCapacity = newTable.length; 
        for (int j = 0; j < src.length; j++) { 
            Entry<K,V> e = src[j]; 
            if (e != null) { 
                src[j] = null; 
                do { 
                    Entry<K,V> next = e.next; 
                    int i = indexFor(e.hash, newCapacity); 
                    e.next = newTable[i]; 
                    newTable[i] = e; 
                    e = next; 
                } while (e != null); 
            } 
        } 
    } 
 */  
  
 /** 
 *transfer()方法是其父类HashMap调用resize()的时候调用的方法，它的作用是表扩容后，把旧表中的key重新hash到新的表中。 
 *这里从写了父类HashMap中的该方法，是因为考虑到，LinkedHashMap拥有的双链表，在这里Override是为了提高迭代的效率。 
 */  
 void transfer(HashMap.Entry[] newTable) {  
   int newCapacity = newTable.length;  
   for (Entry<K, V> e = header.after; e != header; e = e.after) {  
     int index = indexFor(e.hash, newCapacity);  
     e.next = newTable[index];  
     newTable[index] = e;  
   }  
 }  
 public V get(Object key) {  
    // 调用父类HashMap的getEntry()方法，取得要查找的元素。  
    Entry<K,V> e = (Entry<K,V>)getEntry(key);  
    if (e == null)  
        return null;  
    // 记录访问顺序。  
    e.recordAccess(this);  
    return e.value;  
}  
void recordAccess(HashMap<K,V> m) {  
    LinkedHashMap<K,V> lm = (LinkedHashMap<K,V>)m;  
    // 如果定义了LinkedHashMap的迭代顺序为访问顺序，  
    // 则删除以前位置上的元素，并将最新访问的元素添加到链表表头。  
    if (lm.accessOrder) {  
        lm.modCount++;  
        remove();  
        addBefore(lm.header);  
    }  
}  
/** 
 * Removes this entry from the linked list. 
 */  
  private void remove() {  
     before.after = after;  
     after.before = before;  
 }  
/**clear链表，设置header为初始状态*/  
public void clear() {  
 super.clear();  
 header.before = header.after = header;  
}  
```

 5) 排序模式：

LinkedHashMap定义了排序模式accessOrder，该属性为boolean型变量，对于访问顺序，为true；对于插入顺序，则为false。

```java
private final boolean accessOrder;  
```

 一般情况下，不必指定排序模式，其迭代顺序即为默认为插入顺序。看LinkedHashMap的构造方法，如：

```java
public LinkedHashMap(int initialCapacity, float loadFactor) {  
    super(initialCapacity, loadFactor);  
    accessOrder = false;  
}  
```

这些构造方法都会默认指定排序模式为插入顺序。如果你想构造一个LinkedHashMap，并打算按从近期访问最少到近期访问最多的顺序（即访问顺序）来保存元素，那么请使用下面的构造方法构造LinkedHashMap：

```java
public LinkedHashMap(int initialCapacity,  
         float loadFactor,  
                     boolean accessOrder) {  
    super(initialCapacity, loadFactor);  
    this.accessOrder = accessOrder;  
}  
```

该哈希映射的迭代顺序就是最后访问其条目的顺序，这种映射很适合构建LRU缓存。LinkedHashMap提供了removeEldestEntry(Map.Entry<K,V> eldest)方法。该方法可以提供在每次添加新条目时移除最旧条目的实现程序，默认返回false，这样，此映射的行为将类似于正常映射，即永远不能移除最旧的元素。

当有新元素加入Map的时候会调用Entry的addEntry方法，会调用removeEldestEntry方法，这里就是实现LRU元素过期机制的地方，默认的情况下removeEldestEntry方法只返回false表示元素永远不过期。

```java
/** 
    * This override alters behavior of superclass put method. It causes newly 
    * allocated entry to get inserted at the end of the linked list and 
    * removes the eldest entry if appropriate. 
    */  
   void addEntry(int hash, K key, V value, int bucketIndex) {  
       createEntry(hash, key, value, bucketIndex);  
  
       // Remove eldest entry if instructed, else grow capacity if appropriate  
       Entry<K,V> eldest = header.after;  
       if (removeEldestEntry(eldest)) {  
           removeEntryForKey(eldest.key);  
       } else {  
           if (size >= threshold)   
               resize(2 * table.length);  
       }  
   }  
  
   /** 
    * This override differs from addEntry in that it doesn't resize the 
    * table or remove the eldest entry. 
    */  
   void createEntry(int hash, K key, V value, int bucketIndex) {  
       HashMap.Entry<K,V> old = table[bucketIndex];  
Entry<K,V> e = new Entry<K,V>(hash, key, value, old);  
       table[bucketIndex] = e;  
       e.addBefore(header);  
       size++;  
   }  
  
   protected boolean removeEldestEntry(Map.Entry<K,V> eldest) {  
       return false;  
   }  
```

此方法通常不以任何方式修改映射，相反允许映射在其返回值的指引下进行自我修改。如果用此映射构建LRU缓存，则非常方便，它允许映射通过删除旧条目来减少内存损耗。

例如：重写此方法，维持此映射只保存100个条目的稳定状态，在每次添加新条目时删除最旧的条目。

```java
private static final int MAX_ENTRIES = 100;  
protected boolean removeEldestEntry(Map.Entry eldest) {  
    return size() > MAX_ENTRIES;  
}  
```

[使用LinkedHashMap构建LRU的](http://tomyz0223.iteye.com/blog/1035686)

[基于LinkedHashMap实现LRU](http://woming66.iteye.com/blog/1284326)

其实LinkedHashMap几乎和HashMap一样，不同的是它定义了一个Entry<K,V> header，这个header不是放在Table里，它是额外独立出来的。LinkedHashMap通过继承hashMap中的Entry<K,V>,并添加两个属性Entry<K,V>  before,after,和header结合起来组成一个双向链表，来实现按插入顺序或访问顺序排序。

#### 1.8 抽象类和接口的区别，类可以继承多个类么，接口可以继承多个接口么,类可以实现多个接口么。

1、抽象类和接口都不能直接实例化，如果要实例化，抽象类变量必须指向实现所有抽象方法的子类对象，接口变量必须指向实现所有接口方法的类对象。

2、抽象类要被子类继承，接口要被类实现。

3、接口只能做方法申明，抽象类中可以做方法申明，也可以做方法实现

4、接口里定义的变量只能是公共的静态的常量，抽象类中的变量是普通变量。

5、抽象类里的抽象方法必须全部被子类所实现，如果子类不能全部实现父类抽象方法，那么该子类只能是抽象类。同样，一个实现接口的时候，如不能全部实现接口方法，那么该类也只能为抽象类。

6、抽象方法只能申明，不能实现。abstract void abc();不能写成abstract void abc(){}。

7、抽象类里可以没有抽象方法

8、如果一个类里有抽象方法，那么这个类只能是抽象类

9、抽象方法要被实现，所以不能是静态的，也不能是私有的。

10、接口可继承接口，并可多继承接口，但类只能单根继承。

| **参数**           | **抽象类**                                                   | **接口**                                                     |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 默认的方法实现     | 它可以有默认的方法实现                                       | 接口完全是抽象的。它根本不存在方法的实现                     |
| 关键字             | 子类使用**extends**关键字来继承抽象类。如果子类不是抽象类的话，它需要提供抽象类中所有声明的方法的实现。 | 子类使用关键字**implements**来实现接口。它需要提供接口中所有声明的方法的实现 |
| 构造器             | 抽象类可以有构造器                                           | 接口不能有构造器                                             |
| 与正常Java类的区别 | 除了你不能实例化抽象类之外，它和普通Java类没有任何区别       | 接口是完全不同的类型                                         |
| 访问修饰符         | 抽象方法可以有**public**、**protected**和**default**这些修饰符 | 接口方法默认修饰符是**public**。你不可以使用其它修饰符。     |
| main方法           | 抽象方法可以有main方法并且我们可以运行它                     | 接口没有main方法，因此我们不能运行它。                       |
| 多继承             | 抽象类只可以继承一个类和实现多个接口                         | 接口和接口之间是可以多继承或者单继承多实现的。               |
| 速度               | 它比接口速度要快                                             | 接口是稍微有点慢的，因为它需要时间去寻找在类中实现的方法。   |
| 添加新方法         | 如果你往抽象类中添加新的方法，你可以给它提供默认的实现。因此你不需要改变你现在的代码。 | 如果你往接口中添加方法，那么你必须改变实现该接口的类。       |
| 设计理念           | is-a的关系，体现的是一种关系的延续                           | like-a体现的是一种功能的扩展关系                             |

**具体使用的场景**

- 如果你拥有一些方法并且想让它们中的一些有默认实现，那么使用抽象类吧。
- 如果你想实现多重继承，那么你必须使用接口。由于**Java不支持多继承**，子类不能够继承多个类，但可以实现多个接口。因此你就可以使用接口来解决它。
- 如果基本功能在不断改变，那么就需要使用抽象类。如果不断改变基本功能并且使用接口，那么就需要改变所有实现了该接口的类。
- 多用组合，少用继承。

#### 1.9 继承和聚合的区别在哪。

#### 2.0 IO模型有哪些，讲讲你理解的nio ，他和bio，aio的区别是啥，谈谈reactor模型。

#### 2.1 反射的原理，反射创建类实例的三种方式是什么。

#### 2.2 反射中，Class.forName和ClassLoader区别 。

#### 2.3 描述动态代理的几种实现方式，分别说出相应的优缺点。

#### 2.4 动态代理与cglib实现的区别。

#### 2.5 为什么CGlib方式可以对接口实现代理。

#### 2.6 final的用途。

#### 2.7 写出三种单例模式实现 。

#### 2.8 如何在父类中为子类自动完成所有的hashcode和equals实现？这么做有何优劣。

#### 2.9 请结合OO设计理念，谈谈访问修饰符public、private、protected、default在应用设计中的作用。

#### 3.0 深拷贝和浅拷贝区别。

#### 3.1 数组和链表数据结构描述，各自的时间复杂度。

#### 3.2 error和exception的区别，CheckedException，RuntimeException的区别。

#### 3.3 请列出5个运行时异常。

#### 3.4 在自己的代码中，如果创建一个java.lang.String类，这个类是否可以被类加载器加载？为什么。

#### 3.5 说一说你对java.lang.Object对象中hashCode和equals方法的理解。在什么场景下需要重新实现这两个方法。

#### 3.6 在jdk1.5中，引入了泛型，泛型的存在是用来解决什么问题。

#### 3.7 这样的a.hashcode() 有什么用，与a.equals(b)有什么关系。

#### 3.8 有没有可能2个不相等的对象有相同的hashcode。

#### 3.9 Java中的HashSet内部是如何工作的。

#### 4.0 什么是序列化，怎么序列化，为什么序列化，反序列化会遇到什么问题，如何解决。

#### 4.1 java8的新特性。