function kernels = findDemosaicKernels(N, weightsSigma)
    assert(N >= 5);
    assert(mod(N, 2) == 1);
    assert(weightsSigma > 0);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    tol = 1e-6;
    isSameMatrix = @(A_, B_) all(abs(A_ - B_) < tol, "all");

    kernel00G = findDemosaicKernel(N, weightsSigma, 0, 0, idG);
    kernel11G = findDemosaicKernel(N, weightsSigma, 1, 1, idG);
    assert(isSameMatrix(kernel00G, kernel11G));

    kernel01R = findDemosaicKernel(N, weightsSigma, 0, 1, idR);
    kernel10B = findDemosaicKernel(N, weightsSigma, 1, 0, idB);
    assert(isSameMatrix(kernel01R, kernel10B));

    kernel10R = findDemosaicKernel(N, weightsSigma, 1, 0, idR);
    kernel01B = findDemosaicKernel(N, weightsSigma, 0, 1, idB);
    assert(isSameMatrix(kernel10R, kernel01B));

    kernel00B = findDemosaicKernel(N, weightsSigma, 0, 0, idB);
    kernel11R = findDemosaicKernel(N, weightsSigma, 1, 1, idR);
    assert(isSameMatrix(kernel00B, kernel11R));

    kernels = zeros([N, N, 4], "single");
    kernels(:, :, 1) = kernel00G;
    kernels(:, :, 2) = kernel01R;
    kernels(:, :, 3) = kernel10R;
    kernels(:, :, 4) = kernel00B;
end

function kernel = findDemosaicKernel(N, weightsSigma, mr, mc, colorId)
    nchoose2 = @(n_) n_*(n_ + 1)/2;
    orderLum = 3;
    orderC1 = 1;
    orderC2 = 1;
    colsM = nchoose2(orderLum + 1)...
        + nchoose2(orderC1 + 1)...
        + nchoose2(orderC2 + 1);

    M = zeros([N*N, colsM], "single");
    L = zeros([1, colsM], "single");

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

    gauss1d = exp(-0.5*(linspace(-1, 1, N)'/weightsSigma).^2);
    gauss1d = gauss1d/sum(gauss1d, "all");
    w = gauss1d*gauss1d';

    Mtilde = M*pinv(M'.*w(:)'*M);  % No weights for now
    kernel = reshape(L*(Mtilde'.*w(:)'), [N, N]);
end
