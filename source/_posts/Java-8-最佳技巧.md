---
title: Java 8 最佳技巧
date: 2017-02-18 21:24:53
categories: Java二三事
tags: 
	- Java
---
> 翻译文章
转自[一叶知秋](https://muyinchen.github.io/2016/12/13/Java%208%20%E6%9C%80%E4%BD%B3%E6%8A%80%E5%B7%A7/#more)


<br>
在过去的几年中，我一直使用Java 8 进行了很多的编码工作，用于开发 [新应用](http://trishagee.github.io/presentation/java8_in_anger/) 和 [迁移遗留应用](http://trishagee.github.io/presentation/refactoring_to_java_8/) ，我觉得是时候写一些有用的”最佳实践”。我个人不喜欢”最佳实践”这个术语，因为它意味着“一刀切”的解决方案，当然编码工作是不会这样的–这是因为我们开发人员会想出适合我们的方案。但我发现我对Java8特别的喜欢，它让我的生活更轻松一点，所以我想就此话题展开讨论。
<!--more-->
Optional

Optional是一个被严重低估的功能, 它消除了很多困扰着我们的 NullPointerExceptions。它在代码边界（包括你调用和提供 API）处理上特别有用，因为它允许你和你调用的代码说明程序运行的期望结果。

然而，如果没有必要的思考和设计，那么就会导致一个小变化而影响大量的类，也会导致可读性变差。这里有一些关于如何高效使用Optional的提示。
<br>
Optional **应该只用于返回类型**

…不能是参数和属性. 阅读 [这个博客](http://blog.joda.org/2015/08/java-se-8-optional-pragmatic-approach.html) 了解怎样使用 Optional。 幸运的是, IntelliJ IDEA 在打开 [inspection](https://www.jetbrains.com/help/idea/2016.2/code-inspection.html) 功能的情况下会检查你是否遵循了这些建议。


![](http://img.blog.csdn.net/20161214162906891)

可选值应该在使用的地方进行处理.IntelliJ IDEA 的建议可以防止你不恰当的使用Optional, 所以你应该立即处理你发现的不恰当使用Optional。(根据自己的理解翻译)

![这里写图片描述](http://img.blog.csdn.net/20161214163003908)

<br>
**你不应该简单的调用** get()
Optional的目的是为了表示此值有可能为空，且让你有能力来应付这种情况。因此，在使用值之前进行检查是非常重要的。在某些情况下简单的调用get()而没有先使用isPresent()进行检查是一样会导致空指针问题。幸运的是，IntelliJ IDEA 任然会检查出这个问题并警告你。

![这里写图片描述](http://img.blog.csdn.net/20161214163211900)
<br>
**有可能是一个更优雅的方式**

isPresent() 与  get() 结合 使用的技巧 …

![这里写图片描述](http://img.blog.csdn.net/20161214163327369)

…但还有更优雅的解决方案。你可以使用 orElse方法来使得当它为null时给出一个代替的值。

![这里写图片描述](http://img.blog.csdn.net/20161214163422572)

…或者使用 orElseGet方法来处理上述相同情况。这个例子和上面的看起来好像一样，但本例是可以调用 supplier 接口的 实现 ,，因此如果它是一个高开销的方法，可以使用 lambda 表达式来获得更好的性能。

![这里写图片描述](http://img.blog.csdn.net/20161214163525758)

**使用Lambda表达式**

Lambda 表达式 是 Java 8 的卖点之一.。即使你还没有使用过Java 8， 到目前你也可能有一些基本的了解。但在Java编程中还是一种新的方式，它也不是明显的”最佳实践” 。 这里有一些我遵循的指南。

**保持简短**

函数式程序员更愿意使用较长的lambda 表达式，但我们这些仅仅使用Java很多年的程序员来说更容易保持lambda 表达式的短小。你甚至更喜欢把它们限制在一行，更容易把较长的表达式 重构 到一个方法中。

![这里写图片描述](http://img.blog.csdn.net/20161214163709620)

把它们变成一个方法引用， 方法引用看起来有一点陌生，但却值得这样做，因为在某些情况有助于提高可读性，后面我再谈可读性。

![这里写图片描述](http://img.blog.csdn.net/20161214163740278)

**明确的**
(作者应该想要表达的是: 参数命名规范，要有意义；有更好的翻译请修正)

lambda 表达式中类型信息已经丢失了，因此你会发现包含类型信息的参数会更有用。

![这里写图片描述](http://img.blog.csdn.net/20161214163826731)

如你所见，这样会比较麻烦。因此我更喜欢给参数一个更有意义的命名。当然，你做与否， IntelliJ IDEA 都会让你看到参数的类型信息。

![这里写图片描述](http://img.blog.csdn.net/20161214163910185)

即使是在函数式接口的lambda 表达式中:

![这里写图片描述](http://img.blog.csdn.net/20161214163951076)

**针对 Lambda 表达式进行设计**

我认为lambda表达式有点像 泛型 – 泛型,我们经常使用它们 (例如, 给 List<> 添加类型信息 )，但不常见的是我们把一个方法或类泛型化 (如:  Person<'T> )。同样的, 它就像我们使用通过lambdas包装的 Streams API，但对我们来说更罕见的是创建一个需要 lambda 表达式参数的方法。

**IntelliJ IDEA 可以帮助你引入一个函数化的参数**

这里让你可以使用 Lambda 表达式而非对象来 [创建一个参数](https://www.jetbrains.com/help/idea/2016.1/extract-functional-parameter.html) 。这个功能的好处在于其建议使用一个已有的 [函数接口](https://docs.oracle.com/javase/8/docs/api/java/lang/FunctionalInterface.html) 来匹配这个规范。

![这里写图片描述](http://img.blog.csdn.net/20161214164320297)

这个将引导我们

**使用已有的函数接口**

当开发者越来越熟悉 Java 8 代码时，我们会知道使用例如 Supplier 和 Consumer 这样的接口会发生什么，但是单独再创建一个 ErrorMessageCreator 会让我们很诧异并且很浪费时间。你可以翻阅 function package 来查看系统本身已经给我们准备了什么。

**为函数接口添加 @FunctionalInterface 注解**

如果你真的需要创建自己的函数接口，那么就需要用这个  @FunctionalInterface  注解。这个注解似乎没多大用处，但是  IntelliJ IDEA  会在接口不满足这个注解要求的情况下予以提示。例如你没有指定要继承的方法：

![这里写图片描述](http://img.blog.csdn.net/20161214164518523)

指定太多的方法：

![这里写图片描述](http://img.blog.csdn.net/20161214164547695)

在类中使用注解而不是在接口：

![这里写图片描述](http://img.blog.csdn.net/20161214164619204)

Lambda 表达式可用于任意只包含单个抽象方法的接口中，但是不能用于满足该要求的抽象类。看似不符合逻辑，但实际要求必须如此。

<br>
**Streams**

[Stream](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html) API 是Java 8的另一大卖点, 我认为到现在为止，我们仍然不知道这会对我们的编码方式有多大改变．但我发现这是一个好坏参半的功能。

**流式风格**

就我个人而言，更喜欢使用流式风格．当然你不必也这么做, 但我发现它帮助了我：

  ·一眼就能看出有哪些操作，它的执行顺序是什么
·更方便调试（虽然IntelliJ IDEA提供了 [在包含lambda表达式的行上设置断点的能力](https://www.youtube.com/watch?v=rimzOolGguo&feature=youtu.be&t=3s) ，为了更方便调试，把它拆分到不同的行上）* 在测试的时候允许取消一个操作
·在调试或测试是，可以很方便的插入peek()

![这里写图片描述](http://img.blog.csdn.net/20161214165029299)

在我看来这样写很简洁。但是使用这种方法并没有给我们节省多少代码行。你可能需要调整代码格式化设置让代码看起来更加清晰。

![这里写图片描述](http://img.blog.csdn.net/20161214165143409)

<br>
**使用方法引用**

是的，你需要一点时间来适应这个奇怪的语法。但如果使用恰当，真的可以提升代码的可读性，看看下面代码：

![这里写图片描述](http://img.blog.csdn.net/20161214165247861)

以及使用 Objects 类的辅助方法：

![这里写图片描述](http://img.blog.csdn.net/20161214165331410)

后面一段代码更加的明确可读。IntelliJ IDEA 通常会知道怎么将一个 Lambda 表达式进行折叠。

![这里写图片描述](http://img.blog.csdn.net/20161214165408051)

**当对集合进行元素迭代时，尽可能的使用 Streams API**

…或者用新的集合方法，例如 forEach . IntelliJ IDEA 会建议你这么做：

![这里写图片描述](http://img.blog.csdn.net/20161214165535504)

一般来说使用 Streams API 比起循环和 if 语句组合来得更加直观，例如：

![这里写图片描述](http://img.blog.csdn.net/20161214165613194)

IntelliJ IDEA 会建议这样的写法进行重构：

![这里写图片描述](http://img.blog.csdn.net/20161214165649927)

我做过的性能测试显示这种重构带来的结果比较奇怪，难以预测，有时候好，有时候坏，有时候没区别。一如既往的，如果你的应用对性能问题非常在意，请认真的进行衡量。


**遍历数组时请用 for 循环**

然后，使用 Java 8 并不意味着你一定要使用流 API 以及集合的新方法。IntelliJ IDEA 会建议一些做法改用流的方式重构，但你不一定非得接受 (记住 [inspections can be suppressed](https://www.jetbrains.com/help/idea/2016.2/suppressing-inspections.html) 或者 [turned off](https://www.jetbrains.com/help/idea/2016.2/disabling-and-enabling-inspections.html) ).

特别是对一个原始类型的小数组时，使用 for 循环的性能是最好的，而且代码更具可读性（至少对 Streams API 的新手来说是这样）：

![这里写图片描述](http://img.blog.csdn.net/20161214165851697)

任何的技巧和提示都不是一成不变的，你应该自己决定哪里需要使用 Streams API ，而哪里还用循环操作。

**最后**

我每天都在发现一些新的东西，有时候我的偏好会有所变化。例如我过去会讨厌方法的引用。非常期待倾听你的建议。


