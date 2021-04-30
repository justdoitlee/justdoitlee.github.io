---
title: Iterm2使用agnosterzak打造个性终端
date: 2021-04-22 08:42:00
categories: 杂七杂八
tags:
	- iterm2
---

关机之后打开电脑，突然电脑配置全部恢复默认，Iterm2样式跟着失效了，然后重新打造一下，方便下次快速恢复终端样式。

效果如下：

<img src="/img/iterm2css.png" />

<!-- more -->

准备工作：

> macOS 和 [iTerm](https://www.whatled.com/post-tag/iterm)2 软件

### iTerm 操作

下载 [iTerm](https://www.whatled.com/post-tag/iterm) 软件 ： http://iterm2.com/ 直接下载安装即可;

#### iTerm 主题

##### 1.1 下载主题

下载地址 ： http://iterm2colorschemes.com/

直接下载 `zip` 即可，后解压（主要使用 termite 文件下的主题）

##### 1.2 配置主题

打开 [iTerm](https://www.whatled.com/post-tag/iterm)2 配置 :

> [iTerm](https://www.whatled.com/post-tag/iterm)2 / Preferences / Profiles

新建 `Profile` ， 在 `Other Actions` 下 `Set as Default` , 这样重新打开 `iTerm2` 就是你的配置文件了，当然也可以直接修改默认的 `Profile`

点击Other Actions将当前的Profile设置为默认。

**加载主题**

选择你要修改的`Profile`

> Profile / Colors / Color Presets / import…

点击右下角的 `Color Presets` 下，`Import` 上面我们下载的 `iTerm2` 主题

> 注意: 主要是 termite 文件下的主题，可以全选加入

<img src="/img/iterm2color.png" />



### Oh my ZSH

#### 1. 安装

官网： http://ohmyz.sh/

可以看见两种安装方式：

**curl**

`$ sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

**wget**

`$ sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"`

#### 2. 配置 Theme

访问本地自带的主题：

`cd ~/.oh-my-zsh/themes`

里面有142个自带主题，这些主题在 zsh – theme , 可以查看；

##### 2.1 配置默认主题

打开 [Oh my ZSH](https://www.whatled.com/post-tag/oh-my-zsh) 配置文件

`vim ~/.zshrc`

找到 `ZSH_THEME` 行 修改为默认主题里的任意一个就可以 比如:

`ZSH_THEME="agnosterzak"`

**注意**

> 图片所示的 agnosterzak 非默认主题,需要下载放入 theme 文件夹中

将命令行设置为 **ZSH**

`chsh -s /bin/zsh`

重启 iTerm 可以看到效果；

如果设置 `agnoster` 出现乱码字符是因为没有该类型字体 ： powerline fonts ，后面会说安装该字体;

##### 2.2 配置拓展主题

预览及其下载地址： External-themes

安装 以 AgnosterZak 为例：

访问：*https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme*

`git clone https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme.git`

`cd agnosterzak-ohmyzsh-theme/`

将 `agnosterzak.zsh-theme` 复制到 `~/.oh-my-zsh/themes` 里面，比如：

`cp agnosterzak.zsh-theme ~/.oh-my-zsh/themes`

> 当然 `agnosterzak` 也依赖 power line 字体；

#### 3. powerline 字体

##### 3.1 下载

访问字体地址 ： https://github.com/powerline/fonts

**安装**

\# clone

`git clone https://github.com/powerline/fonts.git`

\# install

`cd fonts ./install.sh`

\# clean-up a bit

`cd ..`

`rm -rf fonts`

##### 3.2 iTerm2 配置使用

> iTerm2 / Preference / Profiles / Text – font

选择 `change font` ， 可以修改字体和字体大小；找到一 [Powerline](https://www.whatled.com/post-tag/powerline) 结尾的字体就可以；

<img src="/img/iterm2font.png" />