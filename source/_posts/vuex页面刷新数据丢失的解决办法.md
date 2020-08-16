---
title: vuex页面刷新数据丢失的解决办法
date: 2020-08-15 23:38:23
categories: 前端
tags:
	- vue
---

在vue项目中用vuex来做全局的状态管理， 发现当刷新网页后，保存在vuex实例store里的数据会丢失。

**原因：**

因为store里的数据是保存在运行内存中的,当页面刷新时，页面会重新加载vue实例，store里面的数据就会被重新赋值初始化

<!-- more -->

**解决思路：**

将state的数据保存在localstorage、sessionstorage或cookie中，这样即可保证页面刷新数据不丢失且易于读取。

1. localStorage: localStorage的生命周期是永久的，关闭页面或浏览器之后localStorage中的数据也不会消失。localStorage除非主动删除数据，否则数据永远不会消失。
2. sessionStorage:sessionStorage的生命周期是在仅在当前会话下有效。sessionStorage引入了一个“浏览器窗口”的概念，sessionStorage是在同源的窗口中始终存在的数据。只要这个浏览器窗口没有关闭，即使刷新页面或者进入同源另一个页面，数据依然存在。但是sessionStorage在关闭了浏览器窗口后就会被销毁。同时独立的打开同一个窗口同一个页面，sessionStorage也是不一样的。
3. cookie:cookie生命期为只在设置的cookie过期时间之前一直有效，即使窗口或浏览器关闭。 存放数据大小为4K左右,有个数限制（各浏览器不同），一般不能超过20个。缺点是不能储存大数据且不易读取。

由于vue是单页面应用，操作都是在一个页面跳转路由，因此sessionStorage较为合适,原因如下：

1. sessionStorage可以保证打开页面时sessionStorage的数据为空；
2. 每次打开页面localStorage存储着上一次打开页面的数据，因此需要清空之前的数据。

vuex中state数据的修改必须通过mutation方法进行修改，因此mutation修改state的同时需要修改sessionstorage,问题倒是可以解决但是感觉很麻烦，state中有很多数据，很多mutation修改state就要很多次sessionstorage进行修改，既然如此直接用sessionstorage解决不就行了，为何还要用vuex多此一举呢？ vuex的数据在每次页面刷新时丢失，是否可以在页面刷新前再将数据存储到sessionstorage中呢，是可以的，[beforeunload](https://www.w3cschool.cn/fetch_api/fetch_api-9vhu2oq0.html)事件可以在页面刷新前触发，但是在每个页面中监听beforeunload事件感觉也不太合适，那么最好的监听该事件的地方就在app.vue中。

1. 在app.vue的created方法中读取sessionstorage中的数据存储在store中，此时用vuex.store的[replaceState](https://vuex.vuejs.org/zh/api/#replacestate)方法，替换store的根状态
2. 在beforeunload方法中将store.state存储到sessionstorage中。

**代码如下：**

```js
export default {
  name: 'App',
  created () {
    //在页面加载时读取sessionStorage里的状态信息
    if (sessionStorage.getItem("store") ) {
        this.$store.replaceState(Object.assign({}, this.$store.state,JSON.parse(sessionStorage.getItem("store"))))
    } 

    //在页面刷新时将vuex里的信息保存到sessionStorage里
    window.addEventListener("beforeunload",()=>{
        sessionStorage.setItem("store",JSON.stringify(this.$store.state))
    })
  }
}
```