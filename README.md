# MyPostprocessing
 自制Unity后处理效果

文件目录：

  Assets/Scenes————测试各个后处理效果的场景，以对应后处理名字命名

  Assets/Shaders————实现相关后处理效果的Shader文件夹

  Assets/Scripts————以Control为后缀的C#脚本是挂载在相机上控制后处理的代码
 
 修改历史：

——Bloom效果实现阶段1：低级辉光效果，采用均值模糊。
 
——Bloom效果实现阶段2：一般辉光效果，采用高斯模糊，横纵多次，颜色过滤。
