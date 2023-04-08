function J = demosaicBilinear(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    sI = single(I);
    J = repmat(sI, [1, 1, 3]);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    % Some padding to not go out of bounds
    padI = padarray(sI, [1, 1]);


    %% Build the red channel
    J(1:2:end, 1:2:end, idR) = sI(1:2:end, 1:2:end);
    J(1:2:end, 2:2:end, idR) = findPixelsInPosition(padI, idR, 0, 1);
    J(2:2:end, 1:2:end, idR) = findPixelsInPosition(padI, idR, 1, 0);
    J(2:2:end, 2:2:end, idR) = findPixelsInPosition(padI, idR, 1, 1);


    %% Build the green channel
    J(1:2:end, 1:2:end, idG) = findPixelsInPosition(padI, idG, 0, 0);
    J(1:2:end, 2:2:end, idG) = sI(1:2:end, 2:2:end);
    J(2:2:end, 1:2:end, idG) = sI(2:2:end, 1:2:end);
    J(2:2:end, 2:2:end, idG) = findPixelsInPosition(padI, idG, 1, 1);


    %% Build the blue channel
    J(1:2:end, 1:2:end, idB) = findPixelsInPosition(padI, idB, 0, 0);
    J(1:2:end, 2:2:end, idB) = findPixelsInPosition(padI, idB, 0, 1);
    J(2:2:end, 1:2:end, idB) = findPixelsInPosition(padI, idB, 1, 0);
    J(2:2:end, 2:2:end, idB) = sI(2:2:end, 2:2:end);


    %% Treat boundaries
    if ~isfield(opts, "treatBoundaries") || opts.treatBoundaries == true
        newOpts = opts;
        newOpts.treatBoundaries = false;
        newOpts.castBack = false;
        wI = demosaicBilinear(ones(size(I)), newOpts);
        J = J./wI;
    end

    if ~isfield(opts, "castBack") || opts.castBack == true
        J = cast(J, class(I));
    end
end

function kernel = getKernel(colorId, mr, mc)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    if mr == 0 && mc == 0 && colorId == idG...
            || mr == 1 && mc == 1 && colorId == idG
        kernel = [  0    1    0
                    1    0    1
                    0    1    0]/4;
    elseif mr == 0 && mc == 1 && colorId == idR...
            || mr == 1 && mc == 0 && colorId == idB
        kernel = [  0    0    0
                    1    0    1
                    0    0    0]/2;
    elseif mr == 1 && mc == 0 && colorId == idR...
            || mr == 0 && mc == 1 && colorId == idB
        kernel = [  0    1    0
                    0    0    0
                    0    1    0]/2;
    elseif mr == 0 && mc == 0 && colorId == idB...
            || mr == 1 && mc == 1 && colorId == idR
        kernel = [  1    0    1
                    0    0    0
                    1    0    1]/4;
    else
        error("Unexpected error");
    end

    % Flip for convolution
    kernel = rot90(kernel, 2);
end

function pixels = findPixelsInPosition(sI, colorId, mr, mc)
    pixels = convn(sI, getKernel(colorId, mr, mc), "valid");
    pixels = pixels((mr+1):2:end, (mc+1):2:end);
end
