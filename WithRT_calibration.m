%% Known RT to calculate undistorted
% with depth = 10 for x
% image 1
world_point=[];
n = length(worldPoints(:,1));
for m = 1:n
world_point(m,:) = [worldPoints(m,:), 0, 1];
end
rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.';
load 'E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\calibrationX_1.mat'
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
% depth = 10
%{
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum, {{@covProd, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covProd, {{@covMask,{[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}}}},...
    {@covProd, {{@covMask, {[0 1], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}};


hyp.cov = [-4.405233 -1.767120 ...
    -6.682708 -2.667332 ...
    6.837133 8.544109 ...
    8.871034 -2.723387 ...
    -11.540729 -1.564762 ...
    1.928863 -0.013591];
likfunc = @likGauss;
hyp.lik = -2.43063552;
%}
% depth = 15
%{
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum, {{@covProd, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covProd, {{@covMask,{[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}}}},...
    {@covProd, {{@covMask, {[0 1], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}};


hyp.cov = [-4.860150 -1.990346 ...
    -6.540563 -2.840742 ...
    6.977439 8.485829 ...
    8.781981 -2.781668 ...
    -2.000287 -0.009688 ...
    -1.954683 -0.724929];
likfunc = @likGauss;
hyp.lik = -2.14281019;
%}
% depth = 20
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum, {{@covProd, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covSum, {{@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}}}},...
    {@covProd, {{@covMask, {[0 1], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}};


hyp.cov = [-5.156035 -2.236278 ...
    -6.625657 -3.053853 ...
    -4.181956 -0.136049 ...
    7.075458 8.648986 ...
    8.355811 -2.618511 ...
    -1.876213 -0.437832 ...
    -1.875484 -0.431557];
likfunc = @likGauss;
hyp.lik = -2.39524116


% Repeat...
[hyp_opt, nlls] = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% ...optimisation - hopefully restarting optimiser will make it more robust to scale issues
[hyp_opt, nlls_2] = minimize(hyp_opt, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% nlls = [nlls_1; nlls_2];
best_nll = nlls(end)


%% getting pred results in x
POO=[];
for i = 1:10
rotationMatrix = cameraParams.RotationMatrices(:,:,i);
translationVector =  cameraParams.TranslationVectors(i,:);
IntrinsicMatrix = cameraParams.IntrinsicMatrix;
FocalLength = cameraParams.FocalLength;
PrincipalPoint = cameraParams.PrincipalPoint;
[RT] = [rotationMatrix;
    translationVector];
original_image_point = imagePoints(:,:,i);
POO(:,:,i) = world_point * [RT];
tx =  bsxfun(@rdivide, POO(:, 1:2,i), POO(:, 3,i));
undistorted_image_point = undistortPoints(imagePoints(:,:,i), cameraParams);
ty = undistorted_image_point(:,1);
 n=length(ty);
 [mBK sBK]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, tx);
 mse = (1/n)*(mBK-ty)'*(mBK-ty)
 rmse = sqrt((1/n)*(mBK-ty)'*(mBK-ty))
 R = corrcoef(mBK,ty)
 error = mBK - ty;

 filenameY = ['E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\2Dresult\depth20_calibrationX_',num2str(i),'.mat'];
% %  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','error')
end

%% detect distanct
% [x_image x_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)
