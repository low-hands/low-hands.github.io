---
title: Leetcode 541 - 反转字符串II
date: 2026-01-19T23:12:00-08:00
description: 双指针 - 反转字符串II
menu:
  sidebar:
    name: Leetcode 541.反转字符串II
    identifier: Leetcode541
    parent: twopointer
    weight: 30
math: true
hero: image.png
---

[题目链接](https://leetcode.cn/problems/reverse-string-ii/description/)
## 题目描述
给定一个字符串 s 和一个整数 k，从字符串开头算起, 每计数至 2k 个字符，就反转这 2k 个字符中的前 k 个字符。

如果剩余字符少于 k 个，则将剩余字符全部反转。

如果剩余字符小于 2k 但大于或等于 k 个，则反转前 k 个字符，其余字符保持原样。

示例:

>输入: s = "abcdefg", k = 2
>输出: "bacdfeg"
## 思路
我使用的是最简单的思路，即将这条题目理解为局部的反转字符串

所以一部分代码就是反转字符串，然后外层再嵌套一个选取局部区间的循环即可

### 初始化

反转字符串部分为双指针操作，即相向双指针，左指针为起点，右指针为终点
外层嵌套直接一个`for`循环或者`while`循环，根据剩余字符的数量分类讨论

### 循环条件

对反转字符串`reverse`，两个指针相遇后循环停止

外层循环即遍历完整个字符串数组即可，不过步长不为1，而是`2*k`

## 代码

### Python
#### 1. 简单粗暴
```python
class Solution(object):
    def reverseStr(self, s, k):
        """
        :type s: str
        :type k: int
        :rtype: str
        """
        l = len(s)
        s = list(s)
        left = 0
        while(left<l):
            if(left+k>l-1):
                self.reverse(s,left,l - 1)
            else:
                self.reverse(s,left,left+k - 1)
            left+=2*k
        s = "".join(s)
        return s
    def reverse(self,s,left, right):
        while(left<right):
            x = s[left]
            s[left] = s[right]
            s[right] = x
            left += 1
            right -= 1
        return s
```

##### 复杂度分析
时间复杂度： O(n)   （尽管是嵌套循环，但是对于外循环中的每个元素，它的`reverse`是针对有限个元素left to right的，而不是每个元素都要再循环n次，所以依旧是常数次）

空间复杂度： O(n)   （python中的字符串不可变，需要将其转成list再进行操作，额外开辟了一个数组空间）

#### 2. 待续

## 易错点
- python字符串不可变，要进行数组操作要用`list(s)`将其转为数组，最后要返回字符串要进行`"".join(s)`
- `reverse`的终点不要忘记-1，这才是`k`个，否则是`(left+k-left+1) = k+1`，就会出错
## 收获
- pthon数组是不可变的，不能直接进行数组操作。
- 注意循环的边界条件的处理

