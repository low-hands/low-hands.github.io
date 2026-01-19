---
title: Leetcode 344 - Reverse String
date: 2026-01-19T09:00:00-08:00
description: Two Pointers - Reverse String
menu:
  sidebar:
    name: Leetcode 344. Reverse String
    identifier: Leetcode344
    parent: twopointer
    weight: 31
hero: image.png
---
[Problem Link](https://leetcode.com/problems/reverse-string/)
# Problem Description
Write a function that reverses a string. The input string is given as an array of characters s.

You must do this by modifying the input array in-place with O(1) extra memory.

 

Example 1:

>Input: s = ["h","e","l","l","o"]
>Output: ["o","l","l","e","h"]
Example 2:

>Input: s = ["H","a","n","n","a","h"]
>Output: ["h","a","n","n","a","H"]
## Approach
Opposite Direction Pointers: One pointer starts at the beginning, and the other starts at the end.

Both pointers move inward simultaneously with the same step size until they cross each other (left > right), at which point the traversal ends.



### Initialization
The left pointer is initialized at the start `0`, and the right pointer is initialized at the end `len(s) - 1`.

### Loop Condition
The loop terminates when the two pointers meet. If the indices are the same (when the array length is odd), the middle element does not need to enter the loop for swapping. Therefore, the `while` condition does not need to include the equals sign.

Including the equals sign is also acceptable; it simply means the middle element performs a swap with itself.

## Code

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

## Complexity Analysis
Time Complexity: O(n) (single while loop, operations within the loop are constant time)

Space Complexity: O(1) (modified in the original array, no other new array space generated)

## Pitfalls
- Modification is done **in-place** on the original array; you should return the original array (or modify it directly). Creating a new array does not meet the requirements.
- The `while` boundary condition can either exclude or include the equals sign, as an element can swap with itself, i.e., `nums[i] = nums[i]`.

## Takeaways
- "Reversing" often implies the use of opposite-direction pointers. Since the modification must be **in-place**, swapping elements is the primary strategy, which naturally leads to considering a two-pointer approach without allocating a new array.
- In Python, strings (or lists of characters) can be accessed directly using index notation, such as `s[i]`.
- **in-place** stands for modifying the array at its original location.