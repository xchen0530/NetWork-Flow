%######################################
%
% 2015.5.30 CX on desk
% 作用：这个脚本用于从初始分割中得到椭圆拟合假说
% 数据存储：椭圆数据保存在 raw_ellipse 中
% 依赖关系： 反复调用 CX_fit 计算每帧图片的拟合结果 
% 2015.6.5（加入了 FOI 提取，使边缘的判断符合标准 ）
%
%######################################
clear;close all;

if 0
    dataset = 'competition'; % 选择训练还是测试
else
    dataset = 'training';
end
[ segpath, ~ ] = getpath( dataset );

rawpic_dir=dir([ segpath, '\*.png' ]); % 原始tif图片地址
% 输出拟合后图片地址 
output_addr = [ segpath, '\FOI拟合图2.0\'];
if ~exist(output_addr, 'dir')
    mkdir(output_addr);
end
    
% 输出FOI内图片轮廓的地址
lunkuo_addr=[ segpath, '\FOI提取轮廓\'];
if ~exist(lunkuo_addr, 'dir')
    mkdir(lunkuo_addr);
end
    

% 从外部导入e
ellipse_address = [ output_addr, 'raw_ellipse.mat' ];
if exist(ellipse_address, 'file')
    load(ellipse_address);
else
    ellipse = cell(length(rawpic_dir),1);
end
%########## 拟合公差 移除小区域 
tolerance = 2.0;
remove_small = 25; % 移除小物体的阈值可以稍微大一点！

%% 开始循环处理图片 

for frame=1:length(rawpic_dir)
    
    iteration_num = -1;
    lunkuo = 'error';
    pic = [ segpath, '\', rawpic_dir(frame).name ];

    while strcmp(lunkuo, 'error') % 如果出错则增大滤波次数
        iteration_num = iteration_num + 1;
        if iteration_num>4
            error('滤波次数达到4次！查看具体情况');
        end
%         iteration_num = 1;
        [ ellipse{frame}, lunkuo] = CX_Fit( frame, pic, iteration_num, tolerance, remove_small);   %%不进行滤波
    end

    % 保存FOI内的轮廓，后面需要replot
    lunkuo_name = [ lunkuo_addr, rawpic_dir(frame).name ];
    imwrite(lunkuo, lunkuo_name);
    
    % 保存拟合后的figure
    disp('保存结果');
    savename = strcat(output_addr, rawpic_dir(frame).name(1:end-4), '_fit.fig');
    saveas(1, savename);  % 句柄控制
    close('1');
    save(ellipse_address, 'ellipse');
end

