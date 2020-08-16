---
title: hexo g 生成空白文件问题
date: 2020-08-16 13:31:30
categories: hexo
tags:
	- 踩坑
---

最近换了新电脑，重新整环境的时候图快，下载`node`的时候下载的是最新版：node当前版14.0.0。然后安装`hexo`，从github拉取hexo博客项目，然后跑`npm install`，都没啥问题。但是在项目下面执行任何`hexo`的命令的时候，就会出现一个错误：

```
(node:62227) Warning: Accessing non-existent property 'lineno' of module exports inside circular dependency
(Use `node --trace-warnings ...` to show where the warning was created)
(node:62227) Warning: Accessing non-existent property 'column' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'filename' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'lineno' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'column' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'filename' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'lineno' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'column' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'filename' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'lineno' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'column' of module exports inside circular dependency
(node:62227) Warning: Accessing non-existent property 'filename' of module exports inside circular dependency
```

继续跑`hexo s`、`hexo clean`、`hexo g`都是可以的，也没报错。

当我跑`hexo s`的时候是可以正常预览的。

但是当我跑`hexo g`的时候，命令可以跑而且没报错，但是生成的文件是`0kb`的，`/public/index.html`里面没有任何内容。

找了好久原因，发现是node版本的问题。

下`n`来管理node的版本。

```
$ sudo npm i -g n
```

然后将node替换为稳定版：

```
$ sudo n stable
```

然后查看node的版本：

```
$ node -v
v12.18.3
```

先清理，然后再生成：

```
$ hexo clean
$ hexo g
```

然后产看生成的`public`文件夹中`index.html`的大小，是有内容的。正常生成了 -。-