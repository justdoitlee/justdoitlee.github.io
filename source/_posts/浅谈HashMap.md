---
title: 浅谈HashMap
date: 2017-02-18 21:34:09
categories: Java二三事
tags:
	- Java
	- 集合
---

**什么是Map?**

<font color="#008080">Map用于保存具有key-value映射关系的数据</font>
<!--more-->
首先看图！

![这里写图片描述](http://img.blog.csdn.net/20161224234534698)

可以看出Java 中有四种常见的Map实现——HashMap, TreeMap, Hashtable和LinkedHashMap：

·HashMap就是一张hash表，键和值都没有排序。<br>
·TreeMap以红黑树结构为基础，键值可以设置按某种顺序排列。<br>
·LinkedHashMap保存了插入时的顺序。<br>
·Hashtable是同步的(而HashMap是不同步的)。所以如果在线程安全的环境下应该多使用HashMap，而不是Hashtable，因为Hashtable对同步有额外的开销。


**我们在这里简单的说说HashMap：**

(1)HashMap是基于哈希表实现的，每一个元素是一个key-value对，其内部通过单链表解决冲突问题，容量不足（超过了阀值）时，同样会自动增长。

(2)HashMap是非线程安全的，只用于单线程环境下，多线程环境下可以采用concurrent并发包下的concurrentHashMap。

(3)HashMap 实现了Serializable接口，因此它支持序列化。

(4)HashMap还实现了Cloneable接口，故能被克隆。

<br>
先从**HashMap的存储结构**说起：

![这里写图片描述](http://img.blog.csdn.net/20161224235308725)

蓝色部分即代表哈希表本身（其实是一个数组），数组的每个元素都是一个单链表的头节点，链表是用来解决hash地址冲突的，如果不同的key映射到了数组的同一位置处，就将其放入单链表中保存。

**HashMap的构造方法中有两个很重要的参数：**<font color="#008080">初始容量和加载因子</font>

这两个参数是影响HashMap性能的重要参数，其中容量表示哈希表中槽的数量（即哈希数组的长度），初始容量是创建哈希表时的容量（默认为16），加载因子是哈希表当前key的数量和容量的比值，当哈希表中的条目数超出了加载因子与当前容量的乘积时，则要对该哈希表提前进行 resize 操作（即扩容）。如果加载因子越大，对空间的利用更充分，但是查找效率会降低（链表长度会越来越长）；如果加载因子太小，那么表中的数据将过于稀疏（很多空间还没用，就开始扩容了），严重浪费。

JDK开发者规定的默认加载因子为0.75，因为这是一个比较理想的值。另外，无论指定初始容量为多少，构造方法都会将实际容量设为不小于指定容量的2的幂次方，且最大值不能超过2的30次方。



**我们来分析一下HashMap中用的最多的两个方法put和get的源码**

>get()：

```
// 获取key对应的value
    public V get(Object key) {
        if (key == null)
            return getForNullKey();
        // 获取key的hash值
        int hash = hash(key.hashCode());
        // 在“该hash值对应的链表”上查找“键值等于key”的元素
        for (Entry<K, V> e = table[indexFor(hash, table.length)]; e != null; e = e.next) {
            Object k;
            // 判断key是否相同
            if (e.hash == hash && ((k = e.key) == key || key.equals(k)))
                return e.value;
        }
        // 没找到则返回null
        return null;
    }

    // 获取“key为null”的元素的值，HashMap将“key为null”的元素存储在table[0]位置，但不一定是该链表的第一个位置！
    private V getForNullKey() {
        for (Entry<K, V> e = table[0]; e != null; e = e.next) {
            if (e.key == null)
                return e.value;
        }
        return null;
    }
```

首先，如果key为null，则直接从哈希表的第一个位置table[0]对应的链表上查找。记住，key为null的键值对永远都放在以table[0]为头结点的链表中，当然不一定是存放在头结点table[0]中。如果key不为null，则先求的key的hash值，根据hash值找到在table中的索引，在该索引对应的单链表中查找是否有键值对的key与目标key相等，有就返回对应的value，没有则返回null。


>put()：<br>

```
// 将“key-value”添加到HashMap中
    public V put(K key, V value) {
        // 若“key为null”，则将该键值对添加到table[0]中。
        if (key == null)
            return putForNullKey(value);
        // 若“key不为null”，则计算该key的哈希值，然后将其添加到该哈希值对应的链表中。
        int hash = hash(key.hashCode());
        int i = indexFor(hash, table.length);
        for (Entry<K, V> e = table[i]; e != null; e = e.next) {
            Object k;
            // 若“该key”对应的键值对已经存在，则用新的value取代旧的value。然后退出！
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
            }
        }

        // 若“该key”对应的键值对不存在，则将“key-value”添加到table中
        modCount++;
        // 将key-value添加到table[i]处
        addEntry(hash, key, value, i);
        return null;
    }
```

如果key为null，则将其添加到table[0]对应的链表中，如果key不为null，则同样先求出key的hash值，根据hash值得出在table中的索引，而后遍历对应的单链表，如果单链表中存在与目标key相等的键值对，则将新的value覆盖旧的value，且将旧的value返回，如果找不到与目标key相等的键值对，或者该单链表为空，则将该键值对插入到单链表的头结点位置（每次新插入的节点都是放在头结点的位置），该操作是有addEntry方法实现的，它的源码如下：

```
// 新增Entry。将“key-value”插入指定位置，bucketIndex是位置索引。
    void addEntry(int hash, K key, V value, int bucketIndex) {
        // 保存“bucketIndex”位置的值到“e”中
        Entry<K, V> e = table[bucketIndex];
        // 设置“bucketIndex”位置的元素为“新Entry”，
        // 设置“e”为“新Entry的下一个节点”
        table[bucketIndex] = new Entry<K, V>(hash, key, value, e);
        // 若HashMap的实际大小 不小于 “阈值”，则调整HashMap的大小
        if (size++ >= threshold)
            resize(2 * table.length);
    }

```

注意这里倒数第三行的构造方法，将key-value键值对赋给table[bucketIndex]，并将其next指向元素e，这便将key-value放到了头结点中，并将之前的头结点接在了它的后面。该方法也说明，每次put键值对的时候，总是将新的该键值对放在table[bucketIndex]处（即头结点处）。两外注意最后两行代码，每次加入键值对时，都要判断当前已用的槽的数目是否大于等于阀值（容量*加载因子），如果大于等于，则进行扩容，将容量扩为原来容量的2倍。


<font color="#008080">**接下来重点来分析下求hash值和索引值的方法，这两个方法便是HashMap设计的最为核心的部分，二者结合能保证哈希表中的元素尽可能均匀地散列。**</font>

>由hash值找到对应索引的方法如下：

```
static int indexFor(int h, int length) {
        return h & (length-1);
     }
    
```
因为容量初始还是设定都会转化为2的幂次。故可以使用高效的位与运算替代模运算。

>计算hash值的方法如下:

```
 static int hash(int h) {
            h ^= (h >>> 20) ^ (h >>> 12);
            return h ^ (h >>> 7) ^ (h >>> 4);
        }
```

JDK 的 HashMap 使用了一个 hash 方法对hash值使用位的操作，使hash值的计算效率很高。为什么这样做？主要是因为如果直接使用hashcode值，那么这是一个int值（8个16进制数，共32位），int值的范围正负21亿多，但是hash表没有那么长，一般比如初始16，自然散列地址需要对hash表长度取模运算，得到的余数才是地址下标。假设某个key的hashcode是0AAA0000，hash数组长默认16，如果不经过hash函数处理，该键值对会被存放在hash数组中下标为0处，因为0AAA0000 & (16-1) = 0。过了一会儿又存储另外一个键值对，其key的hashcode是0BBB0000，得到数组下标依然是0，这就说明这是个实现得很差的hash算法，因为hashcode的1位全集中在前16位了，导致算出来的数组下标一直是0。<font color="red">于是明明key相差很大的键值对，却存放在了同一个链表里，导致以后查询起来比较慢（蜕化为了顺序查找）。故JDK的设计者使用hash函数的若干次的移位、异或操作，把hashcode的“1位”变得“松散”，非常巧妙。</font>





