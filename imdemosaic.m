function J = imdemosaic(I, opts)
    if strcmp(opts.method, "bilinear")
        J = demosaicBilinear(I, opts);
    elseif strcmp(opts.method, "malvar2004")
        J = demosaicMalvar2004(I, opts);
    elseif strcmp(opts.method, "freeman1988")
        J = demosaicFreeman1988(I, opts);
    elseif strcmp(opts.method, "laroche1994")
        J = demosaicLaroche1994(I, opts);
    end
end
