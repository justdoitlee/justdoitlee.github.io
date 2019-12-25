---
title: Github建立分支备份Hexo
date: 2019-01-12 11:23:35
categories: 杂七杂八
tags:
	- hexo
	- 备份
---

# 前言

由于之前忘记备份Hexo博客的markdown文件，在重做系统时候还忘记备份博客了，导致现在不得不重新从网页上扒下来之前的文章重新写一遍，十分耗费精力。因此在网上找了下如何备份Hexo博客，在此记录下。

# 备份博客

先将本地Hexo博客已经初始化

## 创建新分支

在Github.io上建立博客时已经开了一个新仓库了，如果再开另一个仓库存放源代码有点浪费，因此采用建立新分支的方法备份博客。

虽然理论上什么时候创建新分支来备份都可以，但是还是建议在建立博客的时候就创建备份分支。（然而我中途才想起来-.-）

不过在建立新分支前请确保仓库内已有`master`分支（Hexo本地建站后第一次上传时会自动生成），否则后期再添加`master`分支比较麻烦（请自行搜索`git`命令）。

本地Git建立新分支命令如下：

```
$ git checkout -b BRANCHNAME
```

`BRANCHNAME`是自定义的新分支的名字，建议起为`hexo`。

<!--more-->

## 建立.gitignore

建立`.gitignore`文件将不需要备份的文件屏蔽。个人的`.gitignore`文件如下：

```
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
```

## 在Github上备份

通过如下命令将本地文件备份到Github上。

假设目前在hexo博客的根目录下。

```
$ git add .
$ git commit -m "Backup"
$ git push origin hexo
```

这样就备份完博客了且在Github上能看到两个分支(`master`和`hexo`)。

## 设置默认分支

在Github上你的github.io仓库中设置默认分支为`hexo`。这样有助于之后恢复博客。`master`分支时默认的博客静态页面分支，在之后恢复博客的时候并不需要。

## 个人备份习惯

个人而言习惯于先备份文件再生成博客。即先执行`git add .`,`git commit -m "Backup"`,`git push origin hexo`将博客备份完成，然后执行`hexo g -d`发布博客。

# 恢复博客

先把本地Hexo博客基础环境已经搭好

## 克隆项目到本地

输入下列命令克隆博客必须文件(`hexo`分支)：

```
$ git clone https://github.com/yourgithubname/yourgithubname.github.io
```

## 恢复博客

在克隆的那个文件夹下输入如下命令恢复博客：

```
$ npm install hexo-cli
$ npm install
$ npm install hexo-deployer-git
```

在此不需要执行`hexo init`这条指令，因为不是从零搭建起新博客。



## 提交准备



（1）打开git bash，在用户主目录下运行：ssh-keygen -t rsa -C "youremail@example.com" 把其中的邮件地址换成自己的邮件地址，然后一路回车

（2）最后完成后，会在用户主目录下生成.ssh目录，里面有id_rsa和id_rsa.pub两个文件，这两个就是SSH key密钥对，id_rsa是私钥，千万不能泄露出去，id_rsa.pub是公钥，可以放心地告诉任何人。

（3）登陆GitHub，打开「Settings」-&gt;「SSH and GPG keys」，然后点击「new SSH key」，填上任意Title，在Key文本框里粘贴公钥id_rsa.pub文件的内容（千万不要粘贴成私钥了！），最后点击「Add SSH Key」，你就应该看到已经添加的Key。注意：不要在git版本库中运行ssh，然后又将它提交，这样就把密码泄露出去了。



完成～



