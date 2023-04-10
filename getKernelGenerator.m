function fun = getKernelGenerator(kernels)
    assert(size(kernels, 3) == 4);
    fun = @(colorId_, mr_, mc_) getKernelInternal(colorId_, mr_, mc_, kernels);
end

function kernel = getKernelInternal(colorId, mr, mc, kernels)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    if mr == 0 && mc == 0 && colorId == idG...
            || mr == 1 && mc == 1 && colorId == idG
        kernel = kernels(:, :, 1);
    elseif mr == 0 && mc == 1 && colorId == idR...
            || mr == 1 && mc == 0 && colorId == idB
        kernel = kernels(:, :, 2);
    elseif mr == 1 && mc == 0 && colorId == idR...
            || mr == 0 && mc == 1 && colorId == idB
        kernel = kernels(:, :, 3);
    elseif mr == 0 && mc == 0 && colorId == idB...
            || mr == 1 && mc == 1 && colorId == idR
        kernel = kernels(:, :, 4);
    else
        error("Unexpected error");
    end

    % Flip for convolution
    kernel = rot90(kernel, 2);
end