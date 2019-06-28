function y = my_sinc(x, n, t)
% Note:
%       This function is used to realize 'Sinc interpolation'.
% Usage:
%       y = my_sinc(x, n, t)
% Input arguments:
%       x : the original signal (1*N)
%       n : the original time axis (1*N)
%       t : the moment you want to do 'Sinc interpolation'
% Output arguments:
%       y : the value of the 't' moment
% For example:
%       x = sin(1:10);
%       n = 1:10;
%       t = 7.5;
%       y = 0.8960;
% 说明：
%       本函数用来实现sinc插值
%       输入：原始信号，原始信号对应时间轴（点数），插值时间点（小数点数）
%       输出：插值处信号大小
%       注意：这个函数返回的是一个数

% --------------------------------------------------------------
if(~isempty(find(n == t, 1))) % 确定插值点是否已经存在
    y = x(find(n == t, 1));
else
    y = 0;          % 累加缓存
    N = length(x);  % 信号长度
    for kk = 1:N
        y = y + x(kk)*sin((t-n(kk))*pi)/((t-n(kk))*pi); % 进行sinc插值累加
    end
end

end