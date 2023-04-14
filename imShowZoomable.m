function imShowZoomable(displayRatio, varargin)
    nimages = nargin - 1;
    images = varargin;

    nrows = floor(sqrt(nimages));
    ncols = ceil(nimages/nrows);

    refSize = size(images{1});
    refHeight = refSize(1);
    refWidth = refSize(2);

    if displayRatio == -1
        displayRatio = refWidth/refHeight;
    end

    if refWidth/refHeight < displayRatio
        croppedHeight = refWidth/displayRatio;
        croppedWidth = refWidth;
    else
        croppedHeight = refHeight;
        croppedWidth = refHeight*displayRatio;
    end

    axes = [];
    for idx = 1:nimages
        I = images{idx};
        assert(isequal(refSize, size(I)));

        row0 = floor((idx - 1)/ncols);
        col0 = mod(idx - 1, ncols);

        subplot('Position', [col0/ncols, 1 - (row0 + 1)/nrows, 1/ncols, 1/nrows]);
        imshow(I);

        ybnd = (refHeight - croppedHeight)/2;
        xbnd = (refWidth - croppedWidth)/2;
        xlim(xbnd + [0 croppedWidth]);
        ylim(ybnd + [0 croppedHeight]);
        axes = [axes gca];
    end

    p = get(gcf, 'Position');

    if croppedWidth > croppedHeight
        scalingFactor = p(3)/(ncols*croppedWidth);
    else
        scalingFactor = p(4)/(nrows*croppedHeight);
    end
    adjust = 2;  % Arbitrary adjustment
    scalingFactor = adjust*scalingFactor;

    plotWidth = ncols*croppedWidth*scalingFactor;
    plotHeight = nrows*croppedHeight*scalingFactor;
    set(gcf,...
        'Position',...
        [p(1) - (plotWidth - p(3))/2,...
         p(2) + (plotHeight - p(4))/2,...
         plotWidth,...
         plotHeight]);

    linkaxes(axes);
end
