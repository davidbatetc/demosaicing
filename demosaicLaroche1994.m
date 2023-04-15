function J = demosaicLaroche1994(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    sI = single(I);
    J = repmat(sI, [1, 1, 3]);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    % Padded for 3x3
    padI3 = padarray(sI, [2, 2], "symmetric");
    padI3(2, :) = [];
    padI3(end-1, :) = [];
    padI3(:, 2) = [];
    padI3(:, end-1) = [];

    % Padded for 5x5
    padI5 = padarray(sI, [3, 3], "symmetric");
    padI5(3, :) = [];
    padI5(end-2, :) = [];
    padI5(:, 3) = [];
    padI5(:, end-2) = [];


    %% First compute the green channel
    kernelAlpha = [  0    0    0
                     1   -2    1
                     0    0    0]/2;
    kernelBeta = [  0    1    0
                    0   -2    0
                    0    1    0]/2;

    alphaBetaThreshold = 8;  % Arbitrary

    % In red/blue positions
    for m = 0:1
        alpha = abs(convn(padI5((m+1):2:end, (m+1):2:end), kernelAlpha, "valid"));
        beta = abs(convn(padI5((m+1):2:end, (m+1):2:end), kernelBeta, "valid"));

        greenV = estimateColor(padI3, "vertical", m, m);
        greenH = estimateColor(padI3, "horizontal", m, m);
        greenCross = estimateColor(padI3, "plus", m, m);

        greenInM = zeros(size(alpha), "single");
        greenInM(alpha > beta) = greenV(alpha > beta);
        greenInM(alpha < beta) = greenH(alpha < beta);
        greenInM((alpha - beta) <= alphaBetaThreshold)...
            = greenCross((alpha - beta) <= alphaBetaThreshold);

        J((m+1):2:end, (m+1):2:end, idG) = greenInM;
    end


    %% Then compute the red and green channels
    Crb = sI - J(:, :, idG);
    paddCrb = padarray(Crb, [1, 1], "symmetric");

    % First the red channel
    J(1:2:end, 2:2:end, idR) = estimateColor(paddCrb, "horizontal", 0, 1)...
        + J(1:2:end, 2:2:end, idG);
    J(2:2:end, 1:2:end, idR) = estimateColor(paddCrb, "vertical", 1, 0)...
        + J(2:2:end, 1:2:end, idG);
    J(2:2:end, 2:2:end, idR) = estimateColor(paddCrb, "cross", 1, 1)...
        + J(2:2:end, 2:2:end, idG);

    % Then the blue channel
    J(1:2:end, 1:2:end, idB) = estimateColor(paddCrb, "cross", 0, 0)...
        + J(1:2:end, 1:2:end, idG);
    J(1:2:end, 2:2:end, idB) = estimateColor(paddCrb, "vertical", 0, 1)...
        + J(1:2:end, 2:2:end, idG);
    J(2:2:end, 1:2:end, idB) = estimateColor(paddCrb, "horizontal", 1, 0)...
        + J(2:2:end, 1:2:end, idG);

    J = cast(round(J), class(I));
end

function estG = estimateColor(sI, kernelType, mr, mc)
    kernel = getKernel(kernelType);
    estG = convn(sI, kernel, "valid");
    estG = estG((mr+1):2:end, (mc+1):2:end);
end

function kernel = getKernel(kernelType)
    if strcmp(kernelType, "vertical")
        kernel = [  0    1    0
                    0    0    0
                    0    1    0]/2;
    elseif strcmp(kernelType, "horizontal")
        kernel = [  0    0    0
                    1    0    1
                    0    0    0]/2;
    elseif strcmp(kernelType, "plus")
        kernel = [  0    1    0
                    1    0    1
                    0    1    0]/4;
    elseif strcmp(kernelType, "cross")
        kernel = [  1    0    1
                    0    0    0
                    1    0    1]/4;
    end
end
