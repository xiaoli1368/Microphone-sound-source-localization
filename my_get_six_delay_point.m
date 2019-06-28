function y = my_get_six_delay_point(gcc_all, interPoints, interRadius)
% Note:
%       This function is used to get the six delay points from GCC-Results.
% Usage:
%       y = my_get_six_delay_point(gcc_all, interPoints, interRadius)
% Input arguments:
%       gcc_all     : the SRP response based on GCC-PHAT (6*(frameLen*2-1))
%       interPoints : the interpolation points berween every two points
%       interRadius : the chosen data radius of the original points rate
% Output arguments:
%       y           : the six delay points between two different channels (6*1)
% For example:
%       gcc_all     = ***;%
%       interPoints = 20;
%       interRadius = 20;
%       y           = [5.4286;21.1429;17.6190;15.6667;12.0952;-3.4762];
% 说明：
%       本函数用来从GCC的结果中通过插值计算六个时延点数
%       输入：GCC矩阵，每两个原始点之间的插值点数，插值半径
%       输出：6个时延点数
%       注意：主要是通过插值来获取较为精确的结果，主要是估计最大值

% --------------------------------------------------------------
% 初始化
length_gcc = size(gcc_all,2); % 确定GCC的列数
frameLen = (length_gcc+1)/2;  % 确定frameLen
delayPointMax = zeros(6,1);   % 初始化6路延时矩阵

% --------------------------------------------------------------
% 进行插值求解
for kk = 1:6
    % 先找到最大值位置
    gcc_cac = gcc_all(kk,:);
    max_index = find(gcc_cac==max(gcc_cac));
    % 这里需要进行对零点处的特殊处理
    if(max_index==frameLen)
        gcc_cac(max_index) = 0;
        max_index = find(gcc_cac==max(gcc_cac));                 % 重新寻找最大值
    end
    inputTime = (max_index-interRadius):(max_index+interRadius); % 这里直接就是点数
    inputSignal = gcc_cac(inputTime);                            % 输入的原始插值信号
    [outputSignal, outputTime] = my_sinc_vector(inputSignal, inputTime, interPoints);
    max_index2 = find(outputSignal==max(outputSignal));          % 寻找插值后的最大值索引
    delayPointMax(kk,1) = outputTime(max_index2);                % 将索引值转换为时间
end

% --------------------------------------------------------------
% 输出结果 
y = delayPointMax-frameLen;

end