# 麦克风声源定位

[![](https://img.shields.io/badge/Environment-Matlab-blue)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)  [![](https://img.shields.io/badge/Size-15.3Mb-orange)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)  [![](https://img.shields.io/badge/License-MIT-brightgreen)](<https://github.com/xiaoli1368/Microphone-sound-source-localization>)

当前项目所做出的工作是基本上实现了TDOA的测角的功能，主要由以下两个步骤实现：

- 首先，利用GCC-PHAT估计出各个通道之间的时延
- 然后，利用SRP-PHAT进行声源位置的估计定位

其中在第二步的过程中，使用到了空域收缩的方法，即使用球坐标进行搜索，逐渐缩小搜索的范围（指角度），通过计算每个角度方向上的SRP总和来衡量该方向是否应该被收缩域包括。但是对于距离的判定出现了较大的误差，因此当前只能实现测角。对于距离定位，还需要对几何以及SRP的原理进行系统的分析才可以完成。

除此之外，也使用了一些基本的数值计算的方法来进行求解，结果也是能够实现角度定位，但是难以实现距离定位。更加精确的定位还需要进行算法层面上的进一步改进。

## 目录

- [Background](#background)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## 介绍

##  使用说明

1.当前代码由matlab运行。

2.这里**TDOA_method.m**为主程序，直接运行即可。

3.mat文件为四路麦克风采集到的语音信号，如果想要使用自己的数据可以参照mat内文件的存储名称，相应的改为自己的语音文件。如果想使用多路麦克风的模型（如6路）则较为困难，需要将所有代码中涉及到四路处理的内容全部修改。

4.麦克风阵列模型的坐标在主程序中以完成初始化，必须时可以自行修改。

5.这里调用了几种不同的进行声源定位的子函数，其中主要的方法只有两种：SRP-PHAT以及数值计算法。

# 其它

如有疑问，请与我联系。
