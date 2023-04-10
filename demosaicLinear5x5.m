function J = demosaicLinear5x5(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    sI = single(I);
    J = repmat(sI, [1, 1, 3]);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    K = width(opts.getKernel(2, 0, 0));  % Kernel size. Inferred.
    M = (K - 1)/2;  % Half-kernel size

    % Some padding to not go out of bounds
    padI = padarray(sI, [M + 1, M + 1], "symmetric");
    padI(M+1, :) = [];
    padI(end-M, :) = [];
    padI(:, M+1) = [];
    padI(:, end-M) = [];


    %% Build the red channel
    J(1:2:end, 2:2:end, idR) = findPixelsInPosition(padI, idR, 0, 1, opts.getKernel);
    J(2:2:end, 1:2:end, idR) = findPixelsInPosition(padI, idR, 1, 0, opts.getKernel);
    J(2:2:end, 2:2:end, idR) = findPixelsInPosition(padI, idR, 1, 1, opts.getKernel);


    %% Build the green channel
    J(1:2:end, 1:2:end, idG) = findPixelsInPosition(padI, idG, 0, 0, opts.getKernel);
    J(2:2:end, 2:2:end, idG) = findPixelsInPosition(padI, idG, 1, 1, opts.getKernel);


    %% Build the blue channel
    J(1:2:end, 1:2:end, idB) = findPixelsInPosition(padI, idB, 0, 0, opts.getKernel);
    J(1:2:end, 2:2:end, idB) = findPixelsInPosition(padI, idB, 0, 1, opts.getKernel);
    J(2:2:end, 1:2:end, idB) = findPixelsInPosition(padI, idB, 1, 0, opts.getKernel);


    %% Treat boundaries
    J = cast(J, class(I));
end

function pixels = findPixelsInPosition(sI, colorId, mr, mc, getKernel)
    pixels = convn(sI, getKernel(colorId, mr, mc), "valid");
    pixels = pixels((mr+1):2:end, (mc+1):2:end);
end