function y = my_srp_phat_maxFind_method(gcc_all, mic, v, fs)
% Note:
%       This function is used to realize sound source location by looking 
%       for the point with the max SRP response.
% Usage:
%       y = my_srp_phat_maxFind_method(gcc_all, mic, v, fs)
% Input arguments:
%       gcc_all : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       mic     : the cartesian coordinates of micphone arrays (4*3)
%       v       : the speed of sound (340m/s)
%       fs      : the sampling rate (48000Hz)
% Output arguments:
%       y       : the cartesian coordinates of the sound source
% For example:
%       gcc_all = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34];
%       mic     = [0  , 0  , 0  ;
%                  0  , 0  , 0.1;
%                  0.1, 0  , 0  ;
%                  0  , 0.1, 0  ];
%       v       = 340;
%       fs      = 48000;
%       y       = [7.8000, 6.7000, 1.9000];
% 说明：
%       本函数用来实现声源定位（直角坐标寻找最大值法）
%       输入：GCC-PHAT矩阵，麦克风位置（直角坐标），声速，采样率
%       输出：声源位置（直角坐标）
%       注意：这里主要使用直角坐标搜索+SRP-PHAT方法，直接搜索最大值的方法

% --------------------------------------------------------------
% 搜索初始化
xmax = 8;           % x维度搜索边界
ymax = 8;           % y维度搜索边界
zmax = 2;           % z维度搜索边界
dr = 0.12;          % 每个维度搜索精度 （这个地方如何设置为0.1m则输出很准，因为扫描到了真实值）
energycac = 0;      % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2; % 帧长（用于索引SRP）

% --------------------------------------------------------------
% 进行三重循环
for kx = 0:dr:xmax
    for ky = 0:dr:ymax
        for kz = 0:dr:zmax
            
            obj = [kx,ky,kz]; % 目标位置
            
            % 计算距离差（声源到4个麦克风的距离）
            discac = abs(obj-mic(1,:));
            distance1 = sqrt(sum(discac.^2)); % 目标到1号麦克风距离
            discac = abs(obj-mic(2,:));
            distance2 = sqrt(sum(discac.^2)); % 目标到2号麦克风距离
            discac = abs(obj-mic(3,:));
            distance3 = sqrt(sum(discac.^2)); % 目标到3号麦克风距离
            discac = abs(obj-mic(4,:));
            distance4 = sqrt(sum(discac.^2)); % 目标到4号麦克风距离 
            
            % 计算时延点数矩阵
            delaycac = [2*(distance1-distance2)/v*fs;
                        2*(distance1-distance3)/v*fs;
                        2*(distance1-distance4)/v*fs;
                        2*(distance2-distance3)/v*fs;
                        2*(distance2-distance4)/v*fs;
                        2*(distance3-distance4)/v*fs];
            
            % 进行sinc插值加权计算SRP
            energy_xx_cac = zeros(1,6);
            for zz = 1:6
                index = frameLen+floor(delaycac(zz))+(-3:4);
                energy_xx_cac(zz) = my_sinc(gcc_all(zz,index),index,frameLen+delaycac(zz));
            end
            energysum = sum(energy_xx_cac);
            
            % 直接寻找最大值
            if(energysum>energycac) % 如果找到更大的值
                energycac = energysum;
                y = obj;
            end  
            
        end
    end
end

end