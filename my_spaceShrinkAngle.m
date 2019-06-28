function c = my_spaceShrinkAngle(a, b, gcc_all, mic2, v, fs)
% Note:
%       This function is used to realize‘space Shrink' from angle.
% Usage:
%       c = my_spaceShrinkAngle(a, b, gcc_all, mic2, v, fs)
% Input arguments:
%       a       : the original angle/distance range
%       b       : the original resolution
%       gcc_all : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       mic2    : the spherical coordinates of micphone arrays (4*3)
%       v       : the speed of sound (340m/s)
%       fs      : the sampling rate (48000Hz)
% Output arguments:
%       c       : the angle angle/distance after shrinking (it size relates to b)
% For example:
%       a       = [0.1, 10.1;  % r
%                  60 , 90  ;  % theta
%                  0,   90;]   % phi
%       b       = [1, 10, 10]; % r/theta/phi
%       gcc_all = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34];
%       mic2    = [0  , 0 , 0;
%                  0.1, 0 , 0;
%                  0.1, 90, 0;
%                  0.1, 90, 90];
%       v       = 340;
%       fs      = 48000;
%       c       = [0.1, 10.1;  % r
%                  30 ,   50;  % theta
%                  70 ,   90]; % phi
% 说明：
%       本函数用来实现空域的收缩迭代（仅对角度而言，不考虑极径）
%       输入：原始边界，分辨率
%       输出：收缩边界
%       注意：这种方式只是对角度进行收缩

% --------------------------------------------------------------
% 初始化
frameLen = (size(gcc_all,2)+1)/2; % 帧长
index_theta = a(2,1):b(2):a(2,2); % 俯仰角向量
index_phi = a(3,1):b(3):a(3,2);   % 方位角向量
index_r = a(1,1):b(1):a(1,2);     % 径向量
% 用来缓存的矩阵
srpangle = zeros(length(index_theta)*length(index_phi),3);  % 全局缓存矩阵（以角度个数为行）
number_srpangle = 0;                                        % 缓存矩阵存储变量

% --------------------------------------------------------------
% 进行三重循环
for theta = index_theta     % 俯仰角
    for phi = index_phi     % 方位角    
        response_cac = 0;   % 用来计算每个方向上的缓存矩阵
        for r = index_r     % 径
            % 计算距离
            distance1 = my_distancediff([r,theta,phi],mic2(1,:)); % 目标到1号麦克风距离
            distance2 = my_distancediff([r,theta,phi],mic2(2,:)); % 目标到2号麦克风距离
            distance3 = my_distancediff([r,theta,phi],mic2(3,:)); % 目标到3号麦克风距离
            distance4 = my_distancediff([r,theta,phi],mic2(4,:)); % 目标到4号麦克风距离           
            % 计算时延点数矩阵
            delaycac = [2*(distance1-distance2)/v*fs;
                        2*(distance1-distance3)/v*fs;
                        2*(distance1-distance4)/v*fs;
                        2*(distance2-distance3)/v*fs;
                        2*(distance2-distance4)/v*fs;
                        2*(distance3-distance4)/v*fs
                       ];            
            % 进行sinc加权计算SRP
            energy_xx_cac = zeros(1,6);
            for zz = 1:6
                index = frameLen+floor(delaycac(zz))+(-3:4);
                energy_xx_cac(zz) = my_sinc(gcc_all(zz,index),index,frameLen+delaycac(zz));
            end
            energysum = sum(energy_xx_cac);
            % 存储该方向的10个SRP的响应和
            response_cac = response_cac+energysum;
        end
        % 进行存储
        number_srpangle = number_srpangle+1;
        srpangle(number_srpangle,:) = [theta,phi,response_cac];
    end
end

% --------------------------------------------------------------
% 计算收缩后的结果
srpangle = sortrows(srpangle,3); % 进行SRP排序
number_cac = size(srpangle,1);   % 行数
number = round(number_cac*0.1);  % 提取前10%进行加权
% weight_cac = srpangle(end-number:end,3)/sum(srpangle(end-number:end,3));
% 换一种权重方式（最大值0.5权重，剩下的0.5再分配给额外的前10%个最大的值进行系数加权）
weight_cac = [srpangle(end-number:end-1,3)/sum(srpangle(end-number:end-1,3))*0.5;0.5]; % 获取权重向量
theta_ave = sum(srpangle((end-number):end,1).*weight_cac);                             % 加权获得theta
phi_ave = sum(srpangle((end-number):end,2).*weight_cac);                               % 加权获得phi

% --------------------------------------------------------------
% 输出
c = [a(1,1),a(1,2);                   % r
     theta_ave-b(2),theta_ave+b(2);   % theta
     phi_ave-b(3),phi_ave+b(3)];      % phi

end