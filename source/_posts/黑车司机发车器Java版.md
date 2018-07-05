---
title: 黑车司机发车器Java版
date: 2017-02-18 14:42:57
categories: Java二三事
tags: 
	- Java
	- 黑车
	- 种子
---

既然是发的黑车，磁力链接那套就不必仔细研究了，
磁力链接其实类似于这样（下面的这个是真车）：

>magnet:?xt=urn:btih:3AEA94481B0A406C66083F14C6F42635C14562C2

<!--more-->

说白了就是随机填充 40 个字母或数字，不过有一定几率会发出真车。

 <img src="https://ooo.0o0.ooo/2016/12/25/585f760101362.png " width = "300" height = "300" alt="图片名称" align=center />

<hr>

代码实现：
```
 public class OldDriver {
	public static void main(String[] args) {
		java.util.Scanner input = new java.util.Scanner(System.in);
		System.out.println("黑车司机虚假磁力链接发车器");
		System.out.print("输入需要发的黑车数量：");
		int ljs = input.nextInt();
		for (int i=1;i<=ljs;i++){
			System.out.println("magnet:?xt=urn:btih:"+CLSC());
/*调用 CLSC 函数，获取 40 个随机生成的字符串（CLSC指 磁力生成）*/
		}
	}
	public static String CLSC(){
		String cllj = "";
		String randomchar;
		String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		for (int i=0;i<40;i++){
			int RandomNumber = (int)(Math.random()*35);
/*随机生成一个范围在 [0,35] 的数字*/
			randomchar = "" + chars.charAt(RandomNumber);
/*随机选择一个字符，字符位置由上一步随机数字决定*/
			cllj = cllj+randomchar;
/*将随机字符附到 cllj 字符串上，重复 40 次*/
		}
		return cllj;
	}
}
```

运行效果：
```
黑车司机虚假磁力链接发车器
输入需要发的黑车数量：5
magnet:?xt=urn:btih:126XT8JCPZ6ZWV1Q77OSOAD2P2UOWOAZEIGNN0UH
magnet:?xt=urn:btih:VEKIXXTDDC6STSZN2IS1IQSW6RHJ6ZGC7NEGYIAJ
magnet:?xt=urn:btih:G8Z7O3AIGY2C1PRRNJEZ6Q1VY3HGZQ34E2MOQUWR
magnet:?xt=urn:btih:MRXYGZUFONLDPN5G4E5EDCWMWLI00PB8ZVK6IIKQ
magnet:?xt=urn:btih:3WQ1IYXW0MD3Z32DT80NCJBLTAJ0FC837TB2HW2M
```