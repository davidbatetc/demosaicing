function J = demosaicMalvar2004(I, opts)
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

    for r = 1:h
        for c = 1:w
            refCid = pixelRawColorId(r, c);
            cids = [1, 2, 3];
            cids(refCid) = [];

            for cid = cids
                weights = getWeights(cid, r, c);

                J(r, c, cid) = 0;
                weightSum = 0;
                for d1 = -2:2
                    for d2 = -2:2
                        if isWithinBounds(r + d1, c + d2, h, w)
                            weightSum = weightSum + weights(3 + d1, 3 + d2);
                            J(r, c, cid) = J(r, c, cid)...
                                + weights(3 + d1, 3 + d2)*sI(r + d1, c + d2);
                        end
                    end
                end
                J(r, c, cid) = J(r, c, cid)/weightSum;
            end
        end
    end

    J = cast(J, class(I));
end

function color = pixelRawColorId(r, c)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    mr = mod(r - 1, 2);
    mc = mod(c - 1, 2);

    if mr == 0 && mc == 0
        color = idR;
    elseif mr == 1 && mc == 1
        color = idB;
    else
        color = idG;
    end
end

function weights = getWeights(colorId, r, c)
    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    mr = mod(r - 1, 2);
    mc = mod(c - 1, 2);

    if mr == 0 && mc == 0 && colorId == idG...
            || mr == 1 && mc == 1 && colorId == idG 
        weights = [  0    0   -1    0    0
                     0    0    2    0    0
                    -1    2    4    2   -1
                     0    0    2    0    0
                     0    0   -1    0    0];
    elseif mr == 0 && mc == 1 && colorId == idR...
            || mr == 1 && mc == 0 && colorId == idB
        weights = [  0    0  0.5    0    0
                     0   -1    0   -1    0
                    -1    4    5    4   -1
                     0   -1    0   -1    0
                     0    0  0.5    0    0];
    elseif mr == 1 && mc == 0 && colorId == idR...
            || mr == 0 && mc == 1 && colorId == idB
        weights = [  0    0   -1    0    0
                     0   -1    4   -1    0
                   0.5    0    5    0  0.5
                     0   -1    4   -1    0
                     0    0   -1    0    0];
    elseif mr == 0 && mc == 0 && colorId == idB...
            || mr == 1 && mc == 1 && colorId == idR
        weights = [  0    0 -1.5    0    0
                     0    2    0    2    0
                  -1.5    0    6    0 -1.5
                     0    2    0    2    0
                     0    0 -1.5    0    0];
    else
        error("Unexpected error");
    end
end

function boolean = isWithinBounds(r, c, h, w)
    boolean = 1 <= r && r <= h && 1 <= c && c <= w;
end