function imShowZoomable(varargin)
    nimages = nargin;
    images = varargin;

    nrows = floor(sqrt(nimages));
    ncols = ceil(nimages/nrows);

    refSize = size(images{1});
    refHeight = refSize(1);
    refWidth = refSize(2);
    imageGrid = zeros([refHeight*nrows,...
                       refWidth*ncols,...
                       refSize(3)],...
                       class(images{1}));

    axes = [];
    for idx = 1:nimages
        I = images{idx};
        assert(isequal(refSize, size(I)));

        row0 = floor((idx - 1)/ncols);
        col0 = mod(idx - 1, ncols);

        subplot('Position', [col0/ncols, 1 - (row0 + 1)/nrows, 1/ncols, 1/nrows]);
        imshow(I);
        axes = [axes gca];
    end

    p = get(gcf, 'Position');

    if refWidth > refHeight
        scalingFactor = p(3)/(ncols*refWidth);
    else
        scalingFactor = p(4)/(nrows*refHeight);
    end
    adjust = 2.25;  % Arbitrary adjustment
    scalingFactor = adjust*scalingFactor;

    plotWidth = ncols*refWidth*scalingFactor;
    plotHeight = nrows*refHeight*scalingFactor;
    set(gcf,...
        'Position',...
        [p(1) - (plotWidth - p(3))/2,...
         p(2) + (plotHeight - p(4))/2,...
         plotWidth,...
         plotHeight]);

    linkaxes(axes);
end
