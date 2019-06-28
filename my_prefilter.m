function y = prefilter(x, lowfre, highfre, fs)
% Note:
%       This function is used to do the 'prefilter', a bandpass filter.
% Usage:
%       y = prefilter(x, lowfre, highfre, fs)
% Input arguments:
%       x       : the input signal (1*N)
%       lowfre  : the lower frequency
%       highfre : the high frequency
%       fs      : the sampling frequency
% Output arguments:
%       y       : the output signal
% For example:
%       x       = randn(1,2000);
%       lowfre  = 50;
%       highfre = 3400;
%       fs      = 48000;
%       y       = %%%;
% 说明：
%       本函数用来实现预滤波（带通滤波）
%       输入：原始信号，低频门限，高频门限，采样率
%       输出：滤波后信号

% --------------------------------------------------------------
% 设计带通滤波器
filterd=fdesign.highpass('N,Fc',50,lowfre,fs);  % 50阶的高通滤波器
filterd2=fdesign.lowpass('N,Fc',50,highfre,fs); % 50阶的低通滤波器
Hd=design(filterd);
Hd2=design(filterd2);

% --------------------------------------------------------------
% 进行滤波
y = filter(Hd,x);  % 高通滤波
y = filter(Hd2,x); % 低通滤波    

end