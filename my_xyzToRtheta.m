function result = my_xyzToRtheta(x,y,z)
% Note:
%       This function is used to translate the cartesian coordinates to the
%       spherical coordinates.
% Usage:
%       result = my_xyzToRtheta(x,y,z)
% Input arguments:
%       x      : the x-coordinate
%       y      : the y-coordinate
%       z      : the z-coordinate
% Output arguments:
%       result : the output spherical coordinates [r, theta, phi]
% For example:
%       x       = 0.7071;
%       y       = 0.7071;
%       z       = 0.0000;
%       result  = [1,90,45];
% 说明：
%       本函数用来实现将直角坐标转换为球坐标
%       输入：直角坐标 x,y,z
%       输出：极径，俯仰角，方位角 r,theta,phi（角度值）
%       注意：当极径为零时，角度可以有多个值，这里仅输出为零

% --------------------------------------------------------------
% 开始转换
r = sqrt(x^2+y^2+z^2);     % 计算极径
theta = acos(z/r)/pi*180;  % 计算俯仰角
phi = atan(y/x)/pi*180;    % 计算方位角
result = [r,theta,phi];    % 输出结果
result(isnan(result)) = 0; % 用来处理一些特殊情况

end