---
title: Github自定义Overview
date: 2021-04-29 09:45:15
categories: 杂七杂八
tags:
	- github
---

最近逛别人的Github发现别人的Overview很炫酷，然后发现Github允许在个人主页 Your profile 中的 Overview 页面定义自己的内容，来突出用户的个人风格。

在用户名同名库的READ.ME中所填入的所有信息都会被及时渲染到 GitHub 首页，支持常规的 Markdown 语法。效果如下：

<img src="/img/githubOverview.png" />



<!-- more -->

<br />

自定义个人主页之后你会发现除了项目的展示，还有个人的其他信息介绍，下面让说下如何设置吧。

#### 基本操作

##### 1.在你的 github 上创建一个新仓库

这个新仓库的名称要和你登录账号名称保持一致，注意将仓库仓库设置为 Public

##### 2.将远程仓库拉到本地电脑上

用git clone 一下仓库并且创建 README.md 文件，执行以下命令

```
git clone git@github.com:你用户名/你用户名.git
```

##### 3.在本地文件创建 README.md 文件

完成上面几步之后，我们就可以开始推送到你的远程仓库，**按照上面的步骤做完之后就可以查看属于你风格的个人主页了。**

<br />

**PS:可以在第一步时，选择初始化一个 README 文件，创建好后，页面会自动跳转到仓库主页，点击右上角的 `Edit README` 开始制作。**

<br />

#### **定制：**

**1.My Github Stats**

这个其实就是一个url，替换一下username就行，如下所示：

>https://github-readme-stats.anuraghazra1.vercel.app/api?username=username&show_icons=true
>
>https://github-readme-stats.vercel.app/api/top-langs/?username=username&layout=compact

**2.使用徽标**

使用徽标可以使得主页更加吸引眼球，可以在 **http://shield.io** 搜索找到你想要的图标。

**3.waka**

这个是通过GitHub Action，解锁更多玩法，waka就是一款统计工具，可以嵌入各种开发工具中，方法如下：

- 首先打开<a href="https://wakatime.com/">**WakaTime**</a> 网站，使用 GitHub 登录，在首页会生成一个密钥。然后将这个密钥储存到当前仓库的 `Settings/Secrets` 里面，我这里命名为 WAKATIME_API_KEY。

- Settings/Developer settings/Personal access tokens中新建一个token，给**repo, user**权限即可，然后将这个密钥储存到当前仓库的 `Settings/Secrets` 里面，我这里命名为 GH_TOKEN

- 然后新建一个 Action，粘贴下面的代码：

  ```
  name: Waka Readme
  
  on:
    workflow_dispatch:
    schedule:
      # Runs at 12am UTC
      - cron: "0 0 * * *"
  
  jobs:
    update-readme:
      name: Update this repo's README
      runs-on: ubuntu-latest
      steps:
   		# 这里我是fork到自己仓库里了，方便自定义
   		# 也可以用anmol098/waka-readme-stats@master
        - uses: justdoitlee/waka-readme-stats@master
          with:
            WAKATIME_API_KEY: ${{ secrets.WAKATIME_API_KEY }}
            GH_TOKEN: ${{ secrets.GH_TOKEN }}
  ```

  

创建好后，GitHub 会根据 `cron` 配置的定时任务，定时运行上面的 Action，更新 README。

密钥配置如图所示：

<img src="/img/githubSecrets.png"  />

<img src="/img/githubToken.png"  />

具体操作及效果如下：[**waka-readme-stats**](https://github.com/anmol098/waka-readme-stats)