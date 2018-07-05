---
title: 实验插入b站h5播放器
date: 2017-02-18 16:42:57
categories: 博客
tags: 
	- 小插件
---

Hexo 插 B 站的播放器很简单，在 md 文档中插个 iframe 标签就行，aid 和 cid 值需要手动填写，播放器大小可以自己调节：

>B 站每个视频都有对应的 aid 和 cid 值，在视频网页的源代码中可以找到

<!--more-->

```
<iframe src="https://www.bilibili.com/html/html5player.html?aid=3521416&cid=6041635" width="960" height="600" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
```
<br>
<iframe src="https://www.bilibili.com/html/html5player.html?aid=3521416&cid=6041635" width="960" height="600" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

