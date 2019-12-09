%%  calibration error analysis
X = worldPoints(:,1);
Y = worldPoints(:,2);
Error=zeros(120,11);
%% plot the total error distribution
% GP result
for i=1:11
   
   filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationX_',num2str(i),'.mat'];
% filenameX = ['E:\study\2019FALL\WeeklyReport\10.11\Calibration\IPhoneExampleCode\calibrationX_',num2str(i),'.mat'];
   load(filenameX)
   x_GP_pred = mBK;
   x_GP_boundary = sBK;
   x_toobox = ty;
   x_original = tx(:,1);
   x_error = error;
   x_distortion =distortion;
   filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationY_',num2str(i),'.mat'];
%  filenameY = ['E:\study\2019FALL\WeeklyReport\10.11\Calibration\IPhoneExampleCode\calibrationY_',num2str(i),'.mat'];
   y_GP_pred = mBK;
    y_GP_boundary = sBK;
    y_toobox = ty;
    y_original = tx(:,2);
    y_error = error;
    y_distortion = distortion;
    distortion_GP = sqrt(x_distortion.*x_distortion +y_distortion.*y_distortion);
    figure(1)
    subplot(1,2,1)
%     upper = 1;
% lower = 0;
% r_max = max(r);
% r_min = min(r);
% k = (upper - lower)/(r_max-r_min);
% nor_r = lower + k*(r-r_min);
    plot3(X, Y, distortion_GP, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none')
hold on
% K = boundary(X,Y,r,1);
% trisurf(K,X,Y,r,'FaceColor','red','FaceAlpha',0.1)
zlabel({'Distortion'});
ylabel('Y');
xlabel('X')
title('GP Prediction');
grid on

end

% matlab result
for i = 1:11
 undistortedPoints_2 = undistortPoints(imagePoints(:,:,i),cameraParams);
 imagePoints_2=imagePoints(:,:,i); 
 x_tool_distortion = imagePoints_2(:,1) - undistortedPoints_2(:,1);
  y_tool_distortion = imagePoints_2(:,2) - undistortedPoints_2(:,2);
  distortion_tool = sqrt(x_tool_distortion.*x_tool_distortion +y_tool_distortion.*y_tool_distortion);
%   [R_ideal, GPPS] = mapminmax(r_ideal,0,1);
% upper = 1;
% lower = 0;
% r_ideal_max = max(r_ideal);
% r_ideal_min = min(r_ideal);
% k_ideal = (upper - lower)/(r_ideal_max-r_ideal_min);
% nor_r_ideal = lower + k_ideal*(r_ideal-r_ideal_min);
  figure(1)
  subplot(1,2,2)
  plot3(X, Y, distortion_tool, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none')
hold on
% K = boundary(X,Y,r_ideal,1);
% trisurf(K,X,Y,r_ideal,'FaceColor','red','FaceAlpha',0.1)
zlabel('Distortion');
xlabel('X');
ylabel('Y');
grid on 
title('Toolbox Results');
end

%% plot the special error prejection
% GP-distorted/Toolbox-distorted
for i=1
   
   filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationX_',num2str(i),'.mat'];
   load(filenameX)
   x_GP_pred = mBK;
   x_GP_boundary = sBK;
   x_toobox = ty;
   x_original = tx(:,1);
   x_error = error;
   x_distortion = distortion;
   filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationY_',num2str(i),'.mat'];
   y_GP_pred = mBK;
    y_GP_boundary = sBK;
    y_toobox = ty;
    y_original = tx(:,2);
    y_error = error;
    y_distortion = distortion;
    r = sqrt(x_distortion.*x_distortion +y_distortion.*y_distortion);
    figure(3)
    subplot(2,2,1)
 plot(X,r, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none','Color','b')
hold on
xlabel('X')
ylabel('Distortion')
title('GP prediction')
subplot(2,2,3)
 plot(Y,r, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none','Color','b')
hold on
xlabel('Y')
ylabel('Distortion')
title('GP prediction');
grid on
    hold on
end
% matlab results
for i = 1
 undistortedPoints_2 = undistortPoints(imagePoints(:,:,i),cameraParams);
 imagePoints_2=imagePoints(:,:,i); 
 r_x = imagePoints_2(:,1) - undistortedPoints_2(:,1);
  r_y = imagePoints_2(:,2) - undistortedPoints_2(:,2);
  r_ideal = sqrt(r_x.*r_x +r_y.*r_y);
  figure(3)
subplot(2,2,2)
%   plot3(X, Y, r_ideal, 'MarkerSize',4,'Marker','o','LineWidth',4,...
%     'LineStyle','none')
% zlabel('Error')
 plot(X,r_ideal, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none','Color','r')
hold on
xlabel('X')
ylabel('Distortion')
title('Toolbox resluts')
subplot(2,2,4)
plot(Y, r_ideal, 'MarkerSize',4,'Marker','o','LineWidth',4,...
    'LineStyle','none','Color','r')
hold on
xlabel('Y')
ylabel('Distortion')
title('Toolbox resluts')
grid on
hold on

end


%% plot the GP pred, undistorted and distorted image of a specific image
i = 8;
undistortedPoints_2 = undistortPoints(imagePoints(:,:,i),cameraParams);
x_original = undistortedPoints_2(:,1);
y_original = undistortedPoints_2(:,2);
figure(4)
scatter(x_original,y_original,'square','r')
hold on

imagePoints_2=imagePoints(:,:,i); 
x_distorted = imagePoints_2(:,1);
y_distorted = imagePoints_2(:,2);
scatter(x_distorted, y_distorted,'o','k')

 filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationX_',num2str(i),'.mat'];
   load(filenameX)
   x_GP_pred =  mBK;
 filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationY_',num2str(i),'.mat'];
  load(filenameY)
   y_GP_pred = mBK;
   scatter(x_GP_pred, y_GP_pred,'*','b');
   legend('Distorted','Toolbox','GP')
   

