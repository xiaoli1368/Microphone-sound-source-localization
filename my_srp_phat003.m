function y = my_srp_phat003(gcc_all, mic, v, fs)
% 本函数也是搜索法确定声源位置的测试，区别在于选用了球坐标
% 本函数用来实现声源定位
% 输入：GCC-PHAT矩阵，麦克风位置，声速，采样率
% 输出：声源位置
% 说明：这里主要使用直角坐标搜索+SRP-PHAT方法
% 给定搜索界限，绘图，并输出迭代界限
% 改变为极坐标

% --------------------------------------------------------------
% 搜索初始化
energycac = 0; % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2;
plotcac = []; % 用来缓存矩阵

% --------------------------------------------------------------
% 三重循环进行搜索
for r = 0.1:1:10.1                                 % 极径，分辨率为1，注意最好别从零开始
    for theta = 60*(pi/180):5*(pi/180):90*(pi/180) % 俯仰角，分辨率为2
        for phi = 0:5*(pi/180):90*(pi/180)         % 方位角，分辨率为2
            % 转换为直角坐标
            kx = r*sin(theta)*cos(phi);
            ky = r*sin(theta)*sin(phi);
            kz = r*cos(theta);
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
            % 以下这一段也先注释掉吧
%             scatter3(kx,ky,kz,'.',energysum);          
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
    if(plotcac(kk,4)>0.95*maxcac)
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
scatter3(6, 5, 1.6, 100, [0 0 1],'filled');
% % line(plotcac(:,1),plotcac(:,2),plotcac(:,2));
% plot3([0 8; 1 1],[0 8; 0 8],[1 1; 1 1]);
% view(3);
xlabel('x');
ylabel('y');
zlabel('z');

% --------------------------------------------------------------
% 伪输出
y = 0;

end