---
title: Logger级别
date: 2017-02-18 21:22:28
categories: Java二三事
tags: 
	- Logger
---
日志记录器(Logger)是日志处理的核心组件。log4j具有5种正常级别(Level)。日志记录器(Logger)的可用级别Level (不包括自定义级别 Level)， <!--more-->以下内容就是摘自log4j API (http://jakarta.apache.org/log4j/docs/api/index.html):<br>
**static Level DEBUG**<br>
DEBUG Level指出细粒度信息事件对调试应用程序是非常有帮助的。
**static Level INFO**<br>
INFO level表明 消息在粗粒度级别上突出强调应用程序的运行过程。
**static Level WARN**<br>
WARN level表明会出现潜在错误的情形。
**static Level ERROR**<br>
ERROR level指出虽然发生错误事件，但仍然不影响系统的继续运行。
**static Level FATAL**<br>
FATAL level指出每个严重的错误事件将会导致应用程序的退出。
另外，还有两个可用的特别的日志记录级别: (以下描述来自log4j API http://jakarta.apache.org/log4j/docs/api/index.html):<br>
**static Level ALL**<br>
ALL Level是最低等级的，用于打开所有日志记录。
**static Level OFF**<br>
OFF Level是最高等级的，用于关闭所有日志记录。
日志记录器（Logger）的行为是分等级的。如下表所示：
分为OFF、FATAL、ERROR、WARN、INFO、DEBUG、ALL或者您定义的级别。<font color=red>Log4j建议只使用四个级别，优先级从高到低分别是 ERROR、WARN、INFO、DEBUG。</font>通过在这里定义的级别，您可以控制到应用程序中相应级别的日志信息的开关。<font color=red>比如在这里定义了INFO级别，则应用程序中所有DEBUG级别的日志信息将不被打印出来，也是说大于等于的级别的日志才输出。</font>
 
<font color=red>日志记录的级别有继承性，子类会记录父类的所有的日志级别。</font>