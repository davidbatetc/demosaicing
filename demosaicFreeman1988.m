function J = demosaicFreeman1988(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;


    %% First use bilinear interpolation
    newOpts = opts;
    newOpts.castBack = false;
    J = demosaicBilinear(I, newOpts);


    %% Then median filter the differences
    Cr = J(:, :, idR) - J(:, :, idG);
    Cb = J(:, :, idB) - J(:, :, idG);

    filtCr = medfilt2(Cr, [3, 3], "symmetric");
    filtCb = medfilt2(Cb, [3, 3], "symmetric");

    J(:, :, idR) = filtCr + J(:, :, idG);
    J(1:2:end, 1:2:end, idR) = I(1:2:end, 1:2:end);
    J(:, :, idB) = filtCb + J(:, :, idG);
    J(2:2:end, 2:2:end, idB) = I(2:2:end, 2:2:end);

    J = cast(round(J), class(I));
end
