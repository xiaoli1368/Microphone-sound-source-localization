function y = my_srp_phat004(gcc_all, mic2, v, fs)
% 本函数用来实现声源定位（也是一个测试版）
% 输入：GCC-PHAT矩阵，麦克风位置（球坐标），声速，采样率
% 输出：声源位置
% 说明：这里主要使用直角坐标搜索+SRP-PHAT方法
% 给定搜索界限，绘图，并输出迭代界限
% 改变为极坐标

% --------------------------------------------------------------
% 搜索初始化
energycac = 0; % 用于判决的阈值
frameLen = (size(gcc_all,2)+1)/2;
plotcac = [];  % 用来缓存矩阵
srpangle = [];
d_theta = 10;  % theta分辨率，10度
d_phi = 10;    % phi分辨率，10度

% --------------------------------------------------------------
% 进行三重循环
for theta = 60:d_theta:90  % 俯仰角
    for phi = 0:d_phi:90   % 方位角       
        response_cac = 0;
        for r = 0.1:1:10.1 % 极径（注意最好别从零开始）
            % 计算距离
            distance1 = my_distancediff([r,theta,phi],mic2(1,:)); % 目标到1号麦克风距离
            distance2 = my_distancediff([r,theta,phi],mic2(2,:)); % 目标到2号麦克风距离
            distance3 = my_distancediff([r,theta,phi],mic2(3,:)); % 目标到3号麦克风距离
            distance4 = my_distancediff([r,theta,phi],mic2(4,:)); % 目标到4号麦克风距离           
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
            % 转换回直角坐标并存储
            plotcac = [plotcac;[my_rthetaToXYZ(r,theta,phi),energysum]]; % kx,ky,kz   
            % 存储该方向的10个SRP的响应和
            response_cac = response_cac+energysum;
        end
        srpangle = [srpangle;[theta,phi,response_cac]];
    end
end

% --------------------------------------------------------------
% 查看每个方向上的不同距离的响应之和
disp(srpangle);

% --------------------------------------------------------------
% 进行上色处理，并绘图
maxcac = max(plotcac(:,4));
for kk = 1:size(plotcac,1)
    if(plotcac(kk,4)>0.95*maxcac)
        plotcac(kk,5:7) = plotcac(kk,4)/maxcac*[1 0 0];
    else
        plotcac(kk,5:7) = plotcac(kk,4)/maxcac*[0 1 0];
    end   
end
figure;
scatter3(plotcac(:,1),...
         plotcac(:,2),...
         plotcac(:,3),...
         plotcac(:,4)*2,...
         plotcac(:,5:7),...
         'filled');
grid on;
% hold on;
% scatter3(6, 5, 1.6, 100, [0 0 1],'filled');
% hold on;
% % % line(plotcac(:,1),plotcac(:,2),plotcac(:,2));
% plot3([0 8; 1 1],[0 8; 0 8],[1 1; 1 1]);
% % view(3);
xlabel('x');
ylabel('y');
zlabel('z');

% --------------------------------------------------------------
% 伪输出
y = 0;

end