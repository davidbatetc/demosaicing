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
    
    tiledlayout(nrows, ncols, 'TileSpacing', 'none', 'Padding', 'tight');
    axes = [];
    for idx = 1:nimages
        I = images{idx};
        assert(isequal(refSize, size(I)));

        ax = nexttile;
        imshow(I);
        axes = [axes ax];
    end

    linkaxes(axes);
    %imshow(imageGrid);
end
