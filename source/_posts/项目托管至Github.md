---
title: 项目托管至Github
date: 2018-01-02 15:45:42
categories: 项目管理
tags:
	- github
	- 版本控制
---

本地新建项目后，如何同步到 github 上呢？

1. 在GitHub上新建项目
2. 进入本地项目目录，依次执行

> git init
> git add .
> git commit -m "备注"
> git remote add origin 仓库地址
> git push -u origin master

<!-- more -->

### 命令说明：

#### git init

> 初始化本地仓库

#### git add .

> 添加全部已经修改的文件，准备commit 提交 该命令效果等同于 git add -A

#### git commit -m ‘提交说明’

> 将修改后的文件提交到本地仓库，如：git commit -m ‘增加README.md说明文档’

#### git remote add origin 远程仓库地址

> 连接到远程仓库并为该仓库创建别名 , 别名为origin . 这个别名是自定义的，通常用origin ; 远程仓库地址，就是你自己新建的那个仓库的地址，复制地址的方法参考 第二张图。 
> 如：git remote add origin https://github.com/JustDoItLee/xxxxxx.git 这段代码的含义是： 连接到github上https://github.com/JustDoItLee/xxxxxx.git 这个仓库，并创建别名为origin . （之后push 或者pull 的时候就需要使用到这个 origin 别名）

#### git push -u origin master

> 创建一个 upStream （上传流），并将本地代码通过这个 upStream 推送到 别名为 origin 的仓库中的 master 分支上
>
> -u ，就是创建 upStream 上传流，如果没有这个上传流就无法将代码推送到 github；同时，这个 upStream 只需要在初次推送代码的时候创建，以后就不用创建了
>
> 另外，在初次 push 代码的时候，可能会因为网络等原因导致命令行终端上的内容一直没有变化，耐心等待一会就好。

### 排错

如果执行 `git push -u origin master` 报错，是因为在 github 上项目不是空的，大部分情况是因为有一个 `README.md` 文件

> error: failed to push some refs to 'git@github.com:xxxxxx.git'
> hint: Updates were rejected because the remote contains work that you do
> hint: not have locally. This is usually caused by another repository pushing
> hint: to the same ref. You may want to first integrate the remote changes
> hint: (e.g., 'git pull ...') before pushing again.
> hint: See the 'Note about fast-forwards' in 'git push --help' for details.

执行下面的代码，把github上没有拉下来的代码或文件拉下来

> git pull --rebase origin master

然后再执行

>  git push -u origin master

提交代码即可。

### 结语

所以如果在`github` 上新建项目时初始化了 `README` 文件，按下面的顺序执行命令就可以

> git init git add . git commit -m "备注" git remote add origin 仓库地址 git pull --rebase origin master git push -u origin master

 

