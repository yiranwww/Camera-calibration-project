%% BK with IPhone calibration
% Lock one of the points (random select)
% with depth = 10 for x

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.'
load 'E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\ImageData\calibrationX_lock1.mat'
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covSEiso}}}}},...
    {@covSum, {{@covMask, {[0 1],{@covSEiso}}},...
    {@covProd, {{@covMask, {[0 1], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}}}};
hyp.cov = [7.511502 -5.679325 ...
    -5.869753 -9.486603 ...
    -7.073794 -0.232699 ...
    8.289594 7.194033 ...
    7.659202 4.438151 ...
    -7.657922 -16.885317 5.248964 4.127727];
likfunc = @likGauss;
hyp.lik = 12.59489717;

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
 tx = undistortedPoints_2;
 ty = imagePoints_2(:,1);
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
 filenameY = ['E:\study\2019FALL\WeeklyReport\11.8\cameraCalibration\PredData\PredOtherPoints\calibrationX_lock',num2str(i),'.mat'];
%  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','distortion','error')
end


