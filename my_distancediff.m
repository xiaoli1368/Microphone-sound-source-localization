function y = my_distancediff(a, b)
% Note:
%       This function is used to calculate the distance between two points in spherical coordinates.
% Usage:
%       y = my_distancediff(a, b)
% Input arguments:
%       a : the spherical coordinates of the first point  (1*3)
%       b : the spherical coordinates of the second point (1*3)
% Output arguments:
%       y : the distance
% For example:
%       a = [1, 0 , 90];
%       b = [1, 90, 90];
%       y = 1.414;
% 说明：
%       本函数用来计算球坐标下两点的距离
%       输入：a，b均为1*3向量，即两组球坐标：r,theta,phi(角度值，非弧度制)
%       输出：距离

% --------------------------------------------------------------
% 数据处理
r1 = a(1);
theta1 = a(2)/180*pi; % theta1转换为弧度制
phi1 = a(3)/180*pi;   % phi1转换为弧度制
r2 = b(1);
theta2 = b(2)/180*pi; % theta2转换为弧度制
phi2 = b(3)/180*pi;   % phi2转换为弧度制
% --------------------------------------------------------------
% 按照公式计算
y = sqrt(r1^2+r2^2-2*r1*r2*(sin(theta1)*sin(theta2)*cos(phi1-phi2)+cos(theta1)*cos(theta2)));

end