%% BK with IPhone calibration
% with depth = 10 for x

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.'
load 'E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_1.mat'
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
best_nll = nlls(end)


%% getting pred results in x
for i = 1:11
 undistortedPoints_2 = undistortPoints(imagePoints(:,:,i),cameraParams);
 imagePoints_2=imagePoints(:,:,i);   
 tx = imagePoints_2;
 ty = undistortedPoints_2(:,1);
 n=length(ty);
 [mBK sBK]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, tx);
   ry=tx(:,1);
 mse = (1/n)*(mBK-ty)'*(mBK-ty)
 rmse = sqrt((1/n)*(mBK-ty)'*(mBK-ty))
 R = corrcoef(mBK,ty)
 distortion = mBK-ry;
 error = mBK - ty;
 
%  tool_mse = (1/n)*(ry-ty)'*(ry-ty)
%  tool_rmse = sqrt((1/n)*(ry-ty)'*(ry-ty))
%  tool_re = ry-ty;
%  tool_R = corrcoef(ry,ty)
 filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\WholePoints\NEWcalibrationX_',num2str(i),'.mat'];
%  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','distortion','error')
end

%% detect distanct
[x_image x_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)
