function y = my_enframe_four_channels(frameLen,overLoap,x)
% Note:
%       This function is used to calculate the GCC-ALL function.
% Usage:
%       y = my_gcc_all(frameNum, frameLen, s1, s2, s3, s4)
% Input arguments:
%       frameNum : the number of frames of every channel data
%       frameLen : the length of each frame
% Output arguments:
%       y        : the GCC-PHAT function (1*(2*N-1))
% For example:
%       x1 = randn(1,2000);
%       x2 = delayseq(x1, 5e-3, 8000); % 对x1进行平移5ms，采样率为8kHz
%       y  = %%%;
% 说明：
%       本函数用来实现两路信号的GCC-PHAT的计算
%       输入：两路具有时延关系的信号（要求两信号等长）
%       输出：GCC-PHAT

% --------------------------------------------------------------
% 调用分帧函数
x1_enframe = my_enframe(x(1,:), frameLen, overLoap, 'rect'); % 暂时选择矩形窗
x2_enframe = my_enframe(x(2,:), frameLen, overLoap, 'rect');
x3_enframe = my_enframe(x(3,:), frameLen, overLoap, 'rect');
x4_enframe = my_enframe(x(4,:), frameLen, overLoap, 'rect');

% --------------------------------------------------------------
% 输出4路信号分帧后的矩阵，注意整体是一个元胞数组
y = {x1_enframe;x2_enframe;x3_enframe;x4_enframe}; 

end