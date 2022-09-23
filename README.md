# Ballance

⚠️ 说明：作者已经完成了复刻 Ballance 的梦想。

这个项目没有多少人支持，因此本项目<font size="16" color="#ff0000">**不会再更新**</font>，做的再好也是白费，无用功。

你可以对源码做出任何改动，把它变成你想要的样子，或者以此为基础搞一个新的滚球游戏。

但本项目所用的ivp物理引擎，Ballance 原版模型、贴图资源的版权归原公司所有（havok、atari），如果要用于商业中，请去除ivp物理引擎，Ballance 原版模型、贴图资源。

========================================

[English readme](./README.en.md)

## 简介

这是 Ballance 游戏的开源 Unity 重制版.

Ballance Unity Rebuild 是作者的一个小梦想，希望让 Ballance 可以运行在更多的平台上，希望让 Ballance 可以
方便的拓展功能开发关卡、模组（后者已经被 [BallanceModLoader](https://github.com/Gamepiaynmo/BallanceModLoader) 实现了），并不是为了取代原版游戏而制作的。

本项目完全开源，你可自行编译、修改、拓展游戏的固有内容。

本项目完成了原版的特性：

* 原版游戏内容和玩法
* 1-13 关游戏内容
* 物理效果相似度 85%

本项目相对于原版增加了以下一些特性：

* **直接加载 NMO 文件**（仅Windows版本）
* Android 版本、Mac版本（你也可以尝试编译其他平台）
* 无须兼容模式运行，调整窗口化、全屏、分辨率、帧率、物理速率、球速
* 自制地图接口（以魔脓空间站为例）
* Lua模组、机关接口（使用Lua开发自定义模组或者机关)
* 关卡预览器
* 模组管理器

![image](/Assets/System/Textures/splash_app.bmp)

---

* [Gitee 国内镜像](https://gitee.com/imengyu/Ballance)
* [Github](https://github.com/imengyu/Ballance)

## 说明

**为嘛没有小伙伴支持呢，或者给一些反馈呀，难道是大家真的不再玩 Ballance 了吗**，感觉没有动力做下去了，后续可能只有修复性更新了，更新时长将会在1-12月不等。

## 系统需求

支持系统

* Windows 7 或更高
* MacOS High Sierra 10.13+ (Intel) 或更高
* Android 6.0 或更高

||最低配置|推荐配置|
|---|---|---|
|处理器|Quad core 3Ghz+|Dual core 3Ghz+|
|内存|1 GB RAM (512MB或许也可以运行，但是有可能会OOM) |2 GB RAM|
|显卡|DirectX 10.1 capable GPU with 512 MB VRAM - GeForce GTX 260, Radeon HD 4850 or Intel HD Graphics 5500|DirectX 11 capable GPU with 2 GB VRAM - GeForce GTX 750 Ti, Radeon R7 360|
|DirectX 版本|11|11|
|存储空间|60 MB 可用空间|100 MB 可用空间|

## 安装

1. 前往 Releases 找到最新版本。
2. 下载对应的 zip 安装包。
3. 解压后，运行其中的 `Ballance.exe` 即可开始游戏。

### 项目源码的运行

需要：

* Unity 2021.2.3 以上版本.
* 编辑器：VScode 或者 Visual Studio
* 克隆或者下载本项目 `https://github.com/imengyu/Ballance` 至您的本地.

步骤：

1. 使用 Unity 打开项目。
2. 第一次运行的时候，你需要点击菜单“SLua”>“All”>“Make” 以生成Lua相关文件，生成之后就不需要再重复点击生成了。
3. 打开 `Scenes/MainScene.unity` 场景。
4. 选择 GameEntry 对象，设置“Debug Type”为“NoDebug”。
5. 点击运行，即可查看效果。

## 直接加载 NMO 文件 【NEW】

Ballance Unity Rebuild 0.9.8 版本支持了加载 Ballance 原版关卡文件的功能。

你可以加载通过点击 “开始” > “加载原版 Ballance NMO 关卡” 来加载一个标准的原版关卡。

核心使用 Virtools SDK 5.0 来处理 NMO 文件，因此只支持 Windows 32位 版本。

大部分关卡可以加载成功并且游玩，但目前有少数限制：

* 不能加载带有 Virtools 脚本的关卡。
* 不支持 Virtools 的点、线网格。
* 材质不支持 Virtools 的特殊效果，将使用默认材质代替。
* 不支持设置关卡天空盒、关卡分数，没有背景音乐。

## 从项目源码生成游戏程序

请参考 [文档](/docs/Help/production.md)。

## 开启调试模式

在 UnityEditor 中运行时，永远是调试模式。

### 如果你需要开启独立版的调试模式，可以

1. 在关于页面，连续点击版本号8次，弹出调试模式提示，
2. 然后重启游戏，就进入了调试模式。
3. 按F12可以开启控制台。

在调试模式中，可以按Q键上升球，E键下降球。

在控制台输入 `quit-dev` 指令可以关闭调试模式。

### 开启所有原版关卡

进入调试模式后在控制台输入 highscore open-all 指令就可以开启全部关卡。

## 文档

[完整文档可以参考这里](https://imengyu.github.io/Ballance/#/readme)

[API文档参考这里](https://imengyu.github.io/Ballance/#/LuaApi/readme)

## 物理引擎

物理引擎的C++源代码可以到[这里](https://github.com/nillerusr/source-physics) 查看 (这个不是作者本人的仓库)。

如果需要拓展引擎，或者想在你的其他项目中使用这个物理引擎，你需要自己编译源代码。

物理引擎的包装DLL代码在项目下方 BallancePhysics 目录下，你需要使用 Visual Studio 2919 以上版本编译。

## 联系我

wechart: brave_imengyu

## 游戏相册

原版关卡

![Demo](docs/DemoImages/11.jpg)
![Demo](docs/DemoImages/12.jpg)
![Demo](docs/DemoImages/13.jpg)
![Demo](docs/DemoImages/14.jpg)
![Demo](docs/DemoImages/18.jpg)
![Demo](docs/DemoImages/9.jpg)
![Demo](docs/DemoImages/6.jpg)
![Demo](docs/DemoImages/7.jpg)
![Demo](docs/DemoImages/15.jpg)
![Demo](docs/DemoImages/16.jpg)
![Demo](docs/DemoImages/17.jpg)

13关的大螺旋

![Demo](docs/DemoImages/9.gif)
![Demo](docs/DemoImages/10.png)

（转译版）自制地图（魔脓空间站）

![Demo](docs/DemoImages/3.jpg)
![Demo](docs/DemoImages/4.jpg)
![Demo](docs/DemoImages/5.jpg)

关卡预览器

![Demo](docs/DemoImages/1.jpg)
![Demo](docs/DemoImages/2.jpg)
