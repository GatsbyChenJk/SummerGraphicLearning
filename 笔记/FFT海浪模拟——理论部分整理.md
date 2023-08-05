# FFT海浪模拟——理论部分整理（一）

## 1.频谱、傅里叶变换及其逆变换的概念

#### 0）信号的表示

自变量为x的函数f(x)可看作一个随空间变化的信号（空域信号），只要满足一定条件，它就可以表示为一堆不同频率的随空间变化的正弦信号（空域正弦信号）的线性组合（或积分）

#### 1）频谱

i.正弦信号（称为基底）的频率构成频域。如果将频域作为定义域，相应频率基底的振幅和相位作为函数值，则得到一个新函数F(ω)。称为信号f(x)的频谱。

ii.而频域分析是将信号从**时域（时间域）**或**空域**转换为**频域（频率域）**的过程。在频域中，信号可以表示为不同频率的成分或频谱

#### 2）傅里叶变换及其逆变换

i.傅里叶变换：已知信号的表示方式求解频谱的过程

ii.傅里叶逆变换：已知频谱求解信号的表示方式

## 2.傅里叶变换的形式

#### 1）正弦信号形式（带相位）

$$
f(x)=\sum_{\omega}A(\omega) * sin(\omega x+\phi(\omega))
$$

相应的频谱形式为
$$
F(\omega)=(A(\omega),\phi(\omega))
$$

#### 2）正余弦信号形式（不带相位）

$$
f(x)=\sum_{\omega}[A_1(\omega)*cos(\omega x)+A_2(\omega)*sin(\omega x)]
$$

此时频谱形式为
$$
F(\omega)=(A_1(\omega),A_2(\omega))
$$

#### 3）复数为指数的信号形式

首先根据欧拉公式
![](http://latex.codecogs.com/gif.latex?
e^{i\theta}=cos(\theta)+isin(\theta)
)
以空域形式表示时，可令
![](http://latex.codecogs.com/gif.latex?
\theta=\omega x
)
可得
![](http://latex.codecogs.com/gif.latex?
cos(\omega x)=\frac{e^{i\omega x}+e^{-i\omega x}}{2}\\
sin(\omega x)=\frac{e^{i\omega x}-e^{-i\omega x}}{2i}
)
这样就可将信号表示为
![](http://latex.codecogs.com/gif.latex?
f(x)=A_1(0)+\sum_{\omega (\omega>0)}\frac{A_1(\omega)-iA_2(\omega)}{2}e^{i\omega x}+\sum_{\omega(\omega>0)}\frac{A_1(\omega)+iA_2(\omega)}{2}e^{-i \omega x}进行
)
由于A的取值只能为正数，可对A1进行偶延拓，对A2进行奇延拓（此处省略大量过程）

最后可将信号和频谱的关系表示为
![](http://latex.codecogs.com/gif.latex?
f(x)=\sum_\omega F(\omega)e^{i\omega x}
)

## 3.海面的逆傅里叶变换模型（FFT）

#### 1）海面高度的表示

i.模型及基本参数解释
$$
h(\vec{x},t)=\sum_{\vec{k}}\tilde{h}(\vec{k},t)e^{i\vec{k} \cdot \vec{x}}
$$
a.其中
$$
\vec{x}=(x,z)
$$
为空域坐标

b.而
$$
\vec{k}=(k_x,k_z)
$$
为频域坐标，两个分量均表示频率

c.则
$$
\tilde{h}(\vec{k},t)
$$
即为海面高度表示中的频谱，参数t表示高度和频谱会随时间变化

ii.参数的取值

在上式中
$$
e^{i\vec{k} \cdot \vec{x}}=e^{i(k_x\cdot x+k_z\cdot z)}
$$
表示固定z，只让x变化时频率为 k_x ；固定x，只让z变化时频率为k_z。

对于向量k的取值，可用如下方式表示：
$$
k_x =\frac{2\pi x_i}{L}, x_i\in \{ -\frac{N}{2},-\frac{N}{2}+1,...,\frac{N}{2}-1\}\\
k_z=\frac{2\pi z_i}{L},z_i \in \{-\frac{N}{2},-\frac{N}{2}+1,...,\frac{N}{2}-1 \}
$$
表示向量k在频域平面上以原点为中心每隔2pi/L取一个点，共取NxN个，其中L为海面面片尺寸。

对于向量x的取值，可用如下方式表示：
$$
x=\frac{x_jL}{N},x_j \in \{-\frac{N}{2},-\frac{N}{2}+1,...,\frac{N}{2}-1\}\\
z=\frac{z_jL}{N},z_j \in \{-\frac{N}{2},-\frac{N}{2}+1,...,\frac{N}{2}-1\}
$$
表示向量x在xz平面以原点为中心每隔L/N取一个点，共取NxN个。

iii.频谱的具体形式
$$
\tilde{h}(\vec{k},t)=\tilde{h}_0(\vec{k})e^{i\omega (k) t}+\tilde{h}^{*}_{0}(-\vec{k})e^{-i\omega (k) t}
$$
其中
$$
\tilde{h}_0(\vec{k})=\frac{1}{\sqrt{2}}(\xi_r+i\xi_i)\sqrt{P_h(\vec{k})}\\
\tilde{h}^{*}_{0}(\vec{k})=\frac{1}{\sqrt2}(\xi_r-i\xi_i)\sqrt{P_h(\vec{k})}\\
P_h(\vec k)=A\frac{e^{-1/{(kL_0)^2}}}{k^4}|\vec k \cdot \vec{\omega}|^2
$$
其中两个\zeta是相互独立的随机数，均服从均值为0，标准差为1的正态分布

且
$$
L_0=\frac{v^2}{g}
$$
其中v表示风速



而风向的表示为
$$
\omega(k)=\sqrt{gk}
$$
g表示重力加速度，k表示向量k的模

#### 2）法线方向的表示和计算

根据海面高度模型，我们可以通过计算其梯度的方向结合如图所示几何关系得到某点的法线方向

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/NomalDir.png)

其中梯度方向为高度逐渐增高的方向，与切线方向相反

up为上方向（0，1，0）

为便于计算，各向量计算前需进行单位化，则法线方向向量可表示为：
$$
\hat{T}=normalize(T)=normalize(-\nabla h(\vec{x},t))\\
\hat{N}=normalize((0,1,0)+\hat{T})\\
=normalize((0,1,0)-\nabla h(\vec{x},t))
$$


而梯度的具体计算为：
$$
\nabla h(\vec x,t)=\sum_{\vec k}\nabla \tilde{h}(\vec{k},t)e^{i \vec{k} \cdot \vec x }\\
=\sum_{\vec k}\tilde{h}(\vec{k},t)\nabla e^{i\vec{k} \cdot \vec{x}}
$$
其中
$$
\nabla e^{i \vec{k} \cdot \vec{x}}=(\frac{ \partial[e^{i(k_x \cdot x+k_z \cdot z)}]}{\partial x },\frac{\partial[e^{i(k_x \cdot x+k_z \cdot z}]}{\partial z})\\
=(ik_x * e^{i(k_x \cdot x +k_z \cdot z)},ik_z * e^{i(k_x \cdot x+k_z \cdot z)})\\
=(ik_x*e^{i \vec{k} \cdot \vec{x}},ik_z * e^{i\vec{k} \cdot \vec{x}})
$$
