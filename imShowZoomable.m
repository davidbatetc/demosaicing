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
    
    for idx = 1:nimages
        I = images{idx};
        assert(isequal(refSize, size(I)));

        row0 = floor((idx - 1)/ncols);
        col0 = mod(idx - 1, ncols);

        imageGrid(row0*refHeight + (1:refHeight),...
                  col0*refWidth + (1:refWidth),...
                  :) = images{idx};
    end

    imshow(imageGrid);
end