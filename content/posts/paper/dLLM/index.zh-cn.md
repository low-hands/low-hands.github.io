---
title: Diffusion LLM paper reading
date: 2026-03-14T00:16:00-08:00
description: dLLM
menu:
  sidebar:
    name: dLLM
    identifier: dLLM
    parent: paper
    weight: 30
math: true
hero: image.png
---
# 1 Residual Context Diffusion Language Models
## 方法
- 传统dLLM在每轮预测的时候会把没有预测到的位置上的[MASK]直接扔掉，重置为新的空白[MASK]；为了不浪费算力，会选择保留这些废弃的语义，转变成向量用于下一轮预测
## 算法
1. 将模型预测的概率与词向量进行加权求和，生成残差向量：

 $ \Delta_i^{(t_k)} = \sum_{j=1}^V p_{i,j}^{(t_k)} E_{j,:} $ 

$E_{j}$是该词的词向量

2. 残差向量的权重，来判断这个向量值不值得保留

$\alpha_i^{(t_k)} = \frac{-\sum_{j=1}^V p_{i,j}^{(t_k)} \log p_{i,j}^{(t_k)}}{\log V}$

$\alpha$越大，模型对这个词可能越没把握，越应该保留；如果有把握的词都没有被预测，说明可能不应该继续保留

$logV$用来把$\alpha$压缩到0-1之间

3. 如果位置i的词没有被预测出来，就做残差相加，把残差项加到[MASK]上

如果已经被预测出来了，就是等于该词的词向量

$\tilde{e}_i^{(t_k)} = \begin{cases}  (1 - \alpha_i^{(t_{k-1})})E(x_i^{(t_k)}) + \alpha_i^{(t_{k-1})}\Delta_i^{(t_{k-1})}, & \text{if } x_i^{(t_k)} = \text{[MASK]} \\  E(x_i^{(t_k)}), & \text{otherwise}  \end{cases}$

## 训练

### 1 Reference Model Initialization
训练一个$\mathcal{M}_{ref}$，冻结所有参数，用来输出 $p^{(t)}$
### 2 Residual-Aware Target Training
训练一个$\mathcal{M}_{target}$，输入为一个带[MASK]的句子

1. 通过$\mathcal{M}_{ref}$算出来的概率，算出残差向量的权重$\alpha$
2.  $ \Delta_i^{(t_k)} = \sum_{j=1}^V p_{i,j}^{(t_k)} E_{j,:} $ 计算词向量，概率由 $\mathcal{M}_{ref}$ 得到，词向量来自$\mathcal{M}_{target}$
3. 计算最终的加权结果作为输入
4. 输入到$\mathcal{M}_{target}$，预测无掩码的原句
损失函数：$\mathcal{L} = \mathbb{E}\left[\frac{1}{t}\sum_{i:m_i=1} -\log P_{\theta_{target}}(x_i^{(0)} | \{e_{i'}^{(t)}\}_{i'=1}^b)\right]$
## 推理
### 1 Warm-Start
$\mathcal{M}_{ref}$输出第一步的概率分布$p^{(t_0)}$
### 2 Recursive Decoding
在每个时间步$t_k$

1. 检查序列里的每一个位置，根据 $t_{k-1}$步算的$\alpha$和$\Delta$和公式算出新的词向量作为新输入
2. $\mathcal{M}_{target}$对每个[MASK]进行预测，保留原始得分
3. 根据概率选出置信度高的位置确定生成，没把握的remasking
4. 对remasking的部分，对原始得分应用Temperature-Scaled Entropy Alignment，重新计算$\alpha$和$\Delta$给下一轮用

**Temperature-Scaled Entropy Alignment**

推理阶段$\Delta$和$\alpha$不再依赖$\mathcal{M}_{ref}$

$\mathcal{M}_{target}$在依靠自己上一轮来预测的时候容易over-confident，$\alpha$会趋于0，导致最后整个结果趋于0，这样就和[MASK]没区别了

在把得分变成概率之前，引入Residual temperature scalar，把极端的概率值压低

$p_i^{(t_k)}(T_{res}) = \text{softmax}(z_i / T_{res})$

# 2 Deferred Commitment Decoding for Diffusion Language Models
## 方法
- Boundary-Induced Context Truncation：块解码会导致块与块之间的部分不够准确，因为它看不到下一个块的内容，缺失一部分上下文
- 用动态的滑动窗口，对没把握的词进行延迟解码
## 算法
### 1 滑动窗口
1. 左边界
$$L^{(t)} = \arg\min_{i \ge l} \{i | x_i^{(t)} = \langle \text{MASK} \rangle\}$$
第一个没有被解开的位置作为左边界

2. 右边界
$$R^{(t)} = \arg\max_{i \le r} \left\{ i \mid i \le L^{(t)} + s_{max} \text{ and } \sum_{k=L^{(t)}}^{i-1} [x_k^{(t)} = \langle \text{MASK} \rangle] \le s_{init} \right\}$$
长度不超过$s_{max}$；窗口里包括的[MASK]数量不超过$s_{init}$

$r$是块的右边界（绝对右边界）

### 2 延迟解码

$$\mathcal{S}^{(t)} = \mathcal{M}^{(t)} \cap [L^{(t)}, R^{(t)}) \cap \{i \mid \mathcal{C}(i) \ge \min(\tau, \max_j \mathcal{C}(j))\}$$
决定窗口里哪些[MASK]会被解开

置信度必须大于阈值或者窗口里最高的置信度

### 3 Dynamic Block Extension （DBE）
$$\min_{i \in \mathcal{S}^{(t)}} \mathcal{C}(i) < \tau_{low} \text{ and } R^{(t)} - L^{(t)} < s_{max} \text{ and } \sum_{k=L^{(t)}}^{R^{(t)}-1} [x_k^{(t)} = \langle \text{MASK} \rangle] < s_{init}$$

对于semi-causal DLMs，滑动窗口还是在块之间做的，所以如果窗口已经到块边上了（条件2和3），而且窗口里的词置信度都很低（条件1），就动态扩展块的大小
$$r' = \min(r + e_{step}, \text{blocksize} + e_{max})$$
把窗口右边界扩展$e_{step}$个单位，不超过一个极限值

### 4 DCD’s Combination with KV Cache

$$\mathcal{W}^{(t)} = \{x_i^{(t)} \mid i \in [L^{(t-1)} - r, R^{(t)} + r)\}$$
前缀缓存（Prefix Cache）：临时存储活跃区间之前的所有 Token 的 KV 

双向缓存（Dual Cache）：同时存储前缀和后缀的 Token 的 KV 

每成功解开 $B'$ 个掩码词后，就会重新构建一次缓存
# 3 WAVEFRONTDIFFUSION: DYNAMIC DECODING SCHEDULE OR IMPROVED REASONING
## 方法
- 建立Wavefront，从已经解码的词开始往外扩散，而不是用固定的块边界；最后做剪枝，设置一个容量
- MHCO 指标
## 算法
### 1 定义
设定一个半径$R$,把上下文都包括进来

$$\mathcal{W}_{t}=\{i \mid dist(i,\mathcal{C}_{t})\le R\}$$

$C_t$是已经确定的token的集合

### 2 解码迭代过程
1. 打分
前向传播一次，得到置信度
$$s_{j}=\max_{v\in\mathcal{V}}p_{\theta}(x_{j}=v \mid x_{t},c)$$
词表里概率最高的那个词的概率就是它的置信度

2. 去噪
控制每一轮去噪的数量；如果除不尽，剩下的就分摊给前$extra$步
$$k_{t}=k_{base}+\mathbb{⊮}[t\le extra]$$

$$kbase = ⌊N/T⌋, extra =N(mod \space\ T)$$

$N$为总共要解码的词的数量
$T$为步数
$⊮$是指示函数，成立的话就为1

3. 扩展
$$\mathcal{W}_{t}=\bigcup_{i\in\mathcal{C}_{t}}\{j \mid dist(j,i)\le R, x_{j}=\text{[MASK]}\}$$
对新解码的出来的集合$C_t$里的每个token，对他进行半径为$R$的扩展

4. 剪枝
超过最大容量$F$,就把置信度低的token拿掉

# 4 AdaBlock-dLLM: SEMANTIC-AWARE DIFFUSION LLM INFERENCE VIA ADAPTIVE BLOCK SIZE
## 方法
- 块太小的话，延迟解码导致高置信度的token不一定能立即解码出来；块内一些token置信度低也必须在块内解码出来，这也是问题
- 对置信度区域进行划分，设置Volatility Band
## 算法
根据语义自适应切割块的大小
设置一个delimiters集合$D$
窗口内置信度最高的delimiter记为$c_{max}$
如果 $c_{max} \ge \tau_{\mathcal{D}}$：把当前块的大小 $B$ 设置为从起点到这个分割符的距离；否则说明当前处于语义含糊不清的区域，$B$退回到默认的固定块大小 $B_0$（或者剩下的长度）

**Index Window**:防止过早解码<EOS>,设置一个窗口屏蔽掉太远的地方
1. 在进入下一个block之前，做一次初步的去噪
2. 把结果放到上述算法中，得到一个块
3. 在这个块内循环去噪

# 5 Improving the Throughput of Diffusion-based Large Language Models via a Training-Free Confidence-Aware Calibration
## 方法
- Fast-dLLM参数都固定，不动态
- 根据平均置信度动态地做计算，做一系列自适应的操作
## 算法
clip：不能超过min和max，划上下限用的
### 1 Adaptive Block Size
$$B_t = clip(B_{min} + (B_{max} - B_{min})\overline{c}, B_{min}, B_{max})$$
$\overline{c}$是平均置信度
平均置信度越高，size越接近最大值
### 2 Adaptive steps
$$S_t = clip(S_{base} + (S_{max} - S_{base})(1 - \overline{c}), S_{base}, S_{max})$$
与1类似，平均置信度越小，step越大，代表要多算几次
### 3 Adaptive vocabulary size
$$V_t = clip(V_{phase}(g_t) \cdot f_{conf}(\overline{c}) \cdot f_{rep}(r_t), V_{min}, V_{max})$$
$g_t$是生成进度
$V_{phase}(g_t)$：才开始生成的时候，词表大
$f_{conf}(\overline{c})$：置信度小的时候，词表大，即扩大查找的范围
$r_t$是生成token的重复率
$f_{rep}(r_t)$：如果最近生成的token一直重复，就扩大词表
### 4  Adaptive threshold
$$\tau_t = \tau_{base}(1 - g_t) + \tau_{min}g_t$$
才开始生成的时候，阈值比较高$\tau_{base}$，然后降低到$\tau_{min}$
# 6 Next Semantic Scale Prediction via Hierarchical Diffusion Language Models
## 方法
- 在token和[MASK]之间加入聚类的语义，加噪的时候先变成聚类token，再变成[MASK]；去噪的时候也是，先变成聚类，再变成具体的token
- MDLM是HDLM的一个特例，相当于只有一个聚类[MASK]
## 算法
### 1 前向加噪
映射矩阵$\Gamma$，得到一个个聚类 $c(x) = \Gamma x$
$$q_{t}(z_{t}|x)=Cat(z_{t};\alpha_{t}x+\beta_{t,c}c(x)+\beta_{t,m}m)$$
$Cat$为Categorical distribution
在t时间步，有三种可能的状态：
1. $\alpha_{t}$ 为保持为具体的token的概率
2. $\beta_{t,c}$ 为变成聚类c的概率
3. $\beta_{t,m}$为变成[MASK]的概率
t越大，$\alpha_t$ 会变小
#### stochastic perturbations
$$\beta_t \pi_t = \xi \beta_{t,c} c(x) + \sum_{c \neq c(x)} \frac{1-\xi}{N_c-1} \beta_{t,c} c + \beta_{t,m} m$$
以$1-\xi$的概率把错误的词放到集合里
### 2 反向去噪
$$p_{\theta}(z_{s}|z_{t})=q_{t|s}(z_{t}|z_{s})\frac{q_{s}(z_{s}|x_{\theta})}{q_{t}(z_{t}|x_{\theta})}$$
### 3 训练
$$ELBO = -\mathbb{E}_{t,z_{t}}\left[\delta_{z_{t},c}w_{t,c}CE\left(x,\frac{x_{\theta}\odot(\Gamma^{\top}\Gamma x)}{x_{\theta}^{\top}\Gamma^{\top}\Gamma x}\right)+\delta_{z_{t},m}w_{t,m}CE(\Gamma x,\Gamma x_{\theta})\right]$$
1. $\delta_{z_t,c}$ 代表当前token是一个聚类，把聚类外的词汇归0，只在这个聚类里找到正确的token生成
2. $\delta_{z_t,m}$代表当前token是个[MASK]，让他先找到合适的聚类
### Example
1. 前向传播的时候，一个token变成某个聚类后，维持 $t_{m,\tau}$的时间（$[\tau, 1]$的均匀分布），然后可能变成[MASK]
2. 计算该token的状态
$$\beta_{t,c} = \int_{0}^{t} \frac{1-t}{1-\tau} (-d\alpha_\tau)$$
剩下的时间除以总跨度再乘衰减因子
$$\beta_{t,m} = \int_{0}^{t} \frac{t-\tau}{1-\tau} (-d\alpha_\tau)$$
同理
$$\alpha_t = (1-t)^\gamma$$
3. 算loss
$$w_{t,c} = \frac{-\alpha_t'}{\beta_{t,c}}$$
$$w_{t,m} = \frac{-\alpha_t'}{\beta_{t,m}}$$
### 优化
1. Gradient of cluster-level loss
$$-\nabla_{x_{\theta}}(\delta_{z_{t},m}w_{t,m}CE(\Gamma x,\Gamma x_{\theta}(z_{t},t)))=\delta_{z_{t},m}w_{t,m}\Gamma^{\top}\left(\Gamma x\odot\frac{1}{\Gamma x_{\theta}}\right)$$

2. Auxiliary loss
没有单独增加分类头来把token分成聚类，会增加额外的loss；直接用$x_\theta$通过后验得到簇概率

3. Flexible loss weights
算权重 $w_{t,c}$ 和 $w_{t,m}$的时候对过大或者过小的直接clipping

4. Force transition in decoding
不允许预测聚类外的词汇

