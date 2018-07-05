---
title: 关于Ajax的cache参数的测试
date: 2017-02-18 20:42:59
categories: Java二三事
tags: 
	- JavaScript
	- Ajax
	- cache
---
&nbsp;&nbsp;其实这次做这个测试是因为和同学谈论@requestbody时引发的一个笑话，我之前一直以为ajax中的`dataType: 'json'`是传输去后台的数据格式，后来分分钟被打脸，查了一下百度，才知道原来`dataType: 'json'`是期望返回的数据类型，由此才发现原来ajax并没有平常用的那么简单。
<!--more-->
首先我们来看一下什么是Ajax：
AJAX = 异步 JavaScript 和 XML。
AJAX 是一种用于创建快速动态网页的技术。
通过在后台与服务器进行少量数据交换，AJAX 可以使网页实现异步更新。这意味着可以在不重新加载整个网页的情况下，对网页的某部分进行更新。
传统的网页（不使用 AJAX）如果需要更新内容，必需重载整个网页面。
有很多使用 AJAX 的应用程序案例：新浪微博、Google 地图、开心网等等。(以上来自w3cschool)
         
在看这些资料的过程中，一个参数引起了我的注意：**cache** 这个cache有true和false两个方向，<font color=red>显式的要求如果当前请求有缓存的话，直接使用缓存。如果该属性设置为 false，则每次都会向服务器请求</font>。由此我做了下面的测试：

首先创建一个servlet，用来接收客户端发来的请求

AjaxServlet.java

```
public class AjaxServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("进入了servlet!");
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        int a = 1;
        out.print(a);
        out.flush();
        out.close();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
```
这里做出了标记，如果请求进来了，控制台会输出"进入了servlet"

然后创建一个Jsp用来发出请求：
ajaxTest.jsp

```
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String path = request.getContextPath(); %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<button id="ajaxBtn" value="点我试试~">点我试试~</button>
</body>
<script src="jquery.js"></script>
<script>
    $("#ajaxBtn").click(function () {
        $.ajax({
            url: "<%=path%>/AjaxServlet",
            type: 'get',
            cache: true,
            success: function (data) {
                alert(data);
            }
        });
    })
</script>
</html>

```
这里点击这个按钮可以出发一个get请求，我们把cache设置为了true，这样会在浏览器缓存中加载请求信息。

![这里写图片描述](http://img.blog.csdn.net/20161123204951948)


![](http://img.blog.csdn.net/20161123205002870)<br>

可以看出第一次成功进入了servlet，前台也alert出了这个返回的值。

接着我们点击第二次，发现居然还是进入了servlet!!!!!<br>
![这里写图片描述](http://img.blog.csdn.net/20161123205119785)
<br>
这是怎么回事呢？ 没办法只能继续踏上百度谷歌之路，经过查找发现，在IE浏览器下，可以实现这个功能，点击两次，第二次就不再进入servlet了。<br>
![](http://img.blog.csdn.net/20161123205002870)
<br>
不过，并不鼓励使用cache:true,因为ajax是实时获取数据的，所以不太适合从缓存中加载信息，我想也正是因为这个原因，谷歌 safari浏览器实现不了这个功能吧，那么问题来了为什么ie还可以这么坚挺？（日常吐槽）。

附：ajax其他参数<br>
**参数：**
url: 要求为String类型的参数，（默认为当前页地址）发送请求的地址。
type: 要求为String类型的参数，请求方式（post或get）默认为get。注意其他http请求方法，例如put和delete也可以使用，但仅部分浏览器支持。
timeout: 要求为Number类型的参数，设置请求超时时间（毫秒）。此设置将覆盖$.ajaxSetup()方法的全局设置。
async：要求为Boolean类型的参数，默认设置为true，所有请求均为异步请求。如果需要发送同步请求，请将此选项设置为false。注意，同步请求将锁住浏览器，用户其他操作必须等待请求完成才可以执行。
cache：要求为Boolean类型的参数，默认为true（当dataType为script时，默认为false）。设置为false将不会从浏览器缓存中加载请求信息。
data: 要求为Object或String类型的参数，发送到服务器的数据。如果已经不是字符串，将自动转换为字符串格式。get请求中将附加在url后。防止这种自动转换，可以查看processData选项。对象必须为key/value格
 式，例如{foo1:"bar1",foo2:"bar2"}转换为&foo1=bar1&foo2=bar2。如果是数组，JQuery将自动为不同值对应同一个名称。例如{foo:["bar1","bar2"]}转换为&foo=bar1&foo=bar2。
dataType: 要求为String类型的参数，预期服务器返回的数据类型。如果不指定，JQuery将自动根据http包mime信息返回responseXML或responseText，并作为回调函数参数传递。
          可用的类型如下：<br>
          xml：返回XML文档，可用JQuery处理。<br>
          html：返回纯文本HTML信息；包含的script标签会在插入DOM时执行。<br>
          script：返回纯文本JavaScript代码。不会自动缓存结果。除非设置了cache参数。注意在远程请求时（不在同一个域下），所有post请求都将转为get请求。<br>
          json：返回JSON数据。<br>
          jsonp：JSONP格式。使用SONP形式调用函数时，例如myurl?callback=?，JQuery将自动替换后一个“?”为正确的函数名，以执行回调函数。<br>
          text：返回纯文本字符串。
beforeSend：要求为Function类型的参数，发送请求前可以修改XMLHttpRequest对象的函数，例如添加自定义。
            HTTP头。在beforeSend中如果返回false可以取消本次ajax请求。XMLHttpRequest对象是惟一的参数。



