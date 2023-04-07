function J = imdemosaic(I, opts)
    if strcmp(opts.method, "bilinear")
        J = demosaicBilinear(I, opts);
    end
end
