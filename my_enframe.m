function y = my_enframe(x, frameLen, overloap, win)
% Note:
%       This function is used to realize 'framing'.
% Usage:
%       y = my_enframe(x, frameLen, overloap, win)
% Input arguments:
%       x         : the input signal (1*N)
%       frameLen  : the lenth of a frame
%       overtloap : the overloap between two frames
%       win       : the type of window function: 'rect', 'hanning', 'hamming'
% Output arguments:
%       y         : the output signal (M1*M2)
% For example:
%       x        = randn(1,1e4);
%       frameLen = 1200;
%       overloap = 400;
%       win      = 'rect';
%       y        = %%%;
% 说明：
%       本函数用来实现分帧
%       输入：原始信号（行矢量），帧长（点数），重叠（点数），窗函数类型
%       输出：分帧后的信号，每一帧占据一行
%       注意：本函数丢弃了最后不满一帧的数据

% --------------------------------------------------------------
% 初始化
N = length(x);                            % 信号长度
stepLen = frameLen - overloap;            % 步进长度
frameNum = floor((N - overloap)/stepLen); % 帧数
y = zeros(frameNum, frameLen);            % 输出矩阵
n = 1:frameLen;
switch win
    case 'hanning'
        window = 0.5 - 0.5*cos(2*pi*n/frameLen);
    case 'hamming'
        window = 0.54 - 0.46*cos(2*pi*n/frameLen);
    otherwise
        window = ones(1, frameLen);
end

% --------------------------------------------------------------
% 进行分帧
for kk = 1:frameNum % 获取下标索引数组接口
    startIndex = 1+(kk-1)*stepLen;       % 每一帧开始的索引
    endIndex = startIndex+frameLen-1;    % 每一帧结束的索引
    y(kk,:) = x(startIndex:endIndex).*window;
end

end