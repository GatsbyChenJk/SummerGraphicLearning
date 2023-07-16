# unity使用Animation组件制作简单的动画

## 1.为物体创建动画资源

首先在项目窗口依次点击Window->Animation->Animation，接着选中要创建动画的物体，点击Create即可创建动画。

![image-20230715220119278](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230715220119278.png)

创建完成后，点击Add Property按钮，可选择对应属性创建动画，这里选择了物体的Rotation属性，如下图所示：

![image-20230715220739423](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230715220739423.png)

## 2.录制动画

在Preview按钮旁边，有一个红色点点按钮，是控制动画录制的开关，点击以后右侧的时间线会变成红色，相应的Inspector面板中的属性也会具有红色底色，代表已经进入录制状态

![image-20230715221053769](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230715221053769.png)

![image-20230715221102805](C:\Users\25768\AppData\Roaming\Typora\typora-user-images\image-20230715221102805.png)

移动时间轴，在对应时刻修改属性，可以在该时刻创建一个关键帧，从上一关键帧到该关键帧物体属性会进行插值运算，这就形成了一个动画。

按下三角形播放图标，可以预览录制的动画。