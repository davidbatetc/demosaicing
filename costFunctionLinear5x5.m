function cost = costFunctionLinear5x5(Is, N, weightsSigma, weightsAlpha, weightsDelta)
    kernels = findDemosaicKernels(N, weightsSigma, weightsAlpha, weightsDelta);
    
    opts.sensorAlignment = "rggb";
    opts.getKernel = getKernelGenerator(kernels);
    
    h = height(Is);
    w = width(Is);
    n_images = size(Is, 4);

    Js = zeros([h, w, 3, n_images], "uint8");
    for idx = 1:n_images
        mI = immosaic(Is(:, :, :, idx), opts.sensorAlignment);
        Js(:, :, :, idx) = demosaicLinear5x5(mI, opts);
    end

    cost = psnr(Js, Is);
end