---
title: nSum 问题
date: 2020-09-14 14:42:24
categories: 算法
tags: 
	- 框架
---
[1.两数之和](https://leetcode.com/problems/two-sum/)

[15.三数之和](https://leetcode.com/problems/3sum/)

[18.四数之和](https://leetcode.com/problems/4sum/)

```
/**
     * 100sum
     * 调用前 先给数组排序  Arrays.sort(nums);
     */
    public List<List<Integer>> nSumTarget(int[] nums, int n, int start, int target) {
        List<List<Integer>> res = new ArrayList<>();
        int sz = nums.length;
        //至少2sum
        if (n < 2 || sz < n) {
            return res;
        }
        //从2sum开始
        if (n == 2) {
            //双指针
            int left = start;
            int right = sz - 1;
            while (left < right) {
                int sum = nums[left] + nums[right];
                int lv = nums[left];
                int rv = nums[right];
                if (sum < target) {
                    while (left < right && nums[left] == lv) {
                        left++;
                    }
                } else if (sum > target) {
                    while (left < right && nums[right] == rv) {
                        right--;
                    }
                } else {
                    List<Integer> l = new ArrayList<>();
                    l.add(lv);
                    l.add(rv);
                    res.add(l);
                    while (left < right && nums[left] == lv) {
                        left++;
                    }
                    while (left < right && nums[right] == rv) {
                        right--;
                    }
                }
            }
        } else {
            // n > 2时 递归计算（n - 1）sum 的结果
            for (int i = start; i < sz; i++) {
                List<List<Integer>> sub = nSumTarget(nums, n - 1, i + 1, target - nums[i]);
                for (List<Integer> arr : sub) {
                    //（n - 1）sum + num[i] = nsum
                    arr.add(nums[i]);
                    res.add(arr);
                }
                while (i < sz - 1 && nums[i] == nums[i + 1]) {
                    i++;
                }
            }
        }
        return res;
    }
```

tips:

调用前先给数组排序

```
nsum调用
int[] arr = new int[]{};
Arrays.sort(arr);
nSumTarget(arr, n, 0, target)
```

