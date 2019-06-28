function y = my_numCal_gradient_descent(mic, gcc_all, v, fs)
% Note:
%       This function is used to realize sound source location by 
%       'numerical calculation method'.
% Usage:
%       y = my_numCal_gradient_descent(mic, gcc_all, v, fs)
% Input arguments:
%       mic       : the spherical coordinates of micphone arrays (4*3)
%       gcc_all   : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       v         : the speed of sound (340m/s)
%       fs        : the sampling rate (48000Hz)
% Output arguments:
%       y         : the cartesian coordinates of the sound source
% For example:
%       mic       = [0  , 0 , 0  ;
%                    0  , 0 , 0.1;
%                    0.1, 0 , 0  ;
%                    0  , 0 , 0.1];
%       gcc_all = ***; % 
%       v       = 340;
%       fs      = 48000;
%       y       = [6.3880, 5.3350, 1.6807];
% 说明：
%       本函数用来实现声源定位（直接数值计算的方法）
%       输入：麦克风位置（直角坐标坐标），各通道时延矩阵，速度，采样率
%       输出：声源位置（直角坐标）
%       注意：这种方式是基于直角坐标的

% --------------------------------------------------------------
% 初始化
obj = [1, 1, 1];      % 初始值（影响很大），真正的声源是6,5,1.6
alpha = 0.005;        % 步长（影响很大）
error_thresh = 1e-1;  % 误差门限
number = 0;           % 迭代次数
number_thresh = 500;  % 迭代次数门限
error = 100;          % 定义误差的初始值
factor_matrix = [1, -1,  0,  0;
                 1,  0, -1,  0;
                 1,  0,  0, -1;
                 0,  1, -1,  0;
                 0,  1,  0, -1;
                 0,  0,  1, -1;]; % 系数矩阵
delay_ref = my_get_six_delay_point(gcc_all, 20, 20); % 调用函数计算delay_ref

% --------------------------------------------------------------
% 梯度下降法
while(error>error_thresh&&number<number_thresh)                 % 当误差或次数达到门限的时候退出
    range = sqrt(sum((ones(4,1)*obj-mic).^2,2));                % 距离           4*1
    delay = factor_matrix*range*2/v*fs;                         % 时延           6*1         
    error = sum((delay-delay_ref).^2);                          % 当前误差       1*1
    range_gradient = 1./(range*ones(1,3)).*(ones(4,1)*obj-mic); % 每个距离的梯度 4*3
    delay_gradient = factor_matrix*range_gradient;              % 每个时延的梯度 6*3
    delay_error = (delay-delay_ref)*ones(1,3);                  % 每个时延误差   6*3
    error_gradient = sum(delay_gradient.*delay_error*4*fs/v);   % 当前误差梯度   1*3
    obj = obj - alpha*error_gradient;                           % 进行迭代更新
    number = number+1;                                          % 记录次数
    
%     % 以下用于输出测试
%     e = 4*fs/v*(delay-delay_ref)'*factor_matrix*range_gradient; %
%     这种方式也是对的
%     % 以下用于输出测试
%     number 
%     error
%     obj

end

% --------------------------------------------------------------
% 输出结果 
y = obj;

end