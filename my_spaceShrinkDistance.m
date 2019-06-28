function c = my_spaceShrinkDistance(a, b, gcc_all, mic2, v, fs)
% Note:
%       This function is used to realize‘space Shrink' from distance.
% Usage:
%       c = my_spaceShrinkDistance(a, b, gcc_all, mic2, v, fs)
% Input arguments:
%       a       : the original angle/distance range
%       b       : the original resolution
%       gcc_all : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       mic2    : the spherical coordinates of micphone arrays (4*3)
%       v       : the speed of sound (340m/s)
%       fs      : the sampling rate (48000Hz)
% Output arguments:
%       c       : the angle/distance range after shrinking (it size relates to b)
% For example:
%       a       = [0.1    , 10.1   ;   % r
%                  76.4251, 84.4251;   % theta
%                  38.0377, 42.0377;]  % phi
%       b       = [0.5, 0.2, 0.2];     % r/theta/phi
%       gcc_all = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34];
%       mic2    = [0  , 0 , 0;
%                  0.1, 0 , 0;
%                  0.1, 90, 0;
%                  0.1, 90, 90];
%       v       = 340;
%       fs      = 48000;
%       c       = [4.6    , 8.6    ;   % r
%                  76.4251, 78.4137;   % theta
%                  39.3472, 41.3472];  % phi
% 说明：
%       本函数用来实现空域的收缩迭代（主要对距离而言，角度也适当收缩了）
%       输入：原始边界，分辨率
%       输出：收缩边界
%       注意：这种方式重点是对极径距离进行收缩

% --------------------------------------------------------------
% 初始化
frameLen = (size(gcc_all,2)+1)/2;  % 帧长
index_theta = a(2,1):b(2):a(2,2);  % 俯仰角
index_phi = a(3,1):b(3):a(3,2);    % 方位角
index_r = a(1,1):b(1):a(1,2);      % 径
% 用来缓存矩阵
num_r = length(index_r);           % r向量大小
num_theta = length(index_theta);   % theta向量大小
num_phi = length(index_phi);       % phi向量大小
num_row = num_theta*num_phi;       % 角度向量大小
number_srpdistance = 0;            % 用于缓存的控制变量
% 测试用
srpdistance = zeros(num_r+4,num_row+2);

% --------------------------------------------------------------
% 进行三重循环
for r = index_r             % 径
    n1 = 0;
    for theta = index_theta % 俯仰角
        n1 = n1+1;
        n2 = 0;
        for phi = index_phi % 方位角  
             n2 = n2+1;
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
                index = frameLen+floor(delaycac(zz))+(-5:5); % 改变这里可以控制sinc加权点范围(-3:4)
                energy_xx_cac(zz) = my_sinc(gcc_all(zz,index),index,frameLen+delaycac(zz));
            end
            energysum = sum(energy_xx_cac);            
            % 对每一个方向，生成距离主导的响应矩阵
            srpdistance(number_srpdistance+1,num_theta*(n1-1)+n2) = energysum; % 测试用
        end
    end
    % 进行存储
    srpdistance_cac = srpdistance(number_srpdistance+1,:);
    srpdistance(number_srpdistance+1,num_row+1:num_row+2) = [mean(srpdistance_cac),var(srpdistance_cac,1)];
    number_srpdistance = number_srpdistance+1;
end

% --------------------------------------------------------------
% 处理数据
srpdistance2 = [[index_r';zeros(4,1)],srpdistance];                                  % 添加与极径
for kk = 2:size(srpdistance2,2)
    if(kk<=size(srpdistance2,2)-2)
        srpdistance2(num_r+1,kk) = index_theta(ceil((kk-1)/num_phi));                % 添加theta
        srpdistance2(num_r+2,kk) = index_phi(kk-1-(ceil((kk-1)/num_phi)-1)*num_phi); % 添加phi
    end
    max_cac = srpdistance2(1:num_r,kk);
    srpdistance2(num_r+3,kk) = max(max_cac);                         % 寻找最大值
    srpdistance2(num_r+4,kk) = index_r(find(max_cac==max(max_cac))); % 寻找最大值处对于距离
end

% --------------------------------------------------------------
% 后续处理
distance_temp = [];
for kk = 2:size(srpdistance2,2)-2 % 暂时不要方差，方差应该计算最小值（这里有问题）
    if(srpdistance2(end,kk)~=max(index_r))
        distance_temp = [distance_temp;srpdistance2(end:-1:end-4,kk)'];
    end
end
% 计算距离和角度上的收缩
% 这个地方有问题，单纯靠SRP的最大值排序有问题
% 可以参考比较哪一条曲线的
distance_temp2 = sortrows(distance_temp,-5);      % 负号表示降序
distace_center = distance_temp2(1:3,1)'*[1,0,0]'; % 对前三个数值进行加权[0.5 0.3 0.2]计算距离中值
theta_center = mean(distance_temp2(:,4));         % 计算输出theta区间的中值
phi_center = mean(distance_temp2(:,3));           % 计算输出phi区间的中值

% --------------------------------------------------------------
% 输出结果
c = [max(distace_center-2,0),min(distace_center+2,10.1);
     max(theta_center-1,a(2,1)),min(theta_center+1,a(2,2));
     max(phi_center-1,a(3,1)),min(phi_center+1,a(3,2))];

end