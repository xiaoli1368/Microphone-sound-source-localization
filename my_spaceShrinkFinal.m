function c = my_spaceShrinkFinal(a, b, gcc_all, mic2, v, fs)
% Note:
%       This function is used to realize‘space Shrink' to get the sound source location.
% Usage:
%       c = my_spaceShrinkFinal(a, b, gcc_all, mic2, v, fs)
% Input arguments:
%       a       : the original angle/distance range
%       b       : the original resolution
%       gcc_all : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       mic2    : the spherical coordinates of micphone arrays (4*3)
%       v       : the speed of sound (340m/s)
%       fs      : the sampling rate (48000Hz)
% Output arguments:
%       c       : the sound source location
% For example:
%       a       = [4.6    , 8.6    ;   % r
%                  76.4251, 78.4137;   % theta
%                  39.3472, 41.3472;]  % phi
%       b       = [0.1, 0.2, 0.2];     % r/theta/phi
%       gcc_all = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34];
%       mic2    = [0  , 0 , 0;
%                  0.1, 0 , 0;
%                  0.1, 90, 0;
%                  0.1, 90, 90];
%       v       = 340;
%       fs      = 48000;
%       c       = [5.08, 77.9711, 39.3912]; % r/theta/phi
% 说明：
%       本函数用来实现空域的收缩迭代（主要对距离而言，角度也适当收缩了）
%       输入：原始边界，分辨率
%       输出：估计出的声源位置
%       注意：这种方式重点是对当前空域进行扫描后估计声源位置

% --------------------------------------------------------------
% 初始化
frameLen = (size(gcc_all,2)+1)/2;   % 帧长
index_theta = a(2,1):b(2):a(2,2);   % 俯仰角
index_phi = a(3,1):b(3):a(3,2);     % 方位角
index_r = a(1,1):b(1):a(1,2);       % 径
% 用来缓存矩阵
num_r = length(index_r);            % r向量大小
num_theta = length(index_theta);    % theta向量大小
num_phi = length(index_phi);        % phi向量大小
num_all = num_theta*num_phi*num_r;  % 全局扫描点数
srpfinal = zeros(num_all,6);        % 全局存储矩阵

% --------------------------------------------------------------
% 直接分裂式计算三维矩阵
for kr = 2:num_r-1
    for ktheta = 2:num_theta-1
        for kphi = 2:num_phi-1
            % 初始化
            index_cac = [0 0 1;
                         0 0 -1;
                         1 0 0;
                         -1 0 0;
                         0 1 0;
                         0 -1 0;
                         0 0 0];                                % 用来控制加权的7个方向
            index_cac2 = ones(7,1)*[kr,ktheta,kphi]-index_cac;  % 计算7个位置的索引矩阵
            % 确认是否完成计算
            data_temp = zeros(1,7);
            for kk = 1:7
                index_cac3 = sub2ind([num_r,num_theta,num_phi],index_cac2(kk,1),index_cac2(kk,2),index_cac2(kk,3));
                if(srpfinal(index_cac3,4)==0) % 如何还没有进行计算
                    % 初始化
                    r = index_r(index_cac2(kk,1));
                    theta = index_theta(index_cac2(kk,2));
                    phi = index_phi(index_cac2(kk,3));
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
                        index = frameLen+floor(delaycac(zz))+(-5:5); % (-3:4)
                        energy_xx_cac(zz) = my_sinc(gcc_all(zz,index),index,frameLen+delaycac(zz));
                    end 
                    % 完成计算
                    srpfinal(index_cac3,4) = sum(energy_xx_cac);  
                    srpfinal(index_cac3,1:3) = [index_r(index_cac2(kk,1)),index_theta(index_cac2(kk,2)),index_phi(index_cac2(kk,3))];
                end
                % 取出7个值
                data_temp(kk) = srpfinal(index_cac3,4);
            end
            % 到这里应该七个单元都完成了计算，并且已经取出
            index_cac4 = sub2ind([num_r,num_theta,num_phi],index_cac2(7,1),index_cac2(7,2),index_cac2(7,3));
            srpfinal(index_cac4,[1,2,3,5,6]) = [index_r(kr),index_theta(ktheta),index_phi(kphi),mean(data_temp),var(data_temp,1)]; 
        end
    end
end

% --------------------------------------------------------------
% 计算满足条件的距离
srp_cac = srpfinal(:,4);
index_srp = mean(find(srp_cac==max(srp_cac)));             % 寻找srp中的最大值作为参考索引1
mean_cac = srpfinal(:,5);
index_mean = mean(find(mean_cac==max(mean_cac)));          % 寻找mean中的最大值作为参考索引2
var_cac = srpfinal(:,6);
index_var = mean(find(var_cac==min(var_cac(var_cac~=0)))); % 寻找var中的最小值作为参考索引3，注意消除零值影响
r_output = [srpfinal(index_srp,1),srpfinal(index_mean,1),srpfinal(index_var,1)]*[0.05,0.05,0.9]'; % 不能对索引进行加权，存在问题

% --------------------------------------------------------------
% 计算满足条件的角度
srp_cac2 = sortrows(srpfinal,-4);
theta_output = mean(srp_cac2(1:100,2));
phi_output = mean(srp_cac2(1:100,3));

% --------------------------------------------------------------
% 输出结果
c = [r_output,theta_output,phi_output];

end