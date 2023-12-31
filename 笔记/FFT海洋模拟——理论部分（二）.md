# FFT海洋模拟——理论部分（二）

由于使用标准傅里叶变换计算海面计算量过大，所以使用离散形式的傅里叶变换（DFT）代替

## 1.离散傅里叶变换

#### 1）定义式

$$
X[k]=\sum_{n=0}^{N-1}x[n]e^{-j\frac{2\pi k}{N}n},0 \leq k \leq N-1
$$

 为简化表达，令
$$
W_N=e^{-j\frac{2\pi}{N}}
$$
则定义式可化为
$$
X[k]=\sum_{n=0}^{N-1}x[n]W_{N}^{kn}
$$

#### 2）性质

i.对于带有e的指数项W，有如下性质：
$$
W_{N}^{k(2n)}=e^{-j\frac{2\pi k}{N}2n}=e^{-j\frac{2\pi k}{\frac{N}{2}}n}=W_{\frac{N}{2}}^{kn} (代换)
$$

$$
W_{N}^{kn}=W_{N}^{k(n+N)}=W_{N}^{(k+N)n}(周期性)
$$



#### 3）计算方式

采用了分治算法的思想，将一个长度为N的信号分为两个长度为N/2的信号进行计算，一个为偶数信号，另一个为奇数信号，表示如下：

首先将x[n]分解为奇数项和偶数项

偶数项：x[2n]

奇数项：x[2n+1]

此处的n取值范围为
$$
n \in \{0,1,...,\frac{N}{2}-1 \}
$$


则可将DFT定义式分解为
$$
X[k]=\sum_{n=0}^{\frac{N}{2}-1}x[2n]W_{N}^{k(2n)}+\sum_{n=0}^{\frac{N}{2}-1}x[2n+1]W_{N}^{k(2n+1)}\\
=\sum_{n=0}^{\frac{N}{2}-1}x[2n]W_{N}^{k(2n)}+W_{N}^{k}\sum_{n=0}^{\frac{N}{2}-1}x[2n+1]W_{N}^{k(2n)}\\
\sum_{n=0}^{\frac{N}{2}-1}x[2n]W_{\frac{N}{2}}^{kn}+W_{N}^{k}\sum_{n=0}^{\frac{N}{2}-1}x[2n+1]W_{\frac{N}{2}}^{kn}
$$
再令偶数项和奇数项分别为
$$
Even:E[k]=\sum_{n=0}^{\frac{N}{2}-1}x[2n]W_{\frac{N}{2}}^{kn}\\
Odd:O[k]=\sum_{n=0}^{\frac{N}{2}-1}x[2n+1]W_{\frac{N}{2}}^{kn}
$$
 根据W式的周期性，有
$$
E[k]=E[k+\frac{N}{2}]\\
O[k]=O[k+\frac{N}{2}]
$$
这样我们就可以将定义式表示成
$$
X[k]=E[k]+W_{N}^{k}O[k],0 \leq k \leq N-1
$$

## 2.一种计算示例（蝶形图表示）

取N=8，则计算过程如下（从最终结果反推初始输入）：

第1次分解（4上4下）：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/FFT1.png)

第二次（2上2下）：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/FFT2.png)

第三次（1上1下）：

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/FFT3.png)
