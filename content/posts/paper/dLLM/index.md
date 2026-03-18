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
## Method
- Traditional dLLMs discard the [MASK] at unpredicted positions in each round and reset them as new blank [MASK]s. To avoid wasting computational power, this method retains these discarded semantics and transforms them into vectors for the next round of prediction.
## Algorithm
1. Generate the residual vector by performing a weighted sum of the model's predicted probability and the word embeddings:

 $\Delta_i^{(t_k)} = \sum_{j=1}^V p_{i,j}^{(t_k)} E_{j,:}$ 

$E_{j}$ is the embedding for that word.

2. Weight of the residual vector to determine if the vector is worth retaining:

$\alpha_i^{(t_k)} = \frac{-\sum_{j=1}^V p_{i,j}^{(t_k)} \log p_{i,j}^{(t_k)}}{\log V}$

The larger $\alpha$ is, the less certain the model is about the word, and the more it should be retained. If high-confidence words are not predicted, it indicates they should likely not be retained further.

$\log V$ is used to compress $\alpha$ between 0 and 1.

3. If the word at position $i$ is not predicted, perform residual addition by adding the residual term to the [MASK].

If it has been predicted, it equals the word embedding.

$\tilde{e}_i^{(t_k)} = \begin{cases}  (1 - \alpha_i^{(t_{k-1})})E(x_i^{(t_k)}) + \alpha_i^{(t_{k-1})}\Delta_i^{(t_{k-1})}, & \text{if } x_i^{(t_k)} = \text{[MASK]} \\  E(x_i^{(t_k)}), & \text{otherwise}  \end{cases}$

## Training

### 1 Reference Model Initialization
Train a $\mathcal{M}_{ref}$ and freeze all parameters to output $p^{(t)}$.
### 2 Residual-Aware Target Training
Train a $\mathcal{M}_{target}$, where the input is a sentence with [MASK]s.

1. Calculate the weight of the residual vector $\alpha$ based on the probabilities calculated by $\mathcal{M}_{ref}$.
2. Calculate the word vector $ \Delta_i^{(t_k)} = \sum_{j=1}^V p_{i,j}^{(t_k)} E_{j,:} $, where probabilities are from $\mathcal{M}_{ref}$ and embeddings are from $\mathcal{M}_{target}$.
3. Calculate the final weighted result as input.
4. Input into $\mathcal{M}_{target}$ to predict the unmasked original sentence.
Loss function: $\mathcal{L} = \mathbb{E}\left[\frac{1}{t}\sum_{i:m_i=1} -\log P_{\theta_{target}}(x_i^{(0)} | \{e_{i'}^{(t)}\}_{i'=1}^b)\right]$
## Inference
### 1 Warm-Start
$\mathcal{M}_{ref}$ outputs the probability distribution $p^{(t_0)}$ for the first step.
### 2 Recursive Decoding
At each time step $t_k$:

1. Check every position in the sequence and calculate a new word vector as input based on $\alpha$ and $\Delta$ from step $t_{k-1}$.
2. $\mathcal{M}_{target}$ predicts each [MASK] and retains the original scores.
3. Select high-confidence positions for generation and remask uncertain ones.
4. For remasked parts, apply **Temperature-Scaled Entropy Alignment** to original scores to recalculate $\alpha$ and $\Delta$ for the next round.

**Temperature-Scaled Entropy Alignment**

In the inference phase, $\Delta$ and $\alpha$ no longer depend on $\mathcal{M}_{ref}$.

$\mathcal{M}_{target}$ tends to be over-confident when relying on its own previous round's predictions, causing $\alpha$ to trend towards 0, which makes the final result indistinguishable from [MASK].

Before converting scores to probabilities, a Residual temperature scalar is introduced to flatten extreme probability values:

$p_i^{(t_k)}(T_{res}) = \text{softmax}(z_i / T_{res})$

# 2 Deferred Commitment Decoding for Diffusion Language Models
## Method
- **Boundary-Induced Context Truncation**: Block decoding leads to inaccuracies at block boundaries because it cannot see the content of the next block, resulting in a loss of context.
- Use a dynamic sliding window for deferred decoding of low-confidence words.
## Algorithm
### 1 Sliding Window
1. Left Boundary:
$$L^{(t)} = \arg\min_{i \ge l} \{i | x_i^{(t)} = \langle \text{MASK} \rangle\}$$
The first un-decoded position serves as the left boundary.

2. Right Boundary:
$$R^{(t)} = \arg\max_{i \le r} \left\{ i \mid i \le L^{(t)} + s_{max} \text{ and } \sum_{k=L^{(t)}}^{i-1} [x_k^{(t)} = \langle \text{MASK} \rangle] \le s_{init} \right\}$$
The length does not exceed $s_{max}$; the number of [MASK]s included in the window does not exceed $s_{init}$.

$r$ is the block's right boundary (absolute right boundary).

### 2 Deferred Decoding

$$\mathcal{S}^{(t)} = \mathcal{M}^{(t)} \cap [L^{(t)}, R^{(t)}) \cap \{i \mid \mathcal{C}(i) \ge \min(\tau, \max_j \mathcal{C}(j))\}$$
Determines which [MASK]s in the window will be decoded.

Confidence must be greater than a threshold or the highest confidence within the window.

### 3 Dynamic Block Extension (DBE)
$$\min_{i \in \mathcal{S}^{(t)}} \mathcal{C}(i) < \tau_{low} \text{ and } R^{(t)} - L^{(t)} < s_{max} \text{ and } \sum_{k=L^{(t)}}^{R^{(t)}-1} [x_k^{(t)} = \langle \text{MASK} \rangle] < s_{init}$$

For semi-causal DLMs, the sliding window still operates between blocks. If the window reaches the block boundary (conditions 2 and 3) and confidence within the window is very low (condition 1), dynamically extend the block size:
$$r' = \min(r + e_{step}, \text{blocksize} + e_{max})$$
Extend the window right boundary by $e_{step}$ units, not exceeding a maximum limit.

### 4 DCD’s Combination with KV Cache

$$\mathcal{W}^{(t)} = \{x_i^{(t)} \mid i \in [L^{(t-1)} - r, R^{(t)} + r)\}$$
**Prefix Cache**: Temporarily stores KV for all tokens before the active interval.

**Dual Cache**: Simultaneously stores KV for both prefix and suffix tokens.

Reconstruct the cache every time $B'$ masked words are successfully decoded.

# 3 WAVEFRONTDIFFUSION: DYNAMIC DECODING SCHEDULE OR IMPROVED REASONING
## Method
- Establish a **Wavefront**, diffusing outward from already decoded words rather than using fixed block boundaries; finally, perform pruning by setting a capacity.
- **MHCO** Metric.
## Algorithm
### 1 Definition
Set a radius $R$ to include context:

$$\mathcal{W}_{t}=\{i \mid dist(i,\mathcal{C}_{t})\le R\}$$

$C_t$ is the set of confirmed tokens.

### 2 Decoding Iteration Process
1. **Scoring**
Perform one forward pass to obtain confidence:
$$s_{j}=\max_{v\in\mathcal{V}}p_{\theta}(x_{j}=v \mid x_{t},c)$$
The probability of the most likely word in the vocabulary is its confidence.

2. **Denoising**
Control the number of denoising actions per round; if not divisible, distribute the remainder across the first $extra$ steps:
$$k_{t}=k_{base}+\mathbb{I}[t\le extra]$$

$$kbase = ⌊N/T/⌋, extra =N \pmod T$$

$N$ is the total number of words to decode.
$T$ is the number of steps.
$\mathbb{I}$ is the indicator function, equal to 1 if the condition is met.

3. **Expansion**
$$\mathcal{W}_{t}=\bigcup_{i\in\mathcal{C}_{t}}\{j \mid dist(j,i)\le R, x_{j}=\text{[MASK]}\}$$
For each token in the newly decoded set $C_t$, perform an expansion with radius $R$.

4. **Pruning**
If the maximum capacity $F$ is exceeded, remove tokens with lower confidence.

# 4 AdaBlock-dLLM: SEMANTIC-AWARE DIFFUSION LLM INFERENCE VIA ADAPTIVE BLOCK SIZE
## Method
- If the block is too small, deferred decoding results in high-confidence tokens not being decoded immediately; if tokens within a block have low confidence but must be decoded, it creates issues.
- Divide confidence regions and set a **Volatility Band**.
## Algorithm
Adaptive block size adjustment based on semantics.
Set a delimiters set $D$.
The delimiter with the highest confidence in the window is denoted as $c_{max}$.
If $c_{max} \ge \tau_{\mathcal{D}}$: Set the current block size $B$ as the distance from the starting point to this delimiter; otherwise, the current area is semantically ambiguous, and $B$ reverts to the default fixed block size $B_0$ (or the remaining length).

**Index Window**: Prevents premature decoding of `<EOS>` by setting a window to mask out positions that are too far away.
1. Perform initial denoising before entering the next block.
2. Apply the algorithm above to define a block.
3. Iteratively denoise within this block.

# 5 Improving the Throughput of Diffusion-based Large Language Models via a Training-Free Confidence-Aware Calibration
## Method
- Fast-dLLM parameters are fixed and not dynamic.
- Perform calculations and a series of adaptive operations dynamically based on average confidence.
## Algorithm
**clip**: Used to set upper and lower bounds (min/max).
### 1 Adaptive Block Size
$$B_t = clip(B_{min} + (B_{max} - B_{min})\overline{c}, B_{min}, B_{max})$$
$\overline{c}$ is the average confidence.
The higher the average confidence, the closer the size is to the maximum value.
### 2 Adaptive steps
$$S_t = clip(S_{base} + (S_{max} - S_{base})(1 - \overline{c}), S_{base}, S_{max})$$
Similar to point 1, lower average confidence leads to larger steps, representing more calculations.
### 3 Adaptive vocabulary size
$$V_t = clip(V_{phase}(g_t) \cdot f_{conf}(\overline{c}) \cdot f_{rep}(r_t), V_{min}, V_{max})$$
$g_t$ is generation progress.
$V_{phase}(g_t)$: Larger vocabulary size at the start of generation.
$f_{conf}(\overline{c})$: Larger vocabulary size when confidence is low to expand the search range.
$r_t$ is the repetition rate of generated tokens.
$f_{rep}(r_t)$: Expand vocabulary size if recently generated tokens are repetitive.
### 4 Adaptive threshold
$$\tau_t = \tau_{base}(1 - g_t) + \tau_{min}g_t$$
At the start of generation, the threshold is high ($\tau_{base}$), then it decreases to $\tau_{min}$.

# 6 Next Semantic Scale Prediction via Hierarchical Diffusion Language Models
## Method
- Introduce clustered semantics between tokens and [MASK]. When adding noise, transform to cluster tokens first, then to [MASK]. During denoising, revert to clusters first, then to specific tokens.
- MDLM is a special case of HDLM, equivalent to having only one cluster [MASK].
## Algorithm
### 1 Forward Noise Addition
Mapping matrix $\Gamma$ to obtain clusters $c(x) = \Gamma x$:
$$q_{t}(z_{t}|x)=Cat(z_{t};\alpha_{t}x+\beta_{t,c}c(x)+\beta_{t,m}m)$$
$Cat$ is the Categorical distribution.
At time step $t$, there are three possible states:
1. $\alpha_{t}$ is the probability of remaining as a specific token.
2. $\beta_{t,c}$ is the probability of becoming cluster $c$.
3. $\beta_{t,m}$ is the probability of becoming [MASK].
As $t$ increases, $\alpha_t$ decreases.
#### Stochastic Perturbations
$$\beta_t \pi_t = \xi \beta_{t,c} c(x) + \sum_{c \neq c(x)} \frac{1-\xi}{N_c-1} \beta_{t,c} c + \beta_{t,m} m$$
Puts incorrect words into the set with probability $1-\xi$.
### 2 Backward Denoising
$$p_{\theta}(z_{s}|z_{t})=q_{t|s}(z_{t}|z_{s})\frac{q_{s}(z_{s}|x_{\theta})}{q_{t}(z_{t}|x_{\theta})}$$
### 3 Training
$$ELBO = -\mathbb{E}_{t,z_{t}}\left[\delta_{z_{t},c}w_{t,c}CE\left(x,\frac{x_{\theta}\odot(\Gamma^{\top}\Gamma x)}{x_{\theta}^{\top}\Gamma^{\top}\Gamma x}\right)+\delta_{z_{t},m}w_{t,m}CE(\Gamma x,\Gamma x_{\theta})\right]$$
1. $\delta_{z_t,c}$ indicates the current token is a cluster; words outside the cluster are zeroed out, and only the correct token is found within this cluster for generation.
2. $\delta_{z_t,m}$ indicates the current token is a [MASK]; it must first find a suitable cluster.
### Example
1. During forward propagation, after a token becomes a cluster, it maintains this state for duration $t_{m,\tau}$ (uniform distribution over $[\tau, 1]$) before potentially becoming [MASK].
2. Calculate the token's state:
$$\beta_{t,c} = \int_{0}^{t} \frac{1-t}{1-\tau} (-d\alpha_\tau)$$
Remaining time divided by total span multiplied by decay factor.
$$\beta_{t,m} = \int_{0}^{t} \frac{t-\tau}{1-\tau} (-d\alpha_\tau)$$
Similarly:
$$\alpha_t = (1-t)^\gamma$$
3. Calculate loss:
$$w_{t,c} = \frac{-\alpha_t'}{\beta_{t,c}}$$
$$w_{t,m} = \frac{-\alpha_t'}{\beta_{t,m}}$$
### Optimization
1. **Gradient of cluster-level loss**
$$-\nabla_{x_{\theta}}(\delta_{z_{t},m}w_{t,m}CE(\Gamma x,\Gamma x_{\theta}(z_{t},t)))=\delta_{z_{t},m}w_{t,m}\Gamma^{\top}\left(\Gamma x\odot\frac{1}{\Gamma x_{\theta}}\right)$$

2. **Auxiliary loss**
No separate classification head is added to categorize tokens into clusters; cluster probabilities are obtained directly from $x_\theta$ via the posterior.

3. **Flexible loss weights**
Clipping weights $w_{t,c}$ and $w_{t,m}$ if they are too large or too small.

4. **Force transition in decoding**
Disallow prediction of words outside of the cluster.