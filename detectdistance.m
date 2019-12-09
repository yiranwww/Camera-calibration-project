%% detect the distanct in world frame
% generate some points not from the checkboard
% In image 1 E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\OriginalPics\IPhone15mm\IMG_1450.JPG
new_world_point = [0,0;
    0,105;
    210,105;
    210,0];
% new_world_point = [-15, -15;
%     -15, 120;
%     225, 120;
%     225,-15];
% new_world_point = [10,13;
%     10,15;
%     10,20];
zCoord = zeros(size(new_world_point,1),1);
new_world_point = [new_world_point zCoord];
rotationMatrix = cameraParams.RotationMatrices(:,:,1);
translationVector =  cameraParams.TranslationVectors(1,:);
new_image_point = worldToImage(cameraParams,rotationMatrix,translationVector,new_world_point)
new_image_point = undistortPoints(new_image_point,cameraParams); % ideal distance
%% detect distanct
% with depth = 10 for x

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.';
load 'E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_1.mat';
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}},...
    {@covSum, {{@covMask, {[0 1],  {@covSEiso}}},...
    {@covMask, {[0 1], {@covPeriodic}}}}},...
    {@covSum, {{@covMask, {[0 1], {@covSEiso}}}, ...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}}, ...
    {@covSum, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covPeriodic}}}}}}}}}}};
hyp.cov = [7.437580 -5.283175 ...
    12.850806 -8.036269 ...
    7.697941 -3.519437 ...
    9.281118 10.518702 ...
    7.520154 8.860771 6.041065 ...
    13.529060 13.302327 ...
    -2.001155 -17.072010 ...
    -12.672332 -5.723075 ...
    9.105268 6.790992 9.821889];
likfunc = @likGauss;
hyp.lik = -9.68240985;

% Repeat...
[hyp_opt, nlls] = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% ...optimisation - hopefully restarting optimiser will make it more robust to scale issues
[hyp_opt, nlls_2] = minimize(hyp_opt, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% nlls = [nlls_1; nlls_2];
best_nll = nlls(end);

[x_image x_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)

%% detect distanct
% BK with IPhone calibration
% with depth = 10 for y

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.';
load 'E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationY_1.mat';
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum, {{@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[1 0], {@covPeriodic}}},...
    {@covMask, {[0 1], {@covSEiso}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covPeriodic}}},...
    {@covSum, {{@covMask, {[0 1], {@covSEiso}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}}}};
hyp.cov = [1.873156 -0.606189 ...
    9.101003 9.518756 3.034777 ...
    -7.886446 -9.183542 ...
    -3.929146 18.372290 ...
    7.449570 2.099513 ...
    8.222885 10.647207 -1.189599 ...
    7.292757 5.064966 ...
    -1.99990 2.756369];
likfunc = @likGauss;
hyp.lik = -16.24954384;

% Repeat...
[hyp_opt, nlls] = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% ...optimisation - hopefully restarting optimiser will make it more robust to scale issues
[hyp_opt, nlls_2] = minimize(hyp_opt, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% nlls = [nlls_1; nlls_2];
best_nll = nlls(end);

[y_image y_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point);

dis_image_point_GP = [x_image y_image];
dis_world_point_GP = pointsToWorld(cameraParams,rotationMatrix,translationVector, dis_image_point_GP);
h = dis_world_point_GP(2,:) - dis_world_point_GP(1,:);
HeightInMillimeters = hypot(h(1), h(2))
w = dis_world_point_GP(3,:) - dis_world_point_GP(2,:)
WeithINMilimeters = hypot(w(1), w(2))