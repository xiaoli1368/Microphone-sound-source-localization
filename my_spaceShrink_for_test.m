function c = my_spaceShrink_for_test(a, b, gcc_all, mic2, v, fs)
% 该函数主要用来测试，也是对角度进行了收缩迭代，与my_spaceShrinkAngle十分类似
% 因为是测试版，所以注释就不写的这么正式了
% 本函数用来实现空域的收缩迭代（不考虑极径）
% 输入：原始边界，分辨率
% 输出：收缩边界
% a = [0.1,10.1;  %  r
%      60,90;     %  theta
%      0,90;]     %  phi
% b = [1,10,10];
% c = [0.1,10.1;
%      30,50;
%      70,90];

% --------------------------------------------------------------
% 初始化
% energycac = 0; % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2;   % 帧长
srpangle = [];                      % 用来缓存矩阵

% --------------------------------------------------------------
% 进行三重循环
for theta = a(2,1):b(2):a(2,2)      % 俯仰角
    for phi = 0:b(3):90             % 方位角    
        response_cac = 0;
        for r = a(1,1):b(1):a(1,2)  % 径
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
        srpangle = [srpangle;[theta,phi,response_cac]];
    end
end

% --------------------------------------------------------------
% 计算收缩后的结果
srpangle = sortrows(srpangle,3);
number_cac = size(srpangle,1);   % 行数
number = round(number_cac*0.1);  % 提取前10%进行加权
weight_cac = srpangle(end-number:end,3)/sum(srpangle(end-number:end,3));
theta_ave = sum(srpangle((end-number):end,1).*weight_cac);
phi_ave = sum(srpangle((end-number):end,2).*weight_cac);

% --------------------------------------------------------------
% 输出
c = [a(1,1),a(1,2);
     theta_ave-b(2),theta_ave+b(2);
     phi_ave-b(3),phi_ave+b(3)];

end