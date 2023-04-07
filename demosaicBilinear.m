function J = demosaicBilinear(I, opts)
    assert(strcmp(opts.sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    h = height(I);
    w = width(I);
    J = single(repmat(I, [1, 1, 3]));

    % Channel indices
    idR = 1;
    idG = 2;
    idB = 3;

    dirsPlus = [1 0; -1 0; 0 1; 0 -1];
    dirsX = [1 1; -1 -1; 1 -1; -1 1];
    dirsH = [0 1; 0 -1];
    dirsV = [1 0; -1 0];

    for r = 1:h
        for c = 1:w
            color = pixelRawColor(r, c);
            if strcmp(color, "R")
                usedDirs = {dirsPlus, dirsX};
                usedId = {idG, idB};
            elseif strcmp(color, "B")
                usedDirs = {dirsPlus, dirsX};
                usedId = {idG, idR};
            elseif strcmp(color, "GT")
                usedDirs = {dirsH, dirsV};
                usedId = {idR, idB};
            elseif strcmp(color, "GB")
                usedDirs = {dirsV, dirsH};
                usedId = {idR, idB};
            else
                error("Unexpected error.");
            end

            for k = 1:2
                dirs = usedDirs{k};
                id = usedId{k};

                localSum = 0;
                nElems = 0;
                for i = length(dirs)
                    dir = dirs(i, :);
                    if isWithinBounds(r + dir(1), c + dir(2), h, w)
                        localSum = localSum + I(r + dir(1), c + dir(2));
                        nElems = nElems + 1;
                    end
                end
                J(r, c, id) = localSum/nElems;
            end
        end
    end

    J = cast(J, class(I));
end

function color = pixelRawColor(r, c)
    mr = mod(r - 1, 2);
    mc = mod(c - 1, 2);

    if mr == 0 && mc == 0
        color = "R";
    elseif mr == 1 && mc == 1
        color = "B";
    elseif mr == 0 && mc == 1
        color = "GT";  % Green top-right corner.
    else
        color = "GB";  % Green bottom-left corner.
    end
end

function boolean = isWithinBounds(r, c, h, w)
    boolean = 1 <= r && r <= h && 1 <= c && c <= w;
end
