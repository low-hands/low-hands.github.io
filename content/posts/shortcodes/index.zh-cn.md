---
title: "短代码示例"
date: 2026-01-13T01:07:25-08:00
description: Shortcodes sample
menu:
  sidebar:
    name: 短代码示例
    identifier: shortcodes
    weight: 40
---

这是一个示例帖子，旨在测试以下内容：

- 默认的主图（Hero Image）。
- 不同的短代码（Shortcodes）。


## 提示框 (Alert)

本主题支持以下几种提示框。

{{< alert type="success" >}}
这是一个`type="success"` 的例子
{{< /alert >}}

{{< alert type="danger" >}}
这是一个 `type="danger"` 的例子
{{< /alert >}}

{{< alert type="warning" >}}
这是一个 `type="warning"` 的例子
{{< /alert >}}

{{< alert type="info" >}}
这是一个 `type="info"` 的例子
{{< /alert >}}

{{< alert type="dark" >}}
这是一个 `type="dark"` 的例子
{{< /alert >}}

{{< alert type="primary" >}}
这是一个 `type="primary"` 的例子
{{< /alert >}}

{{< alert type="secondary" >}}
这是一个 `type="secondary"` 的例子
{{< /alert >}}

## 图片 (Image)

#### 不带任何属性的示例图片。

{{< img src="/posts/shortcodes/boat.jpg" title="海上的小船" >}}

{{< vs 3 >}}

#### 带有 `height`（高度）和 `width`（宽度）属性的示例图片。

{{< img src="/posts/shortcodes/boat.jpg" height="400" width="600" title="海上的小船" >}}

{{< vs 3 >}}

#### 带有 `height` 和 `width` 属性的居中对齐图片。

{{< img src="/posts/shortcodes/boat.jpg" height="400" width="600" align="center" title="海上的小船" >}}

{{< vs 3 >}}

#### 带有 `float`（浮动）属性的图片。

{{< img src="/posts/shortcodes/boat.jpg" height="200" width="500" float="right" title="A boat at the sea" >}}

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras egestas lectus sed leo ultricies ultricies. Praesent tellus risus, eleifend vel efficitur ac, venenatis sit amet sem. Ut ut egestas erat. Fusce ut leo turpis. Morbi consectetur sed lacus vitae vehicula. Cras gravida turpis id eleifend volutpat. Suspendisse nec ipsum eu erat finibus dictum. Morbi volutpat nulla purus, vel maximus ex molestie id. Nullam posuere est urna, at fringilla eros venenatis quis.

Fusce vulputate dolor augue, ut porta sapien fringilla nec. Vivamus commodo erat felis, a sodales lectus finibus nec. In a pulvinar orci. Maecenas suscipit eget lorem non pretium. Nulla aliquam a augue nec blandit. Curabitur ac urna iaculis, ornare ligula nec, placerat nulla. Maecenas aliquam nisi vitae tempus vulputate.

## 分栏 (Split)

本主题支持将页面拆分为任意数量的列。

#### 两栏分割

{{< split 6 6>}}

##### 左栏

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras egestas lectus sed leo ultricies ultricies.

---

##### 右栏

Fusce ut leo turpis. Morbi consectetur sed lacus vitae vehicula. Cras gravida turpis id eleifend volutpat.

{{< /split >}}

#### 三栏分割

{{< split 4 4 4 >}}

##### 左栏

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras egestas lectus sed leo ultricies ultricies.

---

##### 中栏

Aenean dignissim dictum ex. Donec a nunc vel nibh placerat interdum. 

---

##### 右栏

Fusce ut leo turpis. Morbi consectetur sed lacus vitae vehicula. Cras gravida turpis id eleifend volutpat.

{{< /split >}}

## 垂直间距 (Vertical Space)

在两行之间提供垂直间距。

这是第一行。
{{< vs 4>}}
这是第二行。它与前一行之间应该有 `4rem` 的垂直间距。

## 视频 (Video)

{{< video src="/videos/sample.mp4" >}}

视频来源：[Rahul Sharma](https://www.pexels.com/@rahul-sharma-493988) 选自 [Pexels](https://www.pexels.com)。

## Mermaid 图表

这里有几个 Mermaid 短代码的示例。

**流程图 (Graph):**

{{< mermaid align="left" >}}
graph LR;
    A[硬边框] -->|链接文本| B(圆角边框)
    B --> C{决策}
    C -->|选项一| D[结果一]
    C -->|选项二| E[结果二]
{{< /mermaid >}}

**时序图 (Sequence Diagram):**

{{< mermaid >}}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->>John: Hello John, 最近怎么样?
    loop 健康检查
        John->>John: 与疑病症作斗争
    end
    Note right of John: 理性思考 <br/>占据上风！
    John-->>Alice: 挺好的！
    John->>Bob: 你呢？
    Bob-->>John: 非常棒！
{{< /mermaid >}}

**甘特图 (Gantt diagram):**

{{< mermaid >}}
gantt
  dateFormat  YYYY-MM-DD
  title 为 Mermaid 添加甘特图
  excludes weekdays 2014-01-10

section 阶段 A
  已完成任务            :done,    des1, 2014-01-06,2014-01-08
  进行中任务            :active,  des2, 2014-01-09, 3d
  未来任务              :         des3, after des2, 5d
  未来任务 2            :         des4, after des3, 5d
{{< /mermaid >}}

