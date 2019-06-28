function y = my_delayPoint(mic, obj)
% Note:
%       This function is used to calculate the delay points.
% Usage:
%       y = my_delayPoint(mic, obj)
% Input arguments:
%       mic       : the cartesian coordinates of micphone arrays (4*3)
%       obj       : the cartesian coordinates of the input point (1*3)
% Output arguments:
%       y         : the output delay points (1*6)
% For example:
%       mic       = [0  , 0 , 0  ;
%                    0  , 0 , 0.1;
%                    0.1, 0 , 0  ;
%                    0  , 0 , 0.1];
%       delay_ref = [6,5,1.6];
%       y         = [5.4962,21.1721,17.5998,15.6759,12.1036,-3.5724];
% 说明：
%       本函数用来实现对6组时延数据的计算
%       输入：麦克风位置（直角坐标坐标），待计算点的坐标
%       输出：6组时延点数

% --------------------------------------------------------------
% 初始化
v = 340;              % 声速
fs = 48000;           % 采样率

% --------------------------------------------------------------
% 初始化距离矩阵
distance = zeros(1,4); % 声源到四个mic的距离
for k = 1:4
    discac = abs(obj-mic(k,:));
    distance(k) = sqrt(sum(discac.^2));
end

% --------------------------------------------------------------
% 初始化距离差矩阵（行序号与列序号之差）
disdiff = zeros(4,4);
for ii = 1:4
    for jj = 1:4
        if(ii==jj)
            break; % continue也可以
        else
           disdiff(ii,jj)=distance(ii)-distance(jj); 
        end      
    end
end

% --------------------------------------------------------------
% 输出结果 
disdiff_cac = [disdiff(2,1);
               disdiff(3,1);
               disdiff(4,1);
               disdiff(3,2);
               disdiff(4,2);
               disdiff(4,3)];
y = -disdiff_cac'*2/v*fs;

end