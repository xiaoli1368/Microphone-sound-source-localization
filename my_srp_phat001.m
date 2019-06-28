function y = my_srp_phat001(gcc_all, mic, v, fs)
% 这个函数其实就是 my_srp_phat_maxFind_method 的测试版
% 本函数用来实现声源定位
% 输入：GCC-PHAT矩阵，麦克风位置，声速，采样率
% 输出：声源位置
% 说明：这里主要使用直角坐标搜索+SRP-PHAT方法，直接最大值的方法

% --------------------------------------------------------------
% 搜索初始化
xmax = 8;      % x维度搜索边界
ymax = 8;      % y维度搜索边界
zmax = 2;      % z维度搜索边界
dr = 0.1;      % 每个维度搜索精度
energycac = 0; % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2; % 帧长（用于索引SRP）

% --------------------------------------------------------------
% 三重循环进行搜索
for kx = 0:dr:xmax
    for ky = 0:dr:ymax
        for kz = 0:dr:zmax
            obj = [kx,ky,kz]; % 目标位置
            % 计算距离差
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
                        2*(distance3-distance4)/v*fs
                       ];
            % 进行sinc加权计算SRP
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