---
title: Java反射学习总结（三）
date: 2017-02-18 21:14:58
categories: Java二三事
tags: 
	- 反射
---
Class对象表示所加载的类，取得Class对象后，我们就可以愉快的取得与类相关的信息了，就像包（package,package也是类名的一部分哦~），构造方法，方法，属性等信息，而每一个信息，也会有相应的类别形态，比如包对应的是 java.lang.Package，构造方法对应的是java.lang.reflect.Constructor，成员方法对应的是 java.lang.reflect.Method，属性对应的是 java.lang.reflect.Field等。
<!--more-->
先来个简单的例子吧，获取一下包名：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/4
 */
public class ClassInfoDemo {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);
            Package p = c.getPackage();
            System.out.println(p.getName());
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("没有指定类");
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定类");
        }
    }
}

```
输出：

```
java ClassInfoDemo java.util.ArrayList
java.util
```
用相应的方法，我们可以分别取得 Field、Constructor、Method等对象。


下面是一个我之前写的可以获取某些类信息的一个demo：

```
package CoreJava.day_2;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Scanner;

/**
 * @author 李智
 * @date 2016/12/1
 */
public class ReflectTest {
    public static void main(String[] args) {
        String name;
        if (args.length > 0) {
            name = args[0];
        } else {
            Scanner in = new Scanner(System.in);
            System.out.println("输入类名:(例如:java.util.Date)");
            name = in.next();
        }

        try {
            Class c1 = Class.forName(name);
            Class superc1 = c1.getSuperclass();
            String modifiers = Modifier.toString(c1.getModifiers());
            if (modifiers.length() > 0) {
                System.out.print(modifiers + "");
            }
            System.out.print("class " + name);
            if (superc1 != null && superc1 != Object.class) {
                System.out.print(" extends" + superc1.getName());
            }
            System.out.print("\n{\n");
            printConstructors(c1);
            System.out.println();
            printMethods(c1);
            System.out.println();
            printFields(c1);
            System.out.println("}");
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.exit(0);
    }

    public static void printConstructors(Class c1) {
        Constructor[] constructors = c1.getDeclaredConstructors();
        for (Constructor c : constructors) {
            String name = c.getName();
            System.out.print("");
            String modifers = Modifier.toString(c.getModifiers());
            if (modifers.length() > 0) {
                System.out.print(modifers + " ");
            }
            System.out.print(name + "(");
            Class[] paramTypes = c.getParameterTypes();
            for (int j = 0; j < paramTypes.length; j++) {
                if (j > 0) {
                    System.out.print(",");
                }
                System.out.print(paramTypes[j].getName());
            }
            System.out.println(");");
        }
    }

    public static void printMethods(Class c1) {
        Method[] methods = c1.getDeclaredMethods();
        for (Method m : methods) {
            Class retType = m.getReturnType();
            String name = m.getName();

            System.out.print(" ");
            String modifiers = Modifier.toString(m.getModifiers());
            if (modifiers.length() > 0) {
                System.out.print(modifiers + " ");
            }
            System.out.print(retType.getName() + " " + "(");
            Class[] paramTypes = m.getParameterTypes();
            for (int j = 0; j < paramTypes.length; j++) {
                if (j > 0) {
                    System.out.print(",");
                }
                System.out.print(paramTypes[j].getName());
            }
            System.out.println(");");
        }
    }

    public static void printFields(Class c1) {
        Field[] fields = c1.getDeclaredFields();
        for (Field f : fields) {
            Class type = f.getType();
            String name = f.getName();
            System.out.print(" ");
            String modifiers = Modifier.toString(f.getModifiers());
            if (modifiers.length() > 0) {
                System.out.print(modifiers + " ");
            }
            System.out.println(type.getName() + " " + name + ";");
        }
    }
}
```
输出：

```
输入类名:(例如:java.util.Date)
java.util.Date
publicclass java.util.Date
{
public java.util.Date(java.lang.String);
public java.util.Date(int,int,int,int,int,int);
public java.util.Date(int,int,int,int,int);
public java.util.Date();
public java.util.Date(long);
public java.util.Date(int,int,int);

 public boolean (java.lang.Object);
 public java.lang.String ();
 public int ();
 public java.lang.Object ();
 public int (java.util.Date);
 public volatile int (java.lang.Object);
 private void (java.io.ObjectInputStream);
 private void (java.io.ObjectOutputStream);
 private final sun.util.calendar.BaseCalendar$Date ();
 private final sun.util.calendar.BaseCalendar$Date (sun.util.calendar.BaseCalendar$Date);
 public static long (java.lang.String);
 public boolean (java.util.Date);
 public boolean (java.util.Date);
 public int ();
 public void (int);
 public int ();
 public void (int);
 public void (int);
 public int ();
 public int ();
 public void (int);
 public int ();
 public void (int);
 public int ();
 public void (int);
 private final long ();
 static final long (java.util.Date);
 private static final java.lang.StringBuilder (java.lang.StringBuilder,java.lang.String);
 public java.lang.String ();
 public java.lang.String ();
 public int ();
 private final sun.util.calendar.BaseCalendar$Date ();
 private static final sun.util.calendar.BaseCalendar (sun.util.calendar.BaseCalendar$Date);
 private static final sun.util.calendar.BaseCalendar (long);
 private static final sun.util.calendar.BaseCalendar (int);
 private static final synchronized sun.util.calendar.BaseCalendar ();
 public java.time.Instant ();
 public static long (int,int,int,int,int,int);
 public static java.util.Date (java.time.Instant);
 public int ();
 public void (long);
 public long ();

 private static final sun.util.calendar.BaseCalendar gcal;
 private static sun.util.calendar.BaseCalendar jcal;
 private transient long fastTime;
 private transient sun.util.calendar.BaseCalendar$Date cdate;
 private static int defaultCenturyStart;
 private static final long serialVersionUID;
 private static final [Ljava.lang.String; wtb;
 private static final [I ttb;
}

Process finished with exit code 0
```

输入一个类（完整的类名），即可打印该类的略为完整信息。当然还有一些不知道的，可以查看API来完成。

