function y = my_numCal_Newton_method(mic, gcc_all, v, fs)
% Note:
%       This function is used to realize sound source location by 
%       'numerical calculation method'.
% Usage:
%       y = my_num_calculation_method(mic, delay_ref)
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
%       gcc_all   = ***; % 
%       v         = 340;
%       fs        = 48000;
%       y         = [6.3880, 5.3350, 1.6807];
% 说明：
%       本函数用来实现声源定位（直接牛顿计算的方法）
%       输入：麦克风位置（直角坐标坐标），各通道时延矩阵，速度，采样率
%       输出：声源位置（直角坐标）
%       注意：这种方式是基于直角坐标的，这是牛顿法

% --------------------------------------------------------------
% 初始化
obj = [0.1, 0.1, 0.1]; % 初始值（影响很大），真正的声源是6,5,1.6
error_thresh = 1e-8;   % 误差门限
number = 0;            % 迭代次数
number_thresh = 500;   % 迭代次数门限
error = 100;           % 定义误差的初始值
factor_matrix = [1, -1,  0,  0;
                 1,  0, -1,  0;
                 1,  0,  0, -1;
                 0,  1, -1,  0;
                 0,  1,  0, -1;
                 0,  0,  1, -1;]; % 系数矩阵
delay_ref = my_get_six_delay_point(gcc_all, 20, 20); % 调用函数计算delay_ref

% --------------------------------------------------------------
% 以下是测试内容
error_cac = [];
obj_cac = []; % 用于测试
delay_cac = []; % 用于测试
data_cac = [];
% 可以发现只有当时延估计十分精确的时候，才可以进行距离定位，其它情况下都会导致不收敛
% delay_ref = [5.4932;21.1721;17.5998;15.6759;12.1036;-3.5724]; % 理想情况
% delay_ref = [6.02;21.05;17.65;15.47;12.7;-3.89]; % 有误差
% delay_ref = [6.02-0.4881;21.05;17.65;15.47;12.7-0.5735;-3.89+0.4099]; % 有误差
% delay_ref = [6.02-0.4881;21.05;17.65;15.47;12.7-0.5735;-3.89+0.4099-0.06]; % 有误差
% delay_ref = [6.02-0.4881-0.009;21.05;17.65;15.47;12.7-0.5735;-3.89+0.4099-0.06]; % 有误差
% delay_ref = [5.5932;21.0721;17.6998;15.5759;12.2036;-3.4724]; % 有误差
% delay_ref = [5.4832;21.1821;17.5898;15.6859;12.1136;-3.5624];
% delay_ref = [5.4932;21.1721;17.5998;15.6759;12.1036;-3.5724] + 0.01*rand(6,1);

% --------------------------------------------------------------
% 开启牛顿法主循环
while(error>error_thresh&&number<number_thresh)                 % 当误差或次数达到门限的时候退出
    range = sqrt(sum((ones(4,1)*obj-mic).^2,2));                % 距离           4*1
    delay = factor_matrix*range*2/v*fs;                         % 时延           6*1         
    error = sum((delay-delay_ref).^2);                          % 当前误差       1*1
    range_gradient = 1./(range*ones(1,3)).*(ones(4,1)*obj-mic); % 每个距离的梯度 4*3
    delay_gradient = factor_matrix*range_gradient;              % 每个时延的梯度 6*3
    delay_error = (delay-delay_ref)*ones(1,3);                  % 每个时延误差   6*3
    error_gradient = sum(delay_gradient.*delay_error*4*fs/v);   % 当前误差梯度   1*3
    
    % 以下是牛顿法
    % 一阶梯度矩阵
    e1 = 4*fs/v*(delay-delay_ref)'*factor_matrix*range_gradient; %
    % 二阶梯度矩阵
    e2_cac = factor_matrix*((ones(4,1)*obj-mic).*(1./range*ones(1,3)));
    e2 = 4*fs/v*(1./range')*factor_matrix'*(delay-delay_ref)+8*fs^2/v^2*e2_cac'*e2_cac;
    % 进行迭代
    obj = obj - e1*inv(e2)';
    number = number+1;

%     % 以下用于输出测试
%     number 
%     error
%     obj
%     my_xyzToRtheta(obj(1),obj(2),obj(3))
%     obj_cac = [obj_cac;ans];
%     error_cac = [error_cac;error];
%     delay_cac = [delay_cac;abs(my_delayPoint(mic,obj)-delay_ref')];
%     % 把所有信息都缓存下来
%     % 依次为：[num,error,obj,obj2,delay,delay_error]
%     data_cac = [data_cac;...
%                 number,error,obj,my_xyzToRtheta(obj(1),obj(2),obj(3)),my_delayPoint(mic,obj),abs(my_delayPoint(mic,obj)-delay_ref')
%                 ];
%     % data_cac也是用于测试的内容

end

% --------------------------------------------------------------
% 输出结果 
y = obj;

end