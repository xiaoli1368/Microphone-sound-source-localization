function y = my_testSRPchange(mic2, obj, theta, phi)
% Note:
%       This function is used to test the change of SRP along a certain
%       angle.
% Usage:
%       y = my_testSRPchange(mic2, obj, theta, phi)
% Input arguments:
%       mic2    : the spherical coordinates of micphone arrays (4*3)
%       obj     : the real source location (spherical coordinates)
%       theta   : the angle of pitch
%       phi     : the azimuth angle
% Output arguments:
%       y       : the Min and index of Min SRP [index_min,min]
% For example:
%       mic2    = [0  , 0 , 0;
%                  0.1, 0 , 0;
%                  0.1, 90, 0;
%                  0.1, 90, 90];
%       obj     = [7.9725,78.4226,39.8056];
%       theta   = 78;
%       phi     = 39;
%       y       = [5.7000,0.9660];
% 说明：
%       本函数用来实现对于SRP在某一方向上的变化情况
%       输入：麦克风阵列位置，真实的声源坐标，待检测的俯仰角和方位角
%       输出：srp响应的最小值出现的位置，以及最小值，并且作图
%       注意：这里以时延对应的距离误差最为输出并作图

% --------------------------------------------------------------
% 初始化
close all;
index_r = 0.1:0.1:10.1; % 距离向量
N = length(index_r);    % 距离检测点数
result = zeros(1,N);    % 结果存储矩阵

% --------------------------------------------------------------
% 计算真实距离
distance1_obj = my_distancediff(obj,mic2(1,:)); % 目标到1号麦克风距离
distance2_obj = my_distancediff(obj,mic2(2,:)); % 目标到2号麦克风距离
distance3_obj = my_distancediff(obj,mic2(3,:)); % 目标到3号麦克风距离
distance4_obj = my_distancediff(obj,mic2(4,:)); % 目标到4号麦克风距离  

% --------------------------------------------------------------
% 计算真实时延点数矩阵
delaycac_obj = [distance1_obj-distance2_obj;
                distance1_obj-distance3_obj;
                distance1_obj-distance4_obj;
                distance2_obj-distance3_obj;
                distance2_obj-distance4_obj;
                distance3_obj-distance4_obj]; 

% --------------------------------------------------------------
% 扫描计算误差
for kk = 1:N
    r = index_r(kk);
    % 计算距离
    distance1 = my_distancediff([r,theta,phi],mic2(1,:)); % 目标到1号麦克风距离
    distance2 = my_distancediff([r,theta,phi],mic2(2,:)); % 目标到2号麦克风距离
    distance3 = my_distancediff([r,theta,phi],mic2(3,:)); % 目标到3号麦克风距离
    distance4 = my_distancediff([r,theta,phi],mic2(4,:)); % 目标到4号麦克风距离           
    % 计算时延点数矩阵
    delaycac = [distance1-distance2;
                distance1-distance3;
                distance1-distance4;
                distance2-distance3;
                distance2-distance4;
                distance3-distance4];  
   result(kk) = sum(abs(delaycac-delaycac_obj).^2);
end

% --------------------------------------------------------------
% 输出，返回最小值位置，以及最小值
y_index = find(result==min(result));
y = [y_index*0.1,result(y_index)*1e5];

% --------------------------------------------------------------
% 画图
figure;
plot(result,'-o','linewidth',2);
hold on;
stem(result);
grid on;

end