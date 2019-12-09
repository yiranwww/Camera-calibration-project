%% Known RT to calculate undistorted
% with depth = 10 for x
% image 2
world_point=[];
n = length(worldPoints(:,1));
for m = 1:n
world_point(m,:) = [worldPoints(m,:), 0, 1];
end
rand('twister', 0);
randn('state', 0);

a='Load the data, it should contain X and y.';
load 'E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\calibrationX_2.mat'
X = double(X);
y = double(y);

% Load GPML
addpath(genpath('E:/study/2019spring/BuildKernel/gp-structure-search-master/source/gpml'));

% Set up model.
% depth = 10

meanfunc = {@meanZero};
hyp.mean = [];
covfunc = {@covProd, {{@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covProd, {{@covMask, {[0 1], {@covSEiso}}},...
    {@covSum, {{@covMask, {[1 0], {@covSEiso}}},...
    {@covMask, {[0 1], {@covSEiso}}}}}}}}},...
    {@covSum, {{@covMask, {[1 0], {@covLINscaleshift}}},...
    {@covProd, {{@covMask, {[0 1], {@covLINscaleshift}}},...
    {@covMask, {[0 1], {@covLINscaleshift}}}}}}}}};

hyp.cov = [-5.782750 -3257320 ...
    5.621513 -2.492121 ...
    5.750940 7.176644 ...
    -5.073249 -1.625220 ...
    -4.079710 -3.197180 ...
    -12.087710 1.721964 ...
    -.949031 0.059310];
likfunc = @likGauss;
hyp.lik = 2.17894605;


% Repeat...
[hyp_opt, nlls] = minimize(hyp, @gp, -200, @infExact, meanfunc, covfunc, likfunc, X, y);
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
 R = corrcoef(mBK,ty);
 error = mBK - ty;

 filenameY = ['E:\study\2019FALL\WeeklyReport\11.29\DataWithRotationAndTranslation\Multi-image\Pred\depth10_calibrationX_',num2str(i),'.mat'];
% %  save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','re','tool_mse','tool_rmse','tool_re','tool_R')
save(filenameY,'tx','ty','mBK','sBK','mse','rmse','R','error')
end

%% detect distanct
% [x_image x_boundary]=gp(hyp_opt, @infExact, meanfunc, covfunc, likfunc, X, y, new_image_point)
