---
title: 为什么volatile不能保证原子性而Atomic可以？
date: 2017-03-02 15:51:50
categories: Java二三事
tags:
	- Java
---
在Java中long赋值不是原子操作，因为先写32位，再写后32位，分两步操作，而AtomicLong赋值是原子操作，为什么？为什么volatile能替代简单的锁，却不能保证原子性？这里面涉及volatile，是java中的一个我觉得这个词在Java规范中从未被解释清楚的神奇关键词，在Sun的JDK官方文档是这样形容volatile的：
<!--more-->
>The Java programming language provides a second mechanism, volatile fields, that is more convenient than locking for some purposes. A field may be declared volatile, in which case the Java Memory Model ensures that all threads see a consistent value for the variable.

意思就是说，如果一个变量加了volatile关键字，就会告诉编译器和JVM的内存模型：这个变量是对所有线程共享的、可见的，每次jvm都会读取最新写入的值并使其最新值在所有CPU可见。**volatile似乎是有时候可以代替简单的锁，似乎加了volatile关键字就省掉了锁。但又说volatile不能保证原子性（java程序员很熟悉这句话：volatile仅仅用来保证该变量对所有线程的可见性，但不保证原子性）**。这不是互相矛盾吗？

>不要将volatile用在getAndOperate场合，仅仅set或者get的场景是适合volatile的

**不要将volatile用在getAndOperate场合（这种场合不原子，需要再加锁），仅仅set或者get的场景是适合volatile的。**

>volatile没有原子性举例：AtomicInteger自增

例如你让一个volatile的integer自增（i++），其实要分成3步：1）读取volatile变量值到local； 2）增加变量的值；3）把local的值写回，让其它的线程可见。这3步的jvm指令为：

```
mov    0xc(%r10),%r8d ; Load
inc    %r8d           ; Increment
mov    %r8d,0xc(%r10) ; Store
lock addl $0x0,(%rsp) ; StoreLoad Barrier
```

注意最后一步是内存屏障。

>什么是内存屏障（Memory Barrier）？

内存屏障（memory barrier）是一个CPU指令。基本上，它是这样一条指令： a) 确保一些特定操作执行的顺序； b) 影响一些数据的可见性(可能是某些指令执行后的结果)。编译器和CPU可以在保证输出结果一样的情况下对指令重排序，使性能得到优化。插入一个内存屏障，相当于告诉CPU和编译器先于这个命令的必须先执行，后于这个命令的必须后执行。内存屏障另一个作用是强制更新一次不同CPU的缓存。例如，一个写屏障会把这个屏障前写入的数据刷新到缓存，这样任何试图读取该数据的线程将得到最新值，而不用考虑到底是被哪个cpu核心或者哪颗CPU执行的。

内存屏障（memory barrier）和volatile什么关系？上面的虚拟机指令里面有提到，如果你的字段是volatile，Java内存模型将在写操作后插入一个写屏障指令，在读操作前插入一个读屏障指令。这意味着如果你对一个volatile字段进行写操作，你必须知道：1、一旦你完成写入，任何访问这个字段的线程将会得到最新的值。2、在你写入前，会保证所有之前发生的事已经发生，并且任何更新过的数据值也是可见的，因为内存屏障会把之前的写入值都刷新到缓存。

>volatile为什么没有原子性?

明白了内存屏障（memory barrier）这个CPU指令，回到前面的JVM指令：从Load到store到内存屏障，一共4步，其中最后一步jvm让这个最新的变量的值在所有线程可见，也就是最后一步让所有的CPU内核都获得了最新的值，但中间的几步（从Load到Store）是不安全的，中间如果其他的CPU修改了值将会丢失。下面的测试代码可以实际测试voaltile的自增没有原子性：

```
 private static volatile long _longVal = 0;
     
    private static class LoopVolatile implements Runnable {
        public void run() {
            long val = 0;
            while (val < 10000000L) {
                _longVal++;
                val++;
            }
        }
    }
     
    private static class LoopVolatile2 implements Runnable {
        public void run() {
            long val = 0;
            while (val < 10000000L) {
                _longVal++;
                val++;
            }
        }
    }
     
    private  void testVolatile(){
        Thread t1 = new Thread(new LoopVolatile());
        t1.start();
         
        Thread t2 = new Thread(new LoopVolatile2());
        t2.start();
         
        while (t1.isAlive() || t2.isAlive()) {
        }
 
        System.out.println("final val is: " + _longVal);
    }
 
Output:-------------
     
final val is: 11223828
final val is: 17567127
final val is: 12912109

```

>volatile没有原子性举例：singleton单例模式实现

这是一段线程不安全的singleton（单例模式）实现，尽管使用了volatile：

```
public class wrongsingleton {
    private static volatile wrongsingleton _instance = null; 
 
    private wrongsingleton() {}
 
    public static wrongsingleton getInstance() {
 
        if (_instance == null) {
            _instance = new wrongsingleton();
        }
 
        return _instance;
    }
}
```
下面的测试代码可以测试出是线程不安全的：

```
public class wrongsingleton {
    private static volatile wrongsingleton _instance = null; 
 
    private wrongsingleton() {}
 
    public static wrongsingleton getInstance() {
 
        if (_instance == null) {
            _instance = new wrongsingleton();
            System.out.println("--initialized once.");
        }
 
        return _instance;
    }
}
 
private static void testInit(){
         
        Thread t1 = new Thread(new LoopInit());
        Thread t2 = new Thread(new LoopInit2());
        Thread t3 = new Thread(new LoopInit());
        Thread t4 = new Thread(new LoopInit2());
        t1.start();
        t2.start();
        t3.start();
        t4.start();
         
        while (t1.isAlive() || t2.isAlive() || t3.isAlive()|| t4.isAlive()) {
             
        }
 
    }
输出：有时输出"--initialized once."一次，有时输出好几次
```

原因自然和上面的例子是一样的。**因为volatile保证变量对线程的可见性，但不保证原子性。**

附：正确线程安全的单例模式写法：

```
@ThreadSafe
public class SafeLazyInitialization { 
   private static Resource resource; 
   public synchronized static Resource getInstance() { 
      if (resource == null) 
          resource = new Resource(); 
      return resource; 
    } 
}

```

另外一种写法：

```
@ThreadSafe
public class EagerInitialization { 
  private static Resource resource = new Resource(); 
  public static Resource getResource() { return resource; } 
}
```

延迟初始化的写法：

```
@ThreadSafe
public class ResourceFactory { 
    private static class ResourceHolder { 
        public static Resource resource = new Resource(); 
    } 
    public static Resource getResource() { 
        return ResourceHolder.resource ; 
    } 
}

```

二次检查锁定/Double Checked Locking的写法（反模式）

```
public class SingletonDemo {
    private static volatile SingletonDemo instance = null;//注意需要volatile
  
    private SingletonDemo() {   }
  
    public static SingletonDemo getInstance() {
        if (instance == null) { //二次检查，比直接用独占锁效率高
               synchronized (SingletonDemo .class){
                    if (instance == null) {
                               instance = new SingletonDemo (); 
                    }
             }
        }
        return instance;
    }
}
```

>为什么AtomicXXX具有原子性和可见性？

就拿AtomicLong来说，它既解决了上述的volatile的原子性没有保证的问题，又具有可见性。它是如何做到的？CAS（比较并交换）指令。 其实AtomicLong的源码里也用到了volatile，但只是用来读取或写入，见源码：

```
public class AtomicLong extends Number implements java.io.Serializable {
    private volatile long value;
 
    /**
     * Creates a new AtomicLong with the given initial value.
     *
     * @param initialValue the initial value
     */
    public AtomicLong(long initialValue) {
        value = initialValue;
    }
 
    /**
     * Creates a new AtomicLong with initial value {@code 0}.
     */
    public AtomicLong() {
    }
```

其CAS源码核心代码为：

```
int compare_and_swap (int* reg, int oldval, int newval) 
{
  ATOMIC();
  int old_reg_val = *reg;
  if (old_reg_val == oldval) 
     *reg = newval;
  END_ATOMIC();
  return old_reg_val;
}
```

虚拟机指令为：

```
mov    0xc(%r11),%eax       ; Load
mov    %eax,%r8d            
inc    %r8d                 ; Increment
lock cmpxchg %r8d,0xc(%r11) ; Compare and exchange

```

因为CAS是基于乐观锁的，也就是说当写入的时候，如果寄存器旧值已经不等于现值，说明有其他CPU在修改，那就继续尝试。所以这就保证了操作的原子性。

 <img src="http://images.cnitblog.com/blog/28306/201402/191824486252285.png " width = "400" height = "300" alt="图片名称" align=center />