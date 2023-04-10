function x = evalDemosaicS(f, N, colorId)
    assert(mod(N, 2) == 1);

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    [t2, t1] = meshgrid(linspace(-1, 1, N), linspace(-1, 1, N));
    t1 = single(t1);
    t2 = single(t2);
    y = f(t1, t2);  % (Luminance_x, Luminance_y,
                    %  Chrominance1_x, Chrominance2_y,
                    %  Chrominance2_x, Chrominance2_y)

    assert(all(size(y) == [N, N, 3], "all"));

    % TODO: TEMPORARY, BRING BACK
    idctMtx = idct(eye(3, 3)); % idctMtx = eye(3, 3);
    
    weightsR = permute(idctMtx(idR, :)', [2, 3, 1]);
    weightsG = permute(idctMtx(idG, :)', [2, 3, 1]);
    weightsB = permute(idctMtx(idB, :)', [2, 3, 1]);

    corrY = zeros(size(y), "single");
    corrY(:, :, idR) = sum(y.*weightsR, 3);
    corrY(:, :, idG) = sum(y.*weightsG, 3);
    corrY(:, :, idB) = sum(y.*weightsB, 3);

    x = corrY((N + 1)/2, (N + 1)/2, colorId);
end