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

其中最频繁的是HashMap和ConcurrentHashMap，他们的主要区别是HashMap是非线程安全的。ConcurrentHashMap是线程安全的。

并发下可以使用ConcurrentHashMap和HashTable

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

- ConcurrentHashMap的hash计算公式：(key.hascode()^ (key.hascode()>>> 16)) & 0x7FFFFFFF

  HashTable的hash计算公式：key.hascode()& 0x7FFFFFFF

- HashTable存储方式都是链表+数组，数组里面放的是当前hash的第一个数据，链表里面放的是hash冲突的数据

  ConcurrentHashMap是数组+链表+红黑树

- 默认容量都是16，负载因子是0.75。就是当hashmap填充了75%的busket是就会扩容，最小的可能性是（16*0.75），一般为原内存的2倍

- 4.线程安全的保证：HashTable是在每个操作方法上面加了synchronized来达到线程安全，ConcurrentHashMap线程是使用CAS(compore and swap)来保证线程安全的

- 5.ConcurrentHashMap内部原理

  **1.7：** put 加锁

  通过分段加锁 segment，put 数据时通过 hash(key) 得到该元素要添加到的 segment，对 segment 进行加锁，进行再 hash 得到该元素要添加到的桶，遍历桶中的链表，替换或新增节点到桶中。

  **1.8：** put CAS 加锁

  1.8 中仍然有 segment 的定义，但不再有任何结构上的用处，segment 数量与桶数量一致，不依赖于 segment 加锁。

  首先，判断容器是否为空，如果为空则进行初始化，否则重试对 hash(key) 计算得到该 key 存放的桶位置，判断该桶是否为空，为空则利用 CAS 设置新节点，否则使用 synchronized 加锁，遍历桶中数据，替换或新增加节点到桶中，最后判断是否需要转为红黑树，转换之前判断是否需要扩容。

- 6.细节

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

​	JDK1.8，并发编程不再死循环
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

- put()操作的伪代码

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

#### 1.7 有没有有顺序的Map实现类，如果有，他们是怎么保证有序的。

#### 1.8 抽象类和接口的区别，类可以继承多个类么，接口可以继承多个接口么,类可以实现多个接口么。

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