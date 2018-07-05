---
title: Java基于zxing生成二维码demo
date: 2017-03-23 19:43:10
categories: Java二三事
tags:
	- Java
	- 二维码
---
QR码属于矩阵式二维码中的一个种类，由DENSO(日本电装)公司开发，由JIS和ISO将其标准化。QR码的样子其实在很多场合已经能够被看到了，我这还是贴个图展示一下：

<img src="http://img.blog.csdn.net/20170323193748791?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvTWVsb2RfYmM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast" height="300" width="300" />
<!--more-->

这个图如果被正确解码，应该看到百度。

具体的也不说什么了，百度一大把，直接上源码~

```
package com.lincoln.Untils;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;

import javax.imageio.ImageIO;
import java.io.File;
import java.io.OutputStream;
import java.io.IOException;
import java.awt.image.BufferedImage;
import java.util.Hashtable;

public class QRUtil {

    private static final int BLACK = 0xFF000000;
    private static final int WHITE = 0xFFFFFFFF;

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        String text = "http://www.baidu.com";
        int width = 300;
        int height = 300;
        //二维码的图片格式
        String format = "gif";
        Hashtable hints = new Hashtable();
        //内容所使用编码
        hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
        BitMatrix bitMatrix = new MultiFormatWriter().encode(text,
                BarcodeFormat.QR_CODE, width, height, hints);
        //生成二维码
        File outputFile = new File("/Users/lizhi/Downloads" + File.separator + "new.gif");
        QRUtil.writeToFile(bitMatrix, format, outputFile);
    }

    private QRUtil() {
    }


    public static BufferedImage toBufferedImage(BitMatrix matrix) {
        int width = matrix.getWidth();
        int height = matrix.getHeight();
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                image.setRGB(x, y, matrix.get(x, y) ? BLACK : WHITE);
            }
        }
        return image;
    }


    public static void writeToFile(BitMatrix matrix, String format, File file)
            throws IOException {
        BufferedImage image = toBufferedImage(matrix);
        if (!ImageIO.write(image, format, file)) {
            throw new IOException("Could not write an image of format " + format + " to " + file);
        }
    }


    public static void writeToStream(BitMatrix matrix, String format, OutputStream stream)
            throws IOException {
        BufferedImage image = toBufferedImage(matrix);
        if (!ImageIO.write(image, format, stream)) {
            throw new IOException("Could not write an image of format " + format);
        }
    }
}
```

恩，就这么简单。
