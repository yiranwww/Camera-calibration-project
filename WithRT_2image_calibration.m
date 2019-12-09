%% Known RT to calculate undistorted
% with depth = 10 for x
% using 2 images for training data

rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.';
load 'E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\2Image\calibrationX_2.mat'
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
% depth = 10
%{
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum,{{@covMask, {[1 0], {@covSEiso}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covSEiso}}}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covSum, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}},...
    {@covProd, {{@covMask, {[0 1], {@covSEiso}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}};
hyp.cov = [-5.952636 -0.705689 ...
    -2.675218 -2.498234 ...
    -2.265670 -0.419795 ...
    -2.600329 2.115912 ...
    7.498134 5.345323 ...
    -5.679930 -2.566373 ...
    0.801517 -2.694426 ...
    -6.765586 -2.432526 ...
    -6.547820 -3.217022];
likfunc = @likGauss;
hyp.lik = -2.45583024;
%}

% depth = 15
meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1],{@covSEiso}}}}},...
    {@covProd, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covSum, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}},...
    {@covProd, {{@covMask, {[0 1], {@covSEiso}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}};

hyp.cov = [-5.888991 -0.711574 ...
    -2.672520 -2.357910 ...
    -2.190489 -0.150270 ...
    -2.597331 2.256236 ...
    7.409823 5.066935 ...
    -5.682381 -2.763468 ...
    -3.312258 3.340127 ...
    -6.751948 -2.407846 ...
    -6.547820 -3.241702];
likfunc = @likGauss;
hyp.lik = -2.3980219;


% Repeat...
[hyp_opt, nlls] = minimize(hyp, @gp, -200, @infExact, meanfunc, covfunc, likfunc, X, y);
% ...optimisation - hopefully restarting optimiser will make it more robust to scale issues
[hyp_opt, nlls_2] = minimize(hyp_opt, @gp, -100, @infExact, meanfunc, covfunc, likfunc, X, y);
% nlls = [nlls_1; nlls_2];
best_nll = nlls(end)


%% getting pred results in x
world_point=[];
n = length(worldPoints(:,1));
for m = 1:n
world_point(m,:) = [worldPoints(m,:), 0, 1];
end
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

 filenameY = ['E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\2Image\Pred_result\depth15_calibrationX_',num2str(i),'.mat'];
% %  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','error')
end

%% detect distanct
% [x_image x_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)
