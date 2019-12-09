%% BK with IPhone calibration
% with depth = 10 for y

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.'
load 'E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationY_1.mat'
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
best_nll = nlls(end)


%% getting pred results in Y
for i = 1:11
 undistortedPoints_2 = undistortPoints(imagePoints(:,:,i),cameraParams);
 imagePoints_2=imagePoints(:,:,i);   
 tx = undistortedPoints_2;
 ty = imagePoints_2(:,2);
 n=length(ty);
 [mBK sBK]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, tx);
   ry=tx(:,2);
 mse = (1/n)*(mBK-ty)'*(mBK-ty)
 rmse = sqrt((1/n)*(mBK-ty)'*(mBK-ty))
 R = corrcoef(mBK,ty)
 distortion = mBK-ry;
 error = mBK - ty;
 
%  tool_mse = (1/n)*(ry-ty)'*(ry-ty)
%  tool_rmse = sqrt((1/n)*(ry-ty)'*(ry-ty))
%  tool_re = ry-ty;
%  tool_R = corrcoef(ry,ty)
 filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\calibrationY_',num2str(i),'.mat'];
%  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','distortion','error')
end

%% detect distanct
[y_image y_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)
