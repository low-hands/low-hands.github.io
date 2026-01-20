---
title: Leetcode 344 - 反转字符串
date: 2026-01-19T12:10:00-08:00
description: 双指针 - 反转字符串
menu:
  sidebar:
    name: Leetcode 344.反转字符串
    identifier: Leetcode344
    parent: twopointer
    weight: 30
math: true
hero: image.png
---

[题目链接](https://leetcode.cn/problems/reverse-string/description/)
## 题目描述

编写一个函数，其作用是将输入的字符串反转过来。输入字符串以字符数组 s 的形式给出。

不要给另外的数组分配额外的空间，你必须原地修改输入数组、使用 O(1) 的额外空间解决这一问题。

示例 1：

>输入：s = ["h","e","l","l","o"]
>输出：["o","l","l","e","h"]

示例 2：

>输入：s = ["H","a","n","n","a","h"]
>输出：["h","a","n","n","a","H"]

## 思路
相向指针：一个指针在起点，一个指针在终点

两端同时往内收，步长一致，直到两者错过（左大于右），则遍历结束

### 初始化

左指针为起点`0`，有指针为终点`len(s)-1`

### 循环条件

当两者相遇后终止循环，如果两者索引相同的时候（数组长度为奇数），该元素可以不进入循环进行交换，所以while可以不包括等号

包括等号也可以，相当于中间元素与自己完成了一次交换

## 代码

### Python
```python
class Solution(object):
    def reverseString(self, s):
        """
        :type s: List[str]
        :rtype: None Do not return anything, modify s in-place instead.
        """
        left = 0
        right = len(s) - 1
        while left < right:
            i = s[left]
            s[left] = s[right]
            s[right] = i
            left += 1
            right -= 1
        return s 
```


## 复杂度分析
时间复杂度： O(n)   （while单循环，单循环内都是常数时间的操作）

空间复杂度： O(1)   （在原数组修改，没有其余新的数组空间产生）
## 易错点
- 是在原数组进行修改，只需要返回k，不需要返回一个新数组，自己创建新数组不符合要求。
- `while`的边界条件可以不包括等号，也可以包括，因为可以自己与自己交换，即`nums[i] = nums[i]`
## 收获
- 反转，即暗示可以用同向指针，因为是在原数组上修改，只能交换元素，在不开辟新数组的情况下理应考虑双指针

