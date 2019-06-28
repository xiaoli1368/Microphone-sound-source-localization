function y = my_gcc_all(frameNum, frameLen, s_ideal_enframe)
% Note:
%       This function is used to calculate the GCC-ALL function.
% Usage:
%       y = my_gcc_all(frameNum, frameLen, s1, s2, s3, s4)
% Input arguments:
%       frameNum        : the number of frames of every channel data
%       frameLen        : the length of each frame
%       s_ideal_enframe : the input signal (4*1: {s1;s2;s3;s4})
% Output arguments:
%       y               : the xcorr between two channels (6*1: [x12;x13...])
% For example:
%       frameNum         = 161;
%       fremeLen         = 1200;
%       s_ideal_enframe  = %%%;
% 说明：
%       本函数用来实现两路信号的GCC-PHAT的计算
%       输入：帧数，帧长，4路信号完成分帧之后的元胞数组
%       输出：gcc_all矩阵（6行，每一行是一组信号对的GCC）

% --------------------------------------------------------------
% 初始化
s1 = s_ideal_enframe{1};
s2 = s_ideal_enframe{2};
s3 = s_ideal_enframe{3};
s4 = s_ideal_enframe{4};
xcorrCac12 = zeros(frameNum, 2*frameLen - 1);
xcorrCac13 = zeros(frameNum, 2*frameLen - 1);
xcorrCac14 = zeros(frameNum, 2*frameLen - 1);
xcorrCac23 = zeros(frameNum, 2*frameLen - 1);
xcorrCac24 = zeros(frameNum, 2*frameLen - 1);
xcorrCac34 = zeros(frameNum, 2*frameLen - 1);

% --------------------------------------------------------------
% 调用my_gcc_phat计算两路通道的GCC
for kk = 1:frameNum
    xcorrCac12(kk, :) = my_gcc_phat(s1(kk, :), s2(kk, :));
    xcorrCac13(kk, :) = my_gcc_phat(s1(kk, :), s3(kk, :));
    xcorrCac14(kk, :) = my_gcc_phat(s1(kk, :), s4(kk, :));
    xcorrCac23(kk, :) = my_gcc_phat(s2(kk, :), s3(kk, :));
    xcorrCac24(kk, :) = my_gcc_phat(s2(kk, :), s4(kk, :));
    xcorrCac34(kk, :) = my_gcc_phat(s3(kk, :), s4(kk, :));   
end

% --------------------------------------------------------------
% 形成时延矩阵(1*Ncorr)，每个时延对应的值
xcorr12 = abs(sum(xcorrCac12));
xcorr13 = abs(sum(xcorrCac13));
xcorr14 = abs(sum(xcorrCac14));
xcorr23 = abs(sum(xcorrCac23));
xcorr24 = abs(sum(xcorrCac24));
xcorr34 = abs(sum(xcorrCac34));

% --------------------------------------------------------------
% 其它
% % 注意这里有时候需要对零延时进行特殊处理（这里需要分析）
% xcorr12(1200) = 0;
% xcorr13(1200) = 0;
% xcorr14(1200) = 0;
% xcorr23(1200) = 0;
% xcorr24(1200) = 0;
% xcorr34(1200) = 0;
% --------------------------------------------------------------
% % 作图
% figure;
% imagesc(abs(gcc_all(2,:))); % 分帧后的时延图
% ylabel('frame/nums');
% xlabel('delay/points');
% title('分帧形式下的时延图');
% figure;
% stem(xcorr13); % 整合后的时延图
% grid on;
% xlabel('delay/points');
% title('整体形式下的时延图');

% --------------------------------------------------------------
% 输出
y = [xcorr12;xcorr13;xcorr14;xcorr23;xcorr24;xcorr34]; 

end