function [y, m] = my_sinc_vector(x, n, num)
% Note:
%       This function is used to realize 'Sinc interpolation'.
% Usage:
%       [y, n] = my_sinc_vector(x, n, number)
% Input arguments:
%       x   : the original signal (1*N)
%       n   : the original time axis (1*N)
%       num : the number of interpolation points between two original points.
% Output arguments:
%       y   : the output signal (about 1*N*number)
%       m   : the output time axis (about 1*N*number)
% For example:
%       x   = sin(1:10);
%       n   = 1:10;
%       num = 5;
%       [y, m] = my_sinc_vector(x, n, num);
%       plot(n,x,'-o','linewidth',2);
%       hold on;
%       stem(m,y);
% 说明：
%       本函数用来实现sinc插值
%       输入：原始信号，原始信号对应时间轴（点数），原始两点之间新插入的点数
%       输出：插值后信号，插值后时间轴
%       注意：这个函数返回的是一组向量（包括信号向量、时间向量）

% --------------------------------------------------------------
% 初始化
N = length(n)+num*(length(n)-1); % 总点数
y = zeros(1,N);                  % 输出信号矢量
m = zeros(1,N);                  % 输出时间矢量

% --------------------------------------------------------------
% 进行插值
for ii = 1:N
    if(mod(ii,num+1)==1)                  % 如果刚好取到
        y(ii) = x(ceil(ii/(num+1)));
        m(ii) = n(ceil(ii/(num+1)));
    else                                  % 如果没有取到
        y_cac = 0;                        % 累加变量
        m_before = n(ceil(ii/(num+1)));   % 当前插值点之前的原始时间位置
        m_back = n(ceil(ii/(num+1))+1);   % 当前插值点之后的原始时间位置
        dt = (m_back-m_before)/(num+1);   % 该插值区间的分辨率
        m_cac = m_before+dt*(ii-(num+1)*(ceil(ii/(num+1)-1))-1); % 新的插值点对应的时间位置
        for jj = 1:length(n)
            y_cac = y_cac + x(jj)*sin((m_cac-n(jj))*pi)/((m_cac-n(jj))*pi); % 进行sinc插值累加
        end
        y(ii) = y_cac; % 信号赋值
        m(ii) = m_cac; % 时间赋值
    end
end

end