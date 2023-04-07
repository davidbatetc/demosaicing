function J = imdemosaic(I, opts)
    if strcmp(opts.method, "bilinear")
        J = demosaicBilinear(I, opts);
    elseif strcmp(opts.method, "malvar2004")
        J = demosaicMalvar2004(I, opts);
    end
end
