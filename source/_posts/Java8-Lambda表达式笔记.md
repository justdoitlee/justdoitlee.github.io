---
title: Java8 Lambda表达式笔记
date: 2018-07-07 09:26:39
categories: Java二三事
tags:
	- Java
---

项目的jdk版本从1.7升到了1.8之后，学习了一下java8的新特性，其中Lambda表达式可以使得java类的构造方法看起来紧凑而简洁，没有很多复杂的模板代码，所以写一篇博客记录一下。

先从一个简单的例子来看一下Java8之前的写法：

```java
List<String> params = Arrays.asList("id", "name", "age", "salary");

Collections.sort(params, new Comparator<String>() {
    @Override
    public int compare(String a, String b) {
        return b.compareTo(a);
    }
});
```

这是一个排序的对String列表进行排序的方法，静态工具方法Collections.sort接受一个list，和一个Comparator接口作为输入参数，Comparator的实现类可以对输入的list中的元素进行比较。通常情况下，你可以直接用创建匿名Comparator对象，并把它作为参数传递给sort方法。

除了创建匿名对象以外，Java 8 还提供了一种更简洁的方式，Lambda表达式。

```java
Collections.sort(params, (String a, String b) -> {
    return b.compareTo(a);
});
```

你可以看到，这段代码就比之前的更加简短和易读。但是，它还可以更加简短：

 ```java
Collections.sort(params, (String a, String b) -> b.compareTo(a));
 ```

只要一行代码，包含了方法体。你甚至可以连大括号对{}和return关键字都省略不要。不过这还不是最短的写法：

```java
Collections.sort(params, (a, b) -> b.compareTo(a));
```

 Java编译器能够自动识别参数的类型，所以你就可以省略掉类型不写。<!--more-->

下面可以再深入地研究一下lambda表达式的威力:

Lambda表达式如何匹配Java的类型系统？每一个lambda都能够通过一个特定的接口，与一个给定的类型进行匹配。一个所谓的函数式接口必须要有且仅有一个抽象方法声明。每个与之对应的lambda表达式必须要与抽象方法的声明相匹配。由于默认方法不是抽象的，因此你可以在你的函数式接口里任意添加默认方法。

任意只包含一个抽象方法的接口，我们都可以用来做成lambda表达式。为了让你定义的接口满足要求，你应当在接口前加上@FunctionalInterface 标注。编译器会注意到这个标注，如果你的接口中定义了第二个抽象方法的话，编译器会抛出异常

例如：

```java
@FunctionalInterface
interface Converter<F, T> {
    T convert(F from);
}

Converter<String, Integer> converter = (from) -> Integer.valueOf(from);
Integer converted = converter.convert("123");
System.out.println(converted);    // 123
```



ps：如果不写@FunctionalInterface 标注，程序也是正确的

上面的代码通过静态方法引用的话，会更加简洁：

```java
Converter<String, Integer> converter = Integer::valueOf;
Integer converted = converter.convert("123");
System.out.println(converted);   // 123
```

Java 8 允许通过::关键字获取方法或者构造函数的的引用。上面的例子就演示了如何引用一个静态方法。而且，我们还可以对一个对象的方法进行引用：

```java
class Something {
    String startsWith(String s) {
        return String.valueOf(s.charAt(0));
    }
}

Something something = new Something();
Converter<String, String> converter = something::startsWith;
String converted = converter.convert("Java");
System.out.println(converted);    // "J"

```

让我们看看如何使用::关键字引用构造函数。首先我们定义一个示例bean，包含不同的构造方法：

```java
class Person {
    String firstName;
    String lastName;

    Person() {}

    Person(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }
}
```

接下来，我们定义一个person工厂接口，用来创建新的person对象：

```java
interface PersonFactory<P extends Person> {
    P create(String firstName, String lastName);
}
```

然后我们通过构造函数引用来把所有东西拼到一起，而不是像以前一样，通过手动实现一个工厂来这么做。

```java
PersonFactory<Person> personFactory = Person::new;
Person person = personFactory.create("Peter", "Parker");
```

我们通过Person::new来创建一个Person类构造函数的引用。Java编译器会自动地选择合适的构造函数来匹配PersonFactory.create函数的签名，并选择正确的构造函数形式。

-----------------------------------------------------------------------------------------------------------------------------------------

接下来讨论一下lambda的访问范围，对于lambda表达式外部的变量，其访问权限的粒度与匿名对象的方式非常类似。你能够访问局部对应的外部区域的局部final变量，以及成员变量和静态变量。

我们可以访问lambda表达式外部的final局部变量：

```java
final int num = 1;
Converter<Integer, String> stringConverter =
        (from) -> String.valueOf(from + num);

stringConverter.convert(2);     // 3
```

但是与匿名对象不同的是，变量num并不需要一定是final。下面的代码依然是合法的：

```java
int num = 1;
Converter<Integer, String> stringConverter =
        (from) -> String.valueOf(from + num);

stringConverter.convert(2);     // 3
```

然而，num在编译的时候被隐式地当做final变量来处理。下面的代码就不合法：

```java
int num = 1;
Converter<Integer, String> stringConverter =
        (from) -> String.valueOf(from + num);
num = 3;
```

在lambda表达式内部企图改变num的值也是不允许的。

与局部变量不同，我们在lambda表达式的内部能获取到对成员变量或静态变量的读写权。这种访问行为在匿名对象里是非常典型的。

```java
class Lambda4 {
    static int outerStaticNum;
    int outerNum;

    void testScopes() {
        Converter<Integer, String> stringConverter1 = (from) -> {
            outerNum = 23;
            return String.valueOf(from);
        };

        Converter<Integer, String> stringConverter2 = (from) -> {
            outerStaticNum = 72;
            return String.valueOf(from);
        };
    }
}
```



 默认方法无法在lambda表达式内部被访问。







