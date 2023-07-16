# unity的内置渲染管线、通用渲染管线和高清晰度渲染管线

## 1.概念

Unity是一款流行的游戏开发引擎，它提供了不同的渲染管线选项，以满足不同项目的需求。下面是对Unity的内置渲染管线、通用渲染管线（Universal Render Pipeline，简称URP）和高清晰度渲染管线（High Definition Render Pipeline，简称HDRP）的概念解释：

1. 内置渲染管线：
Unity的内置渲染管线（Built-in Render Pipeline）是Unity早期版本中默认的渲染管线。它提供了基本的渲染功能，适用于简单的2D和3D项目。内置渲染管线使用了一种称为Forward Rendering的技术，它在每个像素上执行一次光照计算。然而，内置渲染管线的功能相对较为有限，不支持一些高级的图形效果。

2. 通用渲染管线（URP）：
通用渲染管线（Universal Render Pipeline，URP）是Unity 2019版本引入的一种渲染管线。URP旨在提供更好的性能和可移植性，同时支持2D和3D项目。它使用了一种称为可编程渲染管线（Scriptable Render Pipeline，SRP）的技术，允许开发者自定义渲染过程。URP支持一些高级图形效果，如屏幕空间反射（Screen Space Reflections）和后处理效果（Post-processing effects）。

3. 高清晰度渲染管线（HDRP）：
高清晰度渲染管线（High Definition Render Pipeline，HDRP）是Unity 2018版本引入的一种渲染管线。HDRP旨在提供逼真的图形效果，适用于需要高质量渲染的项目，如AAA级游戏和高端渲染应用。HDRP支持更多的图形功能，如实时光线追踪（Real-time Ray Tracing）和物理材质（Physically Based Materials）。然而，由于其高质量的渲染需求，HDRP对硬件要求较高。

总结来说，Unity的内置渲染管线适用于简单的2D和3D项目，通用渲染管线（URP）提供了更好的性能和可移植性，而高清晰度渲染管线（HDRP）适用于需要高质量渲染的项目。选择哪种渲染管线取决于项目的需求和性能要求。

## 2.怎么新建一个渲染管线

渲染管线在unity中作为一种asset，所以新建渲染管线要在asset窗口右键然后依次点击Create->Rendering，就可以创建相应的渲染管线，例如创建一个urp渲染管线的过程如下：

![image text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711165049518.png)

依次点击Create->Rendering->URP Asset(with Universal Renderer)

## 3.如何将项目应用对应的渲染管线

依次打开Edit->Project  Settings->Graphics->Scriptable Render Pipeline Settings

![image text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711165410756.png)

点击小圆圈，弹出一个小窗，里面有可供选择的渲染管线资源，选择创建的渲染管线资源后

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711165555925.png)

可能会出现场景着色器文件错误而导致的显示为紫色，这时需要依次打开

Window->Rendering->Render Pipeline Converter

![image-text](https://github.com/GatsbyChenJk/SummerGraphicLearning/blob/main/%E7%AC%94%E8%AE%B0/images/image-20230711165744375.png)

如果修改后的渲染管线是urp，将converter里的下拉菜单改成Built-in to URP

勾选全部选项，点击Initialize Converters，等初始化完成后点击Convert Assets即可解决问题。
