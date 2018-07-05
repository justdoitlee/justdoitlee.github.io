---
title: userId分库，怎么通过其他字段查询
date: 2017-04-18 10:12:40
categories: 数据库那点事
tags:
	- 分库
---
用户中心是几乎每一个公司必备的基础服务，用户注册、登录、信息查询与修改都离不开用户中心。
 
当数据量越来越大时，需要多用户中心进行水平切分。最常见的水平切分方式，**按照userId取模分库**：<!--more-->

例如：

<img src="http://img.blog.csdn.net/20170418093703450" height="300px" width="500px"/>

通过userId取模，将数据分布到多个数据库实例上去，提高服务实例个数，降低单库数据量，以达到扩容的目的。

这样水平切分之后，userId属性上的查询可以直接路由到库，如上图，假设访问uid=10的数据，取模后能够直接定位db1。


但是分库之后，对于其他字段的查询，就不能这么幸运了。假设访问userName="lizhi"的数据，由于不知道数据落在哪个库上，**往往需要遍历所有库，当分库数量多起来，性能会显著降低**。

所以我要们寻找如何高效查询的方法！（以下用userName为例）

<h2>索引表法</h2>

思路：userId直接定位到库，userName不能直接定位到库，如果通过userName能查询到userId，问题解决。

解决方案：<br>
1）建立一个索引表记录userName->userId的映射关系
2）用userName来访问时，先通过索引表查询到userId，再定位相应的库
3）索引表属性较少，可以容纳非常多数据，一般不需要分库
4）如果数据量过大，可以通过userName来分库

潜在不足：多一次数据库查询，性能下降一倍。

<h2>缓存映射法</h2>
思路：访问索引表性能较低，把映射关系放在缓存里性能更佳。

解决方案：<br>
1）userName查询先到cache中查询userId，再根据userId定位数据库
2）假设cache miss，采用扫全库法获取userName对应的userId，放入cache
3）userName到userId的映射关系不会变化，映射关系一旦放入缓存，不会更改，无需淘汰，缓存命中率超高
4）如果数据量过大，可以通过userName进行cache水平切分

潜在不足：多一次cache查询


<h2>userName生成userId</h2>
思路：不进行远程查询，由userName直接得到userId

解决方案：<br>
1）在用户注册时，设计函数userName生成userId，userId=f(userName)，按userId分库插入数据
2）用userName来访问时，先通过函数计算出userId，即userId=f(userName)再来一遍，由userId路由到对应库

潜在不足：该函数设计需要非常讲究技巧，有userId生成冲突风险


<h2>userName基因融入userId</h2>
思路：不能用userName生成userId，可以从userName抽取“基因”，融入userId中

假设分8库，采用userId%8路由，潜台词是，userId的最后3个bit决定这条数据落在哪个库上，这3个bit就是所谓的“基因”。
 
解决方案：<br>
1）在用户注册时，设计函数userName生成3bit基因，userName_gene=f(userName)
2）同时，生成61bit的全局唯一id，作为用户的标识
3）接着把3bit的userName_gene也作为userId的一部分
4）生成64bit的userId，由id和userName_gene拼装而成，并按照userId库插入数据
5）用userName来访问时，先通过函数由userName再次复原3bit基因，userName_gene=f(userName)，通过userName_gene%8直接定位到库
