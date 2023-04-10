function x = evalDemosaicT(f, N, mr, mc)
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

    idctMtx = idct(eye(3, 3));
    
    weightsR = permute(idctMtx(idR, :)', [2, 3, 1]);
    weightsG = permute(idctMtx(idG, :)', [2, 3, 1]);
    weightsB = permute(idctMtx(idB, :)', [2, 3, 1]);

    corrY = zeros(size(y), "single");
    corrY(:, :, idR) = sum(y.*weightsR, 3);
    corrY(:, :, idG) = sum(y.*weightsG, 3);
    corrY(:, :, idB) = sum(y.*weightsB, 3);

    x = zeros([N N], "single");

    row0 = mr;
    col0 = mc;
    if mod(N, 4) == 3
        row0 = mod(mr + 1, 2);
        col0 = mod(mc + 1, 2);
    end
    row1 = mod(row0 + 1, 2);
    col1 = mod(col0 + 1, 2);

    x((row0+1):2:end, (col0+1):2:end) = corrY((row0+1):2:end, (col0+1):2:end, idR);
    x((row0+1):2:end, (col1+1):2:end) = corrY((row0+1):2:end, (col1+1):2:end, idG);
    x((row1+1):2:end, (col0+1):2:end) = corrY((row1+1):2:end, (col0+1):2:end, idG);
    x((row1+1):2:end, (col1+1):2:end) = corrY((row1+1):2:end, (col1+1):2:end, idB);
end