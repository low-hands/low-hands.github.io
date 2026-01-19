---
title: Leetcode 27 - Remove Element
date: 2026-01-18T22:21:00-08:00
description: Two Pointers - Remove Element
menu:
  sidebar:
    name: Leetcode 27. Remove Element
    identifier: Leetcode27
    parent: twopointer
    weight: 30
math: true
hero: image.png
---

[Problem Link](https://leetcode.cn/problems/remove-element/description/)
## Problem Description
Given an array `nums` and a value `val`, you need to **in-place** remove all instances of that value and return the new length of the array.

Do not use extra space for another array; you must do this by modifying the input array **in-place** with **O(1)** extra space.

The order of elements can be changed. You do not need to consider the elements beyond the new length.

Example 1: Given `nums = [3,2,2,3], val = 3`, the function should return length 2, and the first two elements of `nums` are both 2. You do not need to consider the elements beyond the new length.

Example 2: Given `nums = [0,1,2,2,3,0,4,2], val = 2`, the function should return length 5, and the first five elements of `nums` are 0, 1, 3, 0, 4.

You do not need to consider the elements beyond the new length.

## Approach
Fast and slow pointers: A fast pointer and a slow pointer complete the task within a single loop, which is more efficient than the brute-force method.

Fast and slow pointers are a type of same-direction pointers, except that the step size of fast and slow pointers is generally fixed.

The slow pointer is used to store elements that are not `val`, while the fast pointer is used to skip elements that are `val`.

The process ends when the fast pointer finishes traversing; it just increments directly.

The growth of the slow pointer only depends on judging the current element. The problem does not require considering the parts that do not meet the requirements, so the slow pointer only needs to encounter a compliant element (which requires the fast pointer's help to judge) to increment by 1.

### Initialization

Fast and slow pointers are same-direction pointers, both initialized to 0.

### Loop Condition

Only need to observe the fast pointer; when the fast pointer traverses the entire array, it means the end.

When the fast pointer equals `len(nums)-1`, it can enter the loop because if the last element does not equal `val`, then that element needs to be input into `nums[left]`, meaning the slow pointer still potentially needs to use the value of the fast pointer (at this time, the fast pointer points to the last element of the array).

## Code

### Python
```python
class Solution(object):
    def removeElement(self, nums, val):
        """
        :type nums: List[int]
        :type val: int
        :rtype: int
        """
        left = 0
        right = 0
        k = 0
        while right <= len(nums)-1:
            if nums[right] != val:
                nums[left] = nums[right]
                k+=1
                left+=1
            right+=1
        return k
```


## Complexity Analysis
Time Complexity: O(n) (while single loop, operations within the loop are constant time)

Space Complexity: O(1) (modified in the original array, no other new array space generated)
## Pitfalls
- Modification is done **in-place** on the original array; only need to return k, no need to return a new array. Creating a new array yourself does not meet the requirements.
- The `while` boundary condition includes the equals sign; otherwise, if the last element meets the condition (needs to be added to the reorganized array), it will be missed in the answer.
## Takeaways
- The step size of fast and slow pointers is usually the same.
- Initially learned the usage of fast and slow pointers; need to continue practicing.
- When the keyword **in-place** appears, consider the two-pointer method.
- In two pointers, generally the fast pointer performs normal traversal, while the slow pointer is used for conditional judgment.
- **in-place** stands for modifying the array at its original location.