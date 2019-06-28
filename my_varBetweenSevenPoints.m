function [y1,y2] = my_varBetweenSevenPoints(obj,mic,dx)
% Note:
%       This function is used to calculate the mean and var of 7 points' DelayPoints. 
% Usage:
%       [y1,y2] = my_varBetweenSevenPoints(obj,mic,dx)
% Input arguments:
%       obj     : the center point (cartesian coordinates)
%       mic     : the cartesian coordinates of micphone arrays (4*3)
%       dx      : the radius of these 7 points
% Output arguments:
%       [y1,y2] : the mean and var of these 7 points SRP
% For example:
%       mic     = [0  , 0 , 0  ;
%                  0  , 0 , 0.1;
%                  0.1, 0 , 0  ;
%                  0  , 0 , 0.1];
%       obj     = [6,5,1.6];
%       dx      = 0.1;
%       [y1,y2] = [1.0634,0.0299];
% 说明：
%       本函数用来计算某一中心点覆盖的周围7个点的时延点数误差的均值和方差
%       输入：声源坐标，阵列坐标，分辨率
%       输出：均值，方差
%       注意：这里以时延对应的距离误差最为输出并作图

% --------------------------------------------------------------
% 初始化
v = 340;                                            % 声速
fs = 48000;                                         % 采样率
delaycac_obj = [6.02;21.05;17.65;15.47;12.7;-3.89]; % 参考的时延点数，这个需要改
distance_cac = zeros(1,7);
obj_cac = ones(7,1)*obj-dx*[0 0 0;0 0 1;0 0 -1;0 1 0;0 -1 0;1 0 0;-1 0 0];

% --------------------------------------------------------------
% 循环计算误差
for kk = 1:7
    % 计算距离差
    discac = abs(obj_cac(kk,:)-mic(1,:));
    distance1 = sqrt(sum(discac.^2)); % 目标到1号麦克风距离
    discac = abs(obj_cac(kk,:)-mic(2,:));
    distance2 = sqrt(sum(discac.^2)); % 目标到2号麦克风距离
    discac = abs(obj_cac(kk,:)-mic(3,:));
    distance3 = sqrt(sum(discac.^2)); % 目标到3号麦克风距离
    discac = abs(obj_cac(kk,:)-mic(4,:));
    distance4 = sqrt(sum(discac.^2)); % 目标到4号麦克风距离 
    % 计算时延点数矩阵
    delaycac = [2*(distance1-distance2)/v*fs;
                2*(distance1-distance3)/v*fs;
                2*(distance1-distance4)/v*fs;
                2*(distance2-distance3)/v*fs;
                2*(distance2-distance4)/v*fs;
                2*(distance3-distance4)/v*fs
               ];
    % 计算误差
    distance_cac(kk) = sum((delaycac-delaycac_obj).^2);
end

% --------------------------------------------------------------
% 输出
y1 = mean(distance_cac);  % 均值
y2 = var(distance_cac,1); % 方差

end