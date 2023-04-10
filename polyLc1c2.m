function out = polyLc1c2(t1, t2, degs)
    assert(mod(length(degs), 2) == 0);
    n_colors = length(degs)/2;

    h = height(t1);
    w = width(t1);

    out = zeros([h, w, n_colors], "single");
    for cid = 1:n_colors
        deg1 = degs(2*cid - 1);
        deg2 = degs(2*cid);
        
        if deg1 == -1 || deg2 == -1
            out(:, :, cid) = zeros([h, w], "single");
        else
            out(:, :, cid) = t1.^deg1/factorial(deg1).*t2.^deg2/factorial(deg2);
        end
    end
end

