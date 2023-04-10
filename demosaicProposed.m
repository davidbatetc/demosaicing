function J = demosaicProposed(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    if ~isfield(opts, "weightsSigma")
        opts.weightsSigma = 0.212443906922382;
    end

    assert(~isfield(opts, "getKernel"));

    N = 5;
    kernels = findDemosaicKernels(N, opts.weightsSigma);
    opts.getKernel = getKernelGenerator(kernels);

    J = demosaicLinear5x5(I, opts);
end
