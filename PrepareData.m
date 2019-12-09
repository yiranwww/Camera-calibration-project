%% after "E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\IPhone_30mm.m"
m = 11
% collect the undistorted point
for i = 1:m
    imagePointsData = imagePoints(:,:,i);
    undistortedPointsData = undistortPoints(imagePointsData,cameraParams);
    % Divide into x and y part
    tx = undistortedPointsData;
    ty_x = imagePointsData(:,1);
    ty_y = imagePointsData(:,2);
    n=length(ty_x); 
    X = tx;
    filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_',num2str(i),'.mat'];
    y = ty_x;
    save(filenameX,'X', 'y')
    filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationY_',num2str(i),'.mat'];
    y = ty_y;
    save(filenameY,'X','y')
end

%% collect point data without the whole image (lock 1)
for i = 1:m
    num = 120*rand(1)+1;
    num = round(num)
    imagePointsData = imagePoints(:,:,i);
    undistortedPointsData = undistortPoints(imagePointsData,cameraParams);
    % Divide into x and y part
    tx = undistortedPointsData;
    ty_x = imagePointsData(:,1);
    ty_y = imagePointsData(:,2);
    tx(num,:)=[];
    ty_x(num,:)=[];
    ty_y(num,:)=[];
    X = tx;
    filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_lock',num2str(i),'.mat'];
    y = ty_x;
    save(filenameX,'X', 'y')
    filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationY_lock',num2str(i),'.mat'];
    y = ty_y;
    save(filenameY,'X','y')
    
end

%% collect point data without 5 random points
for i = 1:m
    num1 = 120*rand(1)+1;
    num1 = round(num1);
    num2 = 119*rand(1)+1;
    num2 = round(num2);
    num3 = 118*rand(1)+1;
    num3 = round(num3);
    num4 = 117*rand(1)+1;
    num4 = round(num4);
    num5 = 116*rand(1)+1;
    num5 = round(num5);
    imagePointsData = imagePoints(:,:,i);
    undistortedPointsData = undistortPoints(imagePointsData,cameraParams);
    % Divide into x and y part
    tx = undistortedPointsData;
    ty_x = imagePointsData(:,1);
    ty_y = imagePointsData(:,2);
    tx(num1,:)=[]; tx(num2,:)=[]; tx(num3,:)=[]; tx(num4,:)=[]; tx(num5,:)=[];
    ty_x(num1,:)=[];ty_x(num2,:)=[];ty_x(num3,:)=[];ty_x(num4,:)=[];ty_x(num5,:)=[];
    ty_y(num1,:)=[];ty_y(num2,:)=[];ty_y(num3,:)=[];ty_y(num4,:)=[];ty_y(num5,:)=[];
    X = tx;
    filenameX = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_5_lock',num2str(i),'.mat'];
    y = ty_x;
    save(filenameX,'X', 'y')
    filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationY_5_lock',num2str(i),'.mat'];
    y = ty_y;
    save(filenameY,'X','y')
    
end

%% generate some points not from the checkboard
% In image 1 E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\OriginalPics\IPhone15mm\IMG_1450.JPG
new_world_point = [0,0;
    0,105;
    210,105;
    210,0;
zCoord = zeros(size(new_world_point,1),1);
new_world_point = [new_world_point zCoord];
rotationMatrix = cameraParams.RotationMatrices(:,:,1);
translationVector =  cameraParams.TranslationVectors(:,1);
new_image_point = worldToImage(cameraParams,rotationMatrix,translationVector,new_world_point)
