---
title: Leetcode 541 - Reverse String II
date: 2026-01-19T23:12:00-08:00
description: Two Pointers - Reverse String II
menu:
  sidebar:
    name: Leetcode 541. Reverse String II
    identifier: Leetcode541
    parent: twopointer
    weight: 30
math: true
hero: image.png
---

# Leetcode 541. Reverse String II
[Problem Link](https://leetcode.cn/problems/reverse-string-ii/description/)

## Problem Description
Given a string `s` and an integer `k`, reverse the first `k` characters for every `2k` characters counting from the start of the string.

If there are fewer than `k` characters left, reverse all of them.

If there are less than `2k` but greater than or equal to `k` characters, reverse the first `k` characters and leave the other as original.

Example:
>Input: s = "abcdefg", k = 2
>Output: "bacdfeg"

## Approach
I used the most straightforward approach, treating this problem as a series of local string reversals.

The implementation consists of a string reversal function nested within an outer loop that selects the specific local segments.

### Initialization
The string reversal part uses a two-pointer operation (opposite direction pointers), with the left pointer as the start and the right pointer as the end.

The outer nesting uses a `for` or `while` loop, with logic branched based on the number of remaining characters.

### Loop Condition
For the `reverse` function, the loop stops when the two pointers meet.

The outer loop traverses the entire string array with a step size of `2 * k` instead of 1.

## Code

### Python
#### 1. Straightforward Implementation
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

## Complexity Analysis
Time Complexity: O(n) (Although it is a nested loop, for each element in the outer loop, the `reverse` function is only applied to a limited number of elements. Each element is processed a constant number of times.)

Space Complexity: O(n) (Strings in Python are immutable, so they must be converted to a list for modification, which allocates additional array space.)

## Pitfalls
- Python strings are immutable. To perform array-like operations, you must use `list(s)` to convert it into a list, and then use `"".join(s)` to return it as a string at the end.
- Do not forget to subtract 1 when determining the end point of the `reverse` segment; otherwise, you will be processing `k + 1` characters instead of `k` (since `left + k - left + 1 = k + 1`).

## Takeaways
- Python strings are immutable and do not support direct in-place modifications.
- Pay close attention to the handling of boundary conditions in loops.