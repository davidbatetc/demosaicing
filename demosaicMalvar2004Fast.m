function J = demosaicMalvar2004Fast(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    h = height(I);
    w = width(I);

    sI = single(I);
    J = repmat(sI, [1, 1, 3]);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    K = 5;  % Kernel size. Hardcoded.
    M = (K - 1)/2;  % Half-kernel size

    % Some padding to not go out of bounds
    padI = padarray(sI, [M, M]);


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
    % Vertices stored for later use, since they will be overwritten
    tlJ = J(1:M, 1:M, :);
    blJ = J(end-(M-1):end, 1:M, :);
    trJ = J(1:M, end-(M-1):end, :);
    brJ = J(end-(M-1):end, end-(M-1):end, :);

    % Edges
    J(1:M, :, :) = getBoundaryWeights("top", h, w).*J(1:M, :, :);
    J(end-(M-1):end, :, :) = getBoundaryWeights("bottom", h, w).*J(end-(M-1):end, :, :);
    J(:, 1:M, :) = getBoundaryWeights("left", h, w).*J(:, 1:M, :);
    J(:, end-(M-1):end, :) = getBoundaryWeights("right", h, w).*J(:, end-(M-1):end, :);

    % Vertices
    J(1:M, 1:M, :) = getBoundaryWeights("top-left", h, w).*tlJ;
    J(end-(M-1):end, 1:M, :) = getBoundaryWeights("bottom-left", h, w).*blJ;
    J(1:M, end-(M-1):end, :) = getBoundaryWeights("top-right", h, w).*trJ;
    J(end-(M-1):end, end-(M-1):end, :) = getBoundaryWeights("bottom-right", h, w).*brJ;

    J = cast(J, class(I));
end

function kernel = getKernel(colorId, mr, mc)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    if mr == 0 && mc == 0 && colorId == idG...
            || mr == 1 && mc == 1 && colorId == idG
        kernel = [  0    0   -1    0    0
                    0    0    2    0    0
                   -1    2    4    2   -1
                    0    0    2    0    0
                    0    0   -1    0    0]/8;
    elseif mr == 0 && mc == 1 && colorId == idR...
            || mr == 1 && mc == 0 && colorId == idB
        kernel = [  0    0  0.5    0    0
                    0   -1    0   -1    0
                   -1    4    5    4   -1
                    0   -1    0   -1    0
                    0    0  0.5    0    0]/8;
    elseif mr == 1 && mc == 0 && colorId == idR...
            || mr == 0 && mc == 1 && colorId == idB
        kernel = [  0    0   -1    0    0
                    0   -1    4   -1    0
                  0.5    0    5    0  0.5
                    0   -1    4   -1    0
                    0    0   -1    0    0]/8;
    elseif mr == 0 && mc == 0 && colorId == idB...
            || mr == 1 && mc == 1 && colorId == idR
        kernel = [  0    0 -1.5    0    0
                     0    2    0    2    0
                  -1.5    0    6    0 -1.5
                     0    2    0    2    0
                     0    0 -1.5    0    0]/8;
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

function lostWeightsSum = getLostWeightSum(position, colorId, mr, mc)
    kernel = getKernel(colorId, mr, mc);
    K = width(kernel);
    assert(K == height(kernel), "Unexpected error.");

    M = (K - 1)/2;
    if strcmp(position, "top")
        lostWeightsSum = sum(kernel(1:M, :), "all");
    elseif strcmp(position, "bottom")
        lostWeightsSum = sum(kernel(end-(M-1):end, :), "all");
    elseif strcmp(position, "left")
        lostWeightsSum = sum(kernel(:, 1:M), "all");
    elseif strcmp(position, "right")
        lostWeightsSum = sum(kernel(:, end-(M-1):end), "all");
    elseif strcmp(position, "top-left")
        lostWeightsSum = getLostWeightSum("top", colorId, mr, mc)...
            + getLostWeightSum("left", colorId, mr, mc)...
            - sum(kernel(1:M, 1:M), "all");
    elseif strcmp(position, "bottom-left")
        lostWeightsSum = getLostWeightSum("bottom", colorId, mr, mc)...
            + getLostWeightSum("left", colorId, mr, mc)...
            - sum(kernel(end-(M-1):end, 1:M), "all");
    elseif strcmp(position, "top-right")
        lostWeightsSum = getLostWeightSum("top", colorId, mr, mc)...
            + getLostWeightSum("right", colorId, mr, mc)...
            - sum(kernel(1:M, end-(M-1):end), "all");
    elseif strcmp(position, "bottom-right")
        lostWeightsSum = getLostWeightSum("bottom", colorId, mr, mc)...
            + getLostWeightSum("right", colorId, mr, mc)...
            - sum(kernel(end-(M-1):end, end-(M-1):end), "all");
    else
        error("Unexpected error");
    end

    assert(numel(lostWeightsSum) == 1, "Unexpected error.");
end

function boundaryWeights = getBoundaryWeights(position, h, w)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    K = 5;  % Kernel size. Hardcoded.
    M = (K - 1)/2;  % Half-kernel size

    %% Lost weights for each position
    % red
    r01 = getLostWeightSum(position, idR, 0, 1);
    r10 = getLostWeightSum(position, idR, 1, 0);
    r11 = getLostWeightSum(position, idR, 1, 1);

    % green
    g00 = getLostWeightSum(position, idG, 0, 0);
    g11 = getLostWeightSum(position, idG, 1, 1);

    % blue
    b00 = getLostWeightSum(position, idB, 0, 0);
    b01 = getLostWeightSum(position, idB, 0, 1);
    b10 = getLostWeightSum(position, idB, 1, 0);

    % Relative starting indices
    row0 = 1;
    row1 = 2;
    col0 = 1;
    col1 = 2;

    if strcmp(position, "top")
        lostWeightsSum = zeros([M, w, 3], "single");
    elseif strcmp(position, "bottom")
        lostWeightsSum = zeros([M, w, 3], "single");
        if mod(h, 2) == 0
            row0 = 2;
            row1 = 1;
        end
    elseif strcmp(position, "left")
        lostWeightsSum = zeros([h, M, 3], "single");
    elseif strcmp(position, "right")
        lostWeightsSum = zeros([h, M, 3], "single");
        if mod(w, 2) == 0
            col0 = 2;
            col1 = 1;
        end
    else
        lostWeightsSum = zeros([M, M, 3], "single");
        if strcmp(position, "top-left")
            % All good, nothing needed
        end
        if strcmp(position, "bottom-left")...
                || strcmp(position, "bottom-right")
            if mod(h, 2) == 0
                row0 = 2;
                row1 = 1;
            end
        end
        if strcmp(position, "top-right")...
                || strcmp(position, "bottom-right")
            if mod(w, 2) == 0
                col0 = 2;
                col1 = 1;
            end
        end
    end

    % Red
    lostWeightsSum(row0:2:end, col1:2:end, idR) = r01;
    lostWeightsSum(row1:2:end, col0:2:end, idR) = r10;
    lostWeightsSum(row1:2:end, col1:2:end, idR) = r11;

    % Green
    lostWeightsSum(row0:2:end, col0:2:end, idG) = g00;
    lostWeightsSum(row1:2:end, col1:2:end, idG) = g11;

    % Blue
    lostWeightsSum(row0:2:end, col0:2:end, idB) = b00;
    lostWeightsSum(row0:2:end, col1:2:end, idB) = b01;
    lostWeightsSum(row1:2:end, col0:2:end, idB) = b10;

    boundaryWeights = 1./(1 - lostWeightsSum);
end