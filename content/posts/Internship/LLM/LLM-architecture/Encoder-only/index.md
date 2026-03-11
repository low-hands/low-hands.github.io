---
title: Encoder-only
date: 2026-03-02T23:25:00-08:00
description: Encoder-only
menu:
  sidebar:
    name: Encoder-only
    identifier: enc
    parent: llm-arch
    weight: 30
math: true
hero: image.png
---

# What is Pre-training?
Initializing neural network model parameters through **self-supervised learning** (unlabeled data).

The goal is to learn a **universal language understanding capability**.

---

# BERT
## BERT Pre-training Tasks
### Masked Language Modeling (MLM)
A certain percentage (15%) of tokens in the input sequence are replaced, and the model is tasked with predicting what those original words were.



#### The 8-1-1 Rule
* **80%** of the selected tokens are replaced with `[MASK]`: Acts like a cloze test, enabling the model to learn bidirectional semantic context.
* **10%** are replaced with a **random token** from the vocabulary: Since the model doesn't know which tokens are random, this improves error-correction capabilities and forces the model to rely on the global context to generate the correct vector representation.
* **10%** remain as the **original token**: This anchors the model's representations toward the actual "true" embeddings.

#### Optimization Objective
$$\mathcal{L}_{MLM} = - \sum_{i \in m} \log P(x_i | \tilde{X}; \theta)$$
Where $\tilde{X}$ is the corrupted input sequence, $m$ is the set of chosen masked positions, and $\theta$ represents the model parameters.

The higher the probability $P$ that the model predicts the true word $x_i$ at position $i$, the smaller the loss $\mathcal{L}$ becomes.

**In short:** Although the model produces predictions for every token in the top layer (including the 85% of "normal" words), the system only calculates the loss for the 15% of selected positions. The outputs for the remaining 85% are ignored.

### Next Sentence Prediction (NSP)
The model randomly samples pairs of sentences (A, B) and determines if B is the actual subsequent sentence of A. This enhances **cross-sentence understanding**.

* **50%** are positive pairs (consecutive sentences).
* **50%** are negative pairs (random sentences).

#### [CLS] + A + [SEP] + B + [SEP]
* `[CLS]`: A classification token placed at the beginning of the sequence to determine if B follows A.
* `[SEP]`: A separator token used to distinguish between the two sentences.

#### Optimization Objective
$$\mathcal{L}_{NSP} = - \left[ y \log \hat{y} + (1-y) \log (1-\hat{y}) \right]$$

---

## Characteristics
BERT utilizes **only the Encoder** of the Transformer, which provides **bidirectional** understanding.

### Why not use the Decoder?
BERT's primary goal is language understanding. If a Decoder (with Masked Attention) were used, it would lose the ability to see future context. Decoders operate in a left-to-right fashion, masking "future" words, which hinders full contextual comprehension.

---

## Input Representation


* **Token Embeddings:** Split using **WordPiece** tokenization.
* **Segment Embeddings:** Used to distinguish between Sentence A and Sentence B. Without this, tokens in distant sentences would not effectively perceive the `[SEP]` boundary.
* **Position Embeddings:** Learnable position encoding.

---

## Activation Function
**GeLU** (Gaussian Error Linear Unit)

---

## Hyperparameters
* **Base:** 12 encoder layers, 768 hidden dimensions, 12 attention heads, 110M parameters.
* **Large:** 24 encoder layers, 1024 hidden dimensions, 16 attention heads, 340M parameters.

---

## Optimization Goal
A joint loss combining **MLM** and **NSP**.

---

## Fine-tuning
* **Classification:** Use the `[CLS]` token output connected to a Fully Connected (FC) layer.
* **Sequence Labeling (NER):** Attach an FC layer to **every** token and use Softmax to score each entity category.
* **Reading Comprehension / QA:** Identify the `start` and `end` indices of the answer. Both the Question (Sentence A) and the Passage (Sentence B) are fed into BERT simultaneously. Dot products are calculated between `start`/`end` vectors and every token in Sentence B, followed by a Softmax to determine the probability.