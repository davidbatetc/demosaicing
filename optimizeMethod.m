clear;
close;


%%
n_images = 24;
Is = zeros([512, 768, 3, n_images], "uint8");

for idx = 1:n_images
    imPath = sprintf("data/kodak/kodim%02i.png", idx);

    I = imread(imPath);

    if height(I) > width(I)
        I = rot90(I);
    end

    Is(:, :, :, idx) = I;
end

N = 5;

f = @(s_) -costFunctionLinear5x5(Is, N, s_);
sStar = fminbnd(f, 0.1, 1.0);
weightsSigma = sStar

fprintf("psnr: %.2f\n", f(sStar));
