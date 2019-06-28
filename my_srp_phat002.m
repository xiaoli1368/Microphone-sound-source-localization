function y = my_srp_phat002(gcc_all, mic, v, fs)
% 这个函数也是 my_srp_phat_maxFind_method 的测试版
% 区分在于，进行了画图来更加形象的进行测试
% 本函数用来实现声源定位
% 输入：GCC-PHAT矩阵，麦克风位置，声速，采样率
% 输出：声源位置（以及扫描的空间点的信息图）
% 说明：这里主要使用直角坐标搜索+SRP-PHAT方法
% 给定搜索界限，绘图，并输出迭代界限
% 主要是使用了直角坐标搜索

% --------------------------------------------------------------
% 搜索初始化
xmax = 8;
ymax = 8;
zmax = 2;
dr = 1;
energycac = 0; % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2;
plotcac = [];  % 用来缓存矩阵

% --------------------------------------------------------------
% 三重循环进行搜索
for kx = 0:dr:xmax
    for ky = 0:dr:ymax
        for kz = 0:dr:zmax
            obj = [kx,ky,kz]; % 目标位置
            % 计算距离差
            discac = abs(obj-mic(1,:));
            distance1 = sqrt(sum(discac.^2)); % 目标到1号麦克风距离
            discac = abs(obj-mic(2,:));
            distance2 = sqrt(sum(discac.^2)); % 目标到2号麦克风距离
            discac = abs(obj-mic(3,:));
            distance3 = sqrt(sum(discac.^2)); % 目标到3号麦克风距离
            discac = abs(obj-mic(4,:));
            distance4 = sqrt(sum(discac.^2)); % 目标到4号麦克风距离 
            % 计算时延点数矩阵
            delaycac = [2*(distance1-distance2)/v*fs;
                        2*(distance1-distance3)/v*fs;
                        2*(distance1-distance4)/v*fs;
                        2*(distance2-distance3)/v*fs;
                        2*(distance2-distance4)/v*fs;
                        2*(distance3-distance4)/v*fs
                       ];
            % 进行sinc加权计算SRP
            energy_xx_cac = zeros(1,6);
            for zz = 1:6
                index = frameLen+floor(delaycac(zz))+(-3:4);
                energy_xx_cac(zz) = my_sinc(gcc_all(zz,index),index,frameLen+delaycac(zz));
            end
            energysum = sum(energy_xx_cac);
            plotcac = [plotcac;[kx,ky,kz,energysum]];
            % 以下为寻找最大值部分，暂时注释掉
%             % 直接寻找最大值
%             if(energysum>energycac) % 如果找到更大的值
%                 energycac = energysum;
%                 y = obj;
%             end  
        end
    end
end

% --------------------------------------------------------------
% 进行上色处理
maxcac = max(plotcac(:,4));
for kk = 1:size(plotcac,1)
    if(plotcac(kk,4)>0.8*maxcac)
        plotcac(kk,5:7) = plotcac(kk,4)/maxcac*[1 0 0];
    else
        plotcac(kk,5:7) = plotcac(kk,4)/maxcac*[0 1 0];
    end   
end

% --------------------------------------------------------------
% 绘图
figure;
scatter3(plotcac(:,1),...
         plotcac(:,2),...
         plotcac(:,3),...
         plotcac(:,4)*2,...
         plotcac(:,5:7),...
         'filled');
grid on;
hold on;
% % line(plotcac(:,1),plotcac(:,2),plotcac(:,2));
% plot3([0 8; 1 1],[0 8; 0 8],[1 1; 1 1]); % 这里在三维空间中划了一条线
% view(3);
xlabel('x');
ylabel('y');
zlabel('z');

% --------------------------------------------------------------
% 伪输出
y = 0;

end