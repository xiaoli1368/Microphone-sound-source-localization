% TDOA_method
% Note:
%       Release date: 2019/06/06
%       Author: xiaoli
%       Email: xiaoli644@qq.com
% Copyright (C) 2019 xiaoli
% Usage:
%       This program is used to realize the simulation for TDOA.
% 说明：
%       本文主要用来进行TDOA算法的改进。
% 注意：
%       这个是主程序，直接运行即可。

%% 获取数据
% 注意实际中的处理包括：声道合并、二进制转换等
clear;
clc;
close all;

% cd('E:\2018-2019 Master Grade 2 - Backup\006_Competition\003_软件代码\002_初步仿真\TDOA_method');
% 这里原始波形已经完成，是由 obj = [6 5 1.6] 位置处的声源生成的
load('oriWave_004.mat');

fs = 48000; % 采样率
snr = 30;   % 信噪比

% 原始理想信号
s_ideal = [s1cac';s2cac';s3cac';s4cac'];

% 人工加噪
s1cacAddNoise = awgn(s1cac, snr);
s2cacAddNoise = awgn(s2cac, snr);
s3cacAddNoise = awgn(s3cac, snr);
s4cacAddNoise = awgn(s4cac, snr);
s_AddNoise = [s1cacAddNoise';s2cacAddNoise';s3cacAddNoise';s4cacAddNoise'];

% 预滤波
s1cacNoiseFilter = my_prefilter(s1cacAddNoise, 50, 3400, fs); % 300 5000
s2cacNoiseFilter = my_prefilter(s2cacAddNoise, 50, 3400, fs);
s3cacNoiseFilter = my_prefilter(s3cacAddNoise, 50, 3400, fs);
s4cacNoiseFilter = my_prefilter(s4cacAddNoise, 50, 3400, fs);
s_NoiseFilter = [s1cacNoiseFilter';s2cacNoiseFilter';s3cacNoiseFilter';s4cacNoiseFilter'];

% 绘图
t = linspace(0,length(s1cac)/fs,length(s1cac));
figure;
subplot(311);
plot(t,s1cac);
grid on;
xlabel('t/s');
legend('理想信号');
subplot(312);
plot(t,s1cacAddNoise);
grid on;
xlabel('t/s');
legend('加噪信号');
subplot(313);
plot(t,s1cacNoiseFilter);
grid on;
xlabel('t/s');
legend('加噪后滤波信号');

%% 进行分帧
% 设定参数
% frameLenTime = 25e-3; % 25ms
% frameLen = round(fs*frameLenTime); % 1200点
frameLen = 1200;    % 帧长1200点
overLoap = 400;     % 200点重叠

% 以下调用对4路通道分别进行分帧的函数
s_ideal_enframe = my_enframe_four_channels(frameLen,overLoap,s_ideal);             % 原始理想信号的分帧元胞
s_AddNoise_enframe = my_enframe_four_channels(frameLen,overLoap,s_AddNoise);       % 加噪后的分帧元胞
s_NoiseFilter_enframe = my_enframe_four_channels(frameLen,overLoap,s_NoiseFilter); % 加噪滤波后的分帧元胞

%% 计算GCC-PHAT(gcc-all)
frameNum = size(s_ideal_enframe{1,1},1);                          % 帧长
gcc_all = my_gcc_all(frameNum, frameLen, s_ideal_enframe);        % 原始理想信号的6路gcc矩阵
gcc_all2 = my_gcc_all(frameNum, frameLen, s_AddNoise_enframe);    % 加噪后的6路gcc矩阵
gcc_all3 = my_gcc_all(frameNum, frameLen, s_NoiseFilter_enframe); % 加噪滤波后的6路gcc矩阵

% 绘图
figure;
subplot(311);
plot(gcc_all(2,:),'-o','linewidth',2);
hold on;
stem(gcc_all(2,:),'linewidth',1);
legend('理想信号');
xlim([1180,1240]);
grid on;
subplot(312);
plot(gcc_all2(2,:),'-o','linewidth',2);
hold on;
stem(gcc_all2(2,:),'-o','linewidth',1);
legend('加噪信号');
xlim([1180,1240]);
grid on;
subplot(313);
plot(gcc_all3(2,:),'-o','linewidth',2);
hold on;
stem(gcc_all3(2,:),'-o','linewidth',1);
legend('加噪后滤波信号');
xlim([1180,1240]);
grid on;

%% 空间位置
close all;
clc;

% 初始化几何位置（直角坐标和球坐标）
mic = [0  ,0  ,0  ;
       0  ,0  ,0.1;
       0.1,0  ,0  ;
       0  ,0.1,0  ];    % 麦克风位置（1/2/3/4）
mic2 = [0  , 0 , 0;
        0.1, 0 , 0;
        0.1, 90, 0;
        0.1, 90, 90];   % 球坐标下麦克风位置（1/2/3/4）
obj = [6  ,5  ,1.6  ];  % 真实声源位置
v = 340;                % 声速

%% 进行定位
clc;

% 真实声源位置
obj_sph = my_xyzToRtheta(obj(1),obj(2),obj(3));
fprintf('---------------------------------------------------：\n');
fprintf('《真实声源位置》\n');
fprintf('直角坐标结果：%7.4f met, %7.4f met, %7.4f met\n', obj(1), obj(2), obj(3));
fprintf('球面坐标结果：%7.4f met, %7.4f deg, %7.4f deg\n', obj_sph(1), obj_sph(2), obj_sph(3));

% 方法一：直角坐标扫描SRP最大值法
t0 = cputime;
result1 = my_srp_phat_maxFind_method(gcc_all, mic, v, fs);
t1 = cputime;
result1_sph = my_xyzToRtheta(result1(1),result1(2),result1(3));
fprintf('---------------------------------------------------：\n');
fprintf('《直角坐标扫描SRP最大值法》\n');
fprintf('方法一用时为：%7.4fs\n', t1-t0);
fprintf('直角坐标结果：%7.4f met, %7.4f met, %7.4f met\n', result1(1), result1(2), result1(3));
fprintf('球面坐标结果：%7.4f met, %7.4f deg, %7.4f deg\n', result1_sph(1), result1_sph(2), result1_sph(3));

% 方法二：球坐标SRP空域收缩法
t0 = cputime;
result2_sph = my_srp_phat_spaceShrink_method(gcc_all, mic2, v, fs);
t1 = cputime;
result2 = my_rthetaToXYZ(result2_sph(1),result2_sph(2),result2_sph(3));
fprintf('---------------------------------------------------：\n');
fprintf('《球坐标SRP空域收缩法》\n');
fprintf('方法二用时为：%7.4fs\n', t1-t0);
fprintf('直角坐标结果：%7.4f met, %7.4f met, %7.4f met\n', result2(1), result2(2), result2(3));
fprintf('球面坐标结果：%7.4f met, %7.4f deg, %7.4f deg\n', result2_sph(1), result2_sph(2), result2_sph(3));

% 方法三：直接梯度下降法
t0 = cputime;
result3 = my_numCal_gradient_descent(mic, gcc_all, v, fs);
t1 = cputime;
result3_sph = my_xyzToRtheta(result3(1),result3(2),result3(3));
fprintf('---------------------------------------------------：\n');
fprintf('《直接梯度下降法》\n');
fprintf('方法三用时为：%7.4fs\n', t1-t0);
fprintf('直角坐标结果：%7.4f met, %7.4f met, %7.4f met\n', result3(1), result3(2), result3(3));
fprintf('球面坐标结果：%7.4f met, %7.4f deg, %7.4f deg\n', result3_sph(1), result3_sph(2), result3_sph(3));

% 方法四：直接牛顿法
t0 = cputime;
result4 = my_numCal_Newton_method(mic, gcc_all, v, fs);
t1 = cputime;
result4_sph = my_xyzToRtheta(result4(1),result4(2),result4(3));
fprintf('---------------------------------------------------：\n');
fprintf('《直接牛顿法》\n');
fprintf('方法三用时为：%7.4fs\n', t1-t0);
fprintf('直角坐标结果：%7.4f met, %7.4f met, %7.4f met\n', result4(1), result4(2), result4(3));
fprintf('球面坐标结果：%7.4f met, %7.4f deg, %7.4f deg\n', result4_sph(1), result4_sph(2), result4_sph(3));
