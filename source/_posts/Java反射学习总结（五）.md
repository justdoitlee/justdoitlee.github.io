---
title: Java反射学习总结（五）
date: 2017-02-18 21:16:51
categories: Java二三事
tags: 
	- 反射
---
**使用反射实例对象**

使用反射机制，我们可以在运行时动态加载类并且实例化对象，操作对象的方法、改变类成员的值，甚至还可以改变私有（private）成员的值。

我们可以用 Class 的 newInstance() 方法来实例化一个对象，实例化的对象是以 Object 传回的，例如：
<!--more-->
```
Class c = Class.forName(className);
Object obj = c.newInstance();
```

下面范例动态加载list接口的类：

```
package CoreJava.day_2;

import java.util.List;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class NewInstanceDemo {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);
            List list = (List) c.newInstance();

            for (int i = 0; i < 5; i++) {
                list.add("element " + i);
            }

            for (Object o : list.toArray()) {
                System.out.println(o);
            }
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定的类");
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }
}

```
输出：

```
java CoreJava.day_2.NewInstanceDemo java.util.ArrayList
element 0
element 1
element 2
element 3
element 4
```

实际上如果想要使用反射来动态加载类，通常是对对象的接口或类别都一无所知，也就无法像上面对 newInstance() 传回的对象进行接口转换。

如果加载的类中具备无参数的构造方法，则可以无参数的 newInstance() 来构造一个不指定初始化的引用，如果要在动态加载及生成对象时指定对象的引用，则要先指定参数类型、取得 Constructor 对象、使用 Constructor 的 newInstance() 并指定参数。

可以用一个例子来说明，先定义一个student类:

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/05
 */
public class Student {
    private String name;
    private int score;

    public Student() {
        name = "N/A";
    }

    public Student(String name, int score) {
        this.name = name;
        this.score = score;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public String getName() {
        return name;
    }

    public int getScore() {
        return score;
    }

    public String toString() {
        return name + ":" + score;
    }
}
```

我们可以用 Class.forName() 来加载 Student ，并使用第二个有参数的构造方法来构造Student 实例：

```
package CoreJava.day_2;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class NewInstanceDemo2 {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);

            // 指定参数
            Class[] params = new Class[2];
            // 第一个是String
            params[0] = String.class;
            // 第二个是int
            params[1] = Integer.TYPE;

            // 取得对应的构造方法
            Constructor constructor =
                    c.getConstructor(params);

            // 指定引用内容
            Object[] argObjs = new Object[2];
            argObjs[0] = "caterpillar";
            argObjs[1] = new Integer(90);

            // 给定引用并初始化
            Object obj = constructor.newInstance(argObjs);
            // toString()查看
            System.out.println(obj);
        } catch (ClassNotFoundException e) {
            System.out.println("找不到类");
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            System.out.println("没有所指定的方法");
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }
}

```
输出：

```
java NewInstanceDemo2 CoreJava.day_2.Student
caterpillar:90
```

**调用方法**

使用反射可以取回类上方法的对象代表，方法的物件代表是 java.lang.reflect.Method 的实例，我们可以使用它的 invoke() 方法来动态调用指定的方法，例如调用上面 Student 上的 setName() 等方法：

```
package CoreJava.day_2;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class InvokeMethodDemo {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);
            // 使用无参构造方法实例对象
            Object targetObj = c.newInstance();
            // 设置参数类型
            Class[] param1 = {String.class};
            // 根据参数取回方法
            Method setNameMethod = c.getMethod("setName", param1);
            // 设置引用
            Object[] argObjs1 = {"caterpillar"};
            // 给引用调用指定对象的方法方法
            setNameMethod.invoke(targetObj, argObjs1);


            Class[] param2 = {Integer.TYPE};
            Method setScoreMethod =
                    c.getMethod("setScore", param2);

            Object[] argObjs2 = {new Integer(90)};
            setScoreMethod.invoke(targetObj, argObjs2);
            // 显示类描述
            System.out.println(targetObj);

        } catch (ClassNotFoundException e) {
            System.out.println("找不到类");
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            System.out.println("没有这个方法");
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        }
    }
}

```
我们可以指定加载 Student 类并生成实例，接着可以动态调用 setName() 和 setScore() 方法，由于调用setName() 和 setScore() 所设置的参数是 "caterpillar" 和90。

在很少的情況下，我们需要突破 Java 的存取限制来调用受保护的（protected）或私有（private）的方法（例如我们拿到一个组件（Component），但我们没法修改它的原始码来改变某个私有方法的权限，而我们又一定要调用某个私有方法），这时我们可以使用反射机制來达到目的，一个存取私有方法的例子如下：

```
Method privateMethod = 
            c.getDeclaredMethod("somePrivateMethod", new Class[0]);
privateMethod.setAccessible(true);
privateMethod.invoke(targetObj, argObjs);
```

使用反射来动态调用方法的实例例子之一是在 JavaBean 的设定，例如在 JSP/Servlet 中，可以根据使用者的请求名和 JavaBean 的属性自动对比，将请求值设置到指定的 JavaBean 上，并自动根据参数类型转换。

下面是一个map的小例子：

```
package CoreJava.day_2;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Map;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class CommandUtil {
    public static Object getCommand(Map requestMap,
                                    String commandClass)
            throws Exception {
        Class c = Class.forName(commandClass);
        Object o = c.newInstance();

        return updateCommand(requestMap, o);
    }

    // 使用reflection自动找出要更新的属性
    public static Object updateCommand(
            Map requestMap,
            Object command)
            throws Exception {
        Method[] methods =
                command.getClass().getDeclaredMethods();

        for (int i = 0; i < methods.length; i++) {
            // 略过private、protected成员
            // 且找出必须是set开头的方法
            if (!Modifier.isPrivate(methods[i].getModifiers()) &&
                    !Modifier.isProtected(methods[i].getModifiers()) &&
                    methods[i].getName().startsWith("set")) {
                // 取得不包括set方法
                String name = methods[i].getName()
                        .substring(3)
                        .toLowerCase();
                // 如果setter名称键值对相同
                // 调用对应的setter并给值
                if (requestMap.containsKey(name)) {
                    String param = (String) requestMap.get(name);
                    Object[] values = findOutParamValues(
                            param, methods[i]);
                    methods[i].invoke(command, values);
                }
            }
        }
        return command;
    }

    // 转换对应类型
    private static Object[] findOutParamValues(
            String param, Method method) {
        Class[] params = method.getParameterTypes();
        Object[] objs = new Object[params.length];

        for (int i = 0; i < params.length; i++) {
            if (params[i] == String.class) {
                objs[i] = param;
            } else if (params[i] == Short.TYPE) {
                short number = Short.parseShort(param);
                objs[i] = new Short(number);
            } else if (params[i] == Integer.TYPE) {
                int number = Integer.parseInt(param);
                objs[i] = new Integer(number);
            } else if (params[i] == Long.TYPE) {
                long number = Long.parseLong(param);
                objs[i] = new Long(number);
            } else if (params[i] == Float.TYPE) {
                float number = Float.parseFloat(param);
                objs[i] = new Float(number);
            } else if (params[i] == Double.TYPE) {
                double number = Double.parseDouble(param);
                objs[i] = new Double(number);
            } else if (params[i] == Boolean.TYPE) {
                boolean bool = Boolean.parseBoolean(param);
                objs[i] = new Boolean(bool);
            }
        }
        return objs;
    }
     public static void main(String[] args) throws Exception {
        Map<String, String> request = 
                  new HashMap<String, String>();
        request.put("name", "caterpillar");
        request.put("score", "90");
        Object obj = CommandUtil.getCommand(request, args[0]);
        System.out.println(obj);
    }
}

```
CommandUtil 可以自动根据方法上的参数类型，将Map 中的value转换成相应的类型，目前它可以转换基本类型和 String。

输出：

```
java CommandUtilDemo CoreJava.day_2.Student
caterpillar:90
```

当然也可以修改**成员变量**，尽管直接读取类的成员属性（Field）是不被鼓励的，但我们仍是可以直接存取公共的（public）成员属性的，而我们甚至也可以通过反射机制来读取私用成员变量，以一个例子来说明：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class TestField {
    public int testInt;
    public String testString;

    public String toString() {
        return testInt + ":" + testString;
    }
}

```
然后利用反射机制动态的读取成员变量：

```
package CoreJava.day_2;

import java.lang.reflect.Field;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class AssignFieldDemo {
    public static void main(String[] args) {
        try {
            Class c = Class.forName(args[0]);
            Object targetObj = c.newInstance();

            Field testInt = c.getField("testInt");
            testInt.setInt(targetObj, 99);

            Field testString = c.getField("testString");
            testString.set(targetObj, "caterpillar");

            System.out.println(targetObj);
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("没有指定类");
        } catch (ClassNotFoundException e) {
            System.out.println("找不到指定的类");
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
            System.out.println("找不到指定的成员变量");
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }
}

```
输出：

```
java AssignFieldDemo CoreJava.day_2.TestField
99:caterpillar
```
如果有必要的话，也可以通过反射机制来读取私有的成员变量，例如：

```
Field privateField = c.getDeclaredField("privateField"); 
privateField.setAccessible(true);
privateField.setInt(targetObj, 99);
```

**数组**
在 Java 中数组也是一个对象，也会有一个 Class 实例来表示它，我们用几个基本类型和String来进行测试：

```
package CoreJava.day_2;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class ArrayDemo {
    public static void main(String[] args) {
        short[] sArr = new short[5];
        int[] iArr = new int[5];
        long[] lArr = new long[5];
        float[] fArr = new float[5];
        double[] dArr = new double[5];
        byte[] bArr = new byte[5];
        boolean[] zArr = new boolean[5];
        String[] strArr = new String[5];

        System.out.println("short 数组：" + sArr.getClass());
        System.out.println("int 数组：" + iArr.getClass());
        System.out.println("long 数组：" + lArr.getClass());
        System.out.println("float 数组：" + fArr.getClass());
        System.out.println("double 数组：" + dArr.getClass());
        System.out.println("byte 数组：" + bArr.getClass());
        System.out.println("boolean 数组：" + zArr.getClass());
        System.out.println("String 数组：" + strArr.getClass());
    }
}

```
输出：

```
short 数组：class [S
int 数组：class [I
long 数组：class [J
float 数组：class [F
double 数组：class [D
byte 数组：class [B
boolean 数组：class [Z
String 数组：class [Ljava.lang.String;

Process finished with exit code 0
```

要使用**反射机制动态生成数组**的话，也可以这样：

```
package CoreJava.day_2;

import java.lang.reflect.Array;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class NewArrayDemo {
    public static void main(String[] args) {
        Class c = String.class;
        Object objArr = Array.newInstance(c, 5);

        for (int i = 0; i < 5; i++) {
            Array.set(objArr, i, i + "");
        }

        for (int i = 0; i < 5; i++) {
            System.out.print(Array.get(objArr, i) + " ");
        }
        System.out.println();

        String[] strs = (String[]) objArr;
        for (String s : strs) {
            System.out.print(s + " ");
        }
    }
}

```

Array.newInstance() 的第一个参数是指定参数类型，而第二个参数是用来指定数组长度的，结果如下：

```
0 1 2 3 4
0 1 2 3 4
```

如果是二维数组，也是一样的：

```
package CoreJava.day_2;

import java.lang.reflect.Array;

/**
 * @author 李智
 * @date 2016/12/5
 */
public class NewArrayDemo2 {
    public static void main(String[] args) {
        Class c = String.class;

        // 打算建立一个3*4数组
        int[] dim = new int[]{3, 4};
        Object objArr = Array.newInstance(c, dim);

        for (int i = 0; i < 3; i++) {
            Object row = Array.get(objArr, i);
            for (int j = 0; j < 4; j++) {
                Array.set(row, j, "" + (i + 1) * (j + 1));
            }
        }

        for (int i = 0; i < 3; i++) {
            Object row = Array.get(objArr, i);
            for (int j = 0; j < 4; j++) {
                System.out.print(Array.get(row, j) + " ");
            }
            System.out.println();
        }
    }
}

```

输出结果：

```
1 2 3 4
2 4 6 8
3 6 9 12
```

如果想要知道数组元素的类型，可以在取得数组的 Class 实例之后，使用 Class 实例的 getComponentType() 方法，所取回的是元素的 Class 实例，例如：

```
int[] iArr = new int[5];
System.out.println(iArr.getClass().getComponentType());
```


对反射的总结差不多就写到这里了，查阅了很多资料，网络上写的也是参差不齐的，在手写的几十个demo支撑下，得出的一点关于反射的东西，肯定不能说全部正确，但是还是可以提供一些帮助的  -。-
