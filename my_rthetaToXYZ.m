function result = my_rthetaToXYZ(r,theta,phi)
% Note:
%       This function is used to translate the spherical coordinates to the
%       cartesian coordinates.
% Usage:
%       result = my_rthetaToXYZ(r,theta,phi)
% Input arguments:
%       r      : the polar diameter (0 to inf)
%       theta  : the pitch angle    (0 to 180)
%       phi    : the azimuth angle  (0 to 360)
% Output arguments:
%       result : the output cartesian coordinates
% For example:
%       r       = 1;
%       theta   = 90;
%       phi     = 45;
%       result  = [0.7071,0.7071,0.0000];
% 说明：
%       本函数用来实现将球坐标转换为直角坐标
%       输入：极径，俯仰角，方位角 r,theta,phi（角度值）
%       输出：直角坐标 x,y,z

% --------------------------------------------------------------
% 进行转换
angle_con = pi/180;                              % 角度制转弧度制因子
x = r*sin(theta*angle_con)*cos(phi*angle_con);   % x坐标
y = r*sin(theta*angle_con)*sin(phi*angle_con);   % y坐标
z = r*cos(theta*angle_con);                      % z坐标

% --------------------------------------------------------------
% 输出
result = [x,y,z];

end