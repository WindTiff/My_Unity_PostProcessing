# MyPostprocessing
自制Unity后处理效果，基于ShaderLab完成Cg Shader编写，C#逻辑编写，仿制Unity后处理插件提供的效果。

文件目录：

  Assets/Scenes————测试各个后处理效果的场景，以对应后处理名字命名

  Assets/Shaders————实现相关后处理效果的Shader文件夹

  Assets/Scripts————以Control为后缀的C#脚本是挂载在相机上控制后处理的代码
 
 修改历史：

——Bloom效果实现阶段1：初级辉光效果，采用均值模糊。
 
——Bloom效果实现阶段2：一般辉光效果，采用高斯模糊，横纵交替，可设置颜色过滤。

——Vignette效果实现：可以控制遮挡颜色，可视部分位置，形状，大小以及边缘渐变程度。

——Depth Of Field效果实现：一般景深效果，可以调节焦点距离，高斯模糊参数（降采样程度，模糊半径，迭代次数）。

——Len Distortion效果实现阶段1：初级鱼眼镜头畸变效果，可以设定畸变中心，横向纵向强度调节。

——全景扫描效果实现：基于深度图的后处理全景扫描效果，可以设定最大扫描距离、扫描线扩张速度、扫描线颜色、扫描线粗细。




效果：
![image](https://github.com/WindTiff/UsingImages/blob/master/images/BloomEffect.png)
