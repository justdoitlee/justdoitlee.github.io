---
title: Java解析类Xml格式文件
date: 2018-04-30 08:51:57
categories: Java二三事
tags:
	- Java
	- XML
---

解析上游发来的类XML格式数据，直接使用`Document document = reader.read(path);`会失败，因为不包含`<root></root>`，所以这里需要自己手动拼接一下，方便解析，代码如下：

```java
private static Element getRoot(String path) throws Exception {
        SAXReader saxReader = new SAXReader();
        InputStream is = new FileInputStream(path);
        //因为数据格式不是标准的xml，手动拼接一下方便解析
        Enumeration<InputStream> streams = Collections.enumeration(
                Arrays.asList(new InputStream[]{
                        new ByteArrayInputStream("<root>".getBytes()),
                        is,
                        new ByteArrayInputStream("</root>".getBytes()),
                }));
        SequenceInputStream seqStream = new SequenceInputStream(streams);
        Document document = saxReader.read(seqStream);
        return document.getRootElement();
    }
```

