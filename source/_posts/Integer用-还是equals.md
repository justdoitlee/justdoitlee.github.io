---
title: Integer用==还是equals
date: 2020-09-03 17:20:49
categories: Java二三事
tags:
	- Java
---

今天刷minimum-window-substring问题时，写的代码跑通了267/268的测试用例，最后一个没跑通，最后发现是

`window.get(d) == need.get(d)`出的问题，两个值都是371但是结果是false，然后才想起来Interger底部是有缓存的，关系如下：

Integer与int类型的关系，可以简单的回答，Integer是int的包装类，int的默认值是0，而Integer的默认值是null（jdk1.5的新特性 自动装箱和拆箱，Integer.valueOf（） 和xx.intValue（） ）,需要注意的是Integer里面默认的缓存数字是`-128-127`。

1、Integer与Integer相互比较，数据在`-128-127`范围内，就会从缓存中拿去数据，比较就相等；如果不在这个范围，就会直接新创建一个Integer对象，使用 == 判断的是两个内存的应用地址，所以自然不相等，应该用equals来判断值是否想等

2、Integer和int类型相比，在jdk1.5,会自动拆箱，然后比较栈内存中的数据，所以没有不想等的情况

