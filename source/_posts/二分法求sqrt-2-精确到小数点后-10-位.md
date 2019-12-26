---
title: 二分法求sqrt (2)精确到小数点后 10 位
date: 2019-12-26 14:15:08
categories: Java二三事
tags:
	- Java
	- 算法
---

##### 因为 sqrt(2)约等于 1.4，所以可以在(1.4, 1.5)区间做二分

```java
private static final double TEN = 0.0000000001;

    private static double sqrt2() {
        double low = 1.4;
        double high = 1.5;
        double mid = (low + high) / 2;
        while ((high - low) > TEN) {
            if (high * high > 2) {
                high = mid;
            } else {
                low = mid;
            }
            mid = (low + high) / 2;
        }
        return mid;
    }

```

