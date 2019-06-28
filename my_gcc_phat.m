function y = my_gcc_phat(x1, x2)
% Note:
%       This function is used to calculate the GCC-PHAT function.
% Usage:
%       y = my_gcc_phat(x1, x2)
% Input arguments:
%       x1 : the input signal of first channel (1*N)
%       x2 : the input signal of second channel (1*N)
% Output arguments:
%       y  : the GCC-PHAT function (1*(2*N-1))
% For example:
%       x1 = randn(1,2000);
%       x2 = delayseq(x1, 5e-3, 8000); % 对x1进行平移5ms，采样率为8kHz
%       y  = %%%;
% 说明：
%       本函数用来实现两路信号的GCC-PHAT的计算
%       输入：两路具有时延关系的信号（要求两信号等长）
%       输出：GCC-PHAT

% --------------------------------------------------------------
% 初始化
Ncorr = 2*length(x1)-1;   % 线性互相关长度
NFFT = 2^nextpow2(Ncorr); % 计算FFT点数

% --------------------------------------------------------------
% 计算GCC-PAHT
Gss = fft(x1, NFFT).*conj(fft(x2, NFFT));                 % 计算互功率谱
% xcorr_cac = fftshift(ifft(Gss));
xcorr_cac = fftshift(ifft(exp(1i*angle(Gss))));           % 直接GCC-PHAT
y = xcorr_cac(NFFT/2+1-(Ncorr-1)/2:NFFT/2+1+(Ncorr-1)/2); % 确定索引

end