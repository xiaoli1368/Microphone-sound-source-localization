function y = my_srp_phat_spaceShrink_method(gcc_all, mic2, v, fs)
% Note:
%       This function is used to realize sound source location by 
%       'space Shrink method'.
% Usage:
%       y = my_srp_phat_spaceShrink_method(gcc_all, mic2, v, fs)
% Input arguments:
%       gcc_all : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       mic2    : the spherical coordinates of micphone arrays (4*3)
%       v       : the speed of sound (340m/s)
%       fs      : the sampling rate (48000Hz)
% Output arguments:
%       y       : the spherical coordinates of the sound source
% For example:
%       gcc_all = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34];
%       mic2    = [0  , 0 , 0;
%                  0.1, 0 , 0;
%                  0.1, 90, 0;
%                  0.1, 90, 90];
%       v       = 340;
%       fs      = 48000;
%       y       = [5.0800, 77.9711, 39.3912];
% 说明：
%       本函数用来实现声源定位（球坐标下空域收缩法）
%       输入：GCC-PHAT矩阵，麦克风位置（球坐标），声速，采样率
%       输出：声源位置（球坐标）
%       注意：主要思想是通过统计规律不断收缩原始待检测的声源空间

% --------------------------------------------------------------
% 第一次收缩（输出角度区间为20度）
a1 = [0.1,10.1;60,90;0,90]; % 初始搜索范围
b1 = [1,10,10];
a2 = my_spaceShrinkAngle(a1, b1, gcc_all, mic2, v, fs);

% --------------------------------------------------------------
% 第二次收缩（输出角度区间为4度）
b2 = [1,2,2];
a3 = my_spaceShrinkAngle(a2, b2, gcc_all, mic2, v, fs);

% --------------------------------------------------------------
% 第三次收缩（输出角度区间为3度，距离为3米）
b3 = [0.5,0.2,0.2];
a4 = my_spaceShrinkDistance(a3, b3, gcc_all, mic2, v, fs);
% 可以看到距离估计的不是很准
% 以下得继续改进算法

% --------------------------------------------------------------
% 第四次收缩（直接输出估计出的声源位置） 
% b4 = [0.05,0.08,0.08];
b4 = [0.1,0.2,0.2];
a5 = my_spaceShrinkFinal(a4, b4, gcc_all, mic2, v, fs);

% --------------------------------------------------------------
% 输出结果 
y = a5;
% y = my_rthetaToXYZ(a5(1),a5(2),a5(3)); % 进行坐标转换

end