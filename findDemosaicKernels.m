clear;
close;
clc;


%%
I = imread("data/kodak/kodim19.png");
mI = immosaic(I, "rggb");

% Channel indices
idR = 1;
idG = 2;
idB = 3;

nchoose2 = @(n_) n_*(n_ + 1)/2;
orderLum = 3;
orderC1 = 1;
orderC2 = 1;
colsM = nchoose2(orderLum + 1)...
    + nchoose2(orderC1 + 1)...
    + nchoose2(orderC2 + 1);

N = 5;
M = zeros([N*N, colsM], "single");
L = zeros([1, colsM], "single");
mr = 0;  % Relative position in rows
mc = 0;  % Relative position in cols
colorId = idB;  % Color to be estimated

colIdx = 1;

% Luminance
for j = 0:orderLum
    for k1 = 0:j
        k2 = j - k1;
        
        f = @(t1_, t2_) polyLc1c2(t1_, t2_, [k1 k2 -1 -1 -1 -1]);
        xM = evalDemosaicT(f, N, mr, mc);
        M(:, colIdx) = xM(:);
        
        xL = evalDemosaicS(f, N, colorId);
        L(:, colIdx) = xL(:);

        colIdx = colIdx + 1;
    end
end

% Chrominance 1
for j = 0:orderC1
    for k1 = 0:j
        k2 = j - k1;

        f = @(t1_, t2_) polyLc1c2(t1_, t2_, [-1 -1 k1 k2 -1 -1]);
        xM = evalDemosaicT(f, N, mr, mc);
        M(:, colIdx) = xM(:);

        xL = evalDemosaicS(f, N, colorId);
        L(:, colIdx) = xL(:);

        colIdx = colIdx + 1;
    end
end

% Chrominance 2
for j = 0:orderC2
    for k1 = 0:j
        k2 = j - k1;

        f = @(t1_, t2_) polyLc1c2(t1_, t2_, [-1 -1 -1 -1 k1 k2]);
        xM = evalDemosaicT(f, N, mr, mc);
        M(:, colIdx) = xM(:);

        xL = evalDemosaicS(f, N, colorId);
        L(:, colIdx) = xL(:);

        colIdx = colIdx + 1;
    end
end


sigma = 0.6;
gauss1d = exp(-0.5*(linspace(-1, 1, N)'/sigma).^2);
gauss1d = gauss1d/sum(gauss1d, "all");
w = gauss1d*gauss1d';

Mtilde = M*pinv(M'.*w(:)'*M);  % No weights for now
kernel = reshape(L*(Mtilde'.*w(:)'), [5, 5])
