function c = my_spaceShrinkFinal2_for_test(a, b, gcc_all, mic, v, fs)
% 本函数用来实现空域的收缩迭代（不考虑角度）
% 这里改变一种方式直接对距离误差进行扫描
% 这种方式还是几何方法，进行强行扫描，还是不好，有时间想一下数值方法
% 这个函数是一个测试版
% 输入：原始边界，分辨率
% 输出：估计出的声源位置

% --------------------------------------------------------------
% 初始化
frameLen = (size(gcc_all,2)+1)/2;  % 帧长
index_theta = a(2,1):b(2):a(2,2);  % 俯仰角
index_phi = a(3,1):b(3):a(3,2);    % 方位角
index_r = a(1,1):b(1):a(1,2);      % 径
delaycac_obj = [6.02;21.05;17.65;15.47;12.7;-3.89]; % 参考的准确时延，这个需要与输入数据同时更正

% --------------------------------------------------------------
% 用来缓存矩阵
num_r = length(index_r);           % 距离大小
num_theta = length(index_theta);   % 俯仰角大小
num_phi = length(index_phi);       % 方位角大小
num_all = num_theta*num_phi*num_r; % 全部采样点大小

% --------------------------------------------------------------
% 直接计算三维矩阵
number_srpfinal = 0;          % 表示已经完成的个数
srpfinal = zeros(num_all,6);  % 整体存储矩阵
number_srpfinal_r = 0;        % 表示已经完成r的个数
srpfinal_r = zeros(num_r,2);  % 对距离维度的存储矩阵
for r = index_r
    cac_r = 0;
    for theta = index_theta
        for phi = index_phi
            % 初始化
            obj = my_rthetaToXYZ(r,theta,phi);
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
            % 计算误差
            error_cac = sum((delaycac-delaycac_obj).^2);
            [y1,y2] = my_varBetweenSevenPoints(obj,mic,0.05);
            number_srpfinal = number_srpfinal+1;
            srpfinal(number_srpfinal,1:6) = [r,theta,phi,error_cac,y1,y2];
            % 对r进行缓存
            cac_r = cac_r+error_cac;
        end
    end
    % 缓存
    number_srpfinal_r = number_srpfinal_r+1; % 表示已经完成r的个数
    srpfinal_r(number_srpfinal_r,1:2) = [r,cac_r];
end

% --------------------------------------------------------------
% 计算满足条件的距离索引
srpfinal_r = sortrows(srpfinal_r,2);
output_r = mean(srpfinal_r(1:10,1));

% 计算满足条件的角度索引
srpfinal = sortrows(srpfinal,4);
output_theta = mean(srpfinal(1:100,2));
output_phi = mean(srpfinal(1:100,3));

% --------------------------------------------------------------
% 输出结果
c = [output_r,output_theta,output_phi];

end