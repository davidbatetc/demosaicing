function J = immosaic(I, sensorAlignment)
    assert(strcmp(sensorAlignment, "rggb"),...
           "The given sensor alignment is not implemented.");

    idR = 1;
    idG = 2;
    idB = 3;

    J = zeros([height(I), width(I)], class(I));
    J(1:2:end, 1:2:end) = I(1:2:end, 1:2:end, idR);
    J(1:2:end, 2:2:end) = I(1:2:end, 2:2:end, idG);
    J(2:2:end, 1:2:end) = I(2:2:end, 1:2:end, idG);
    J(2:2:end, 2:2:end) = I(2:2:end, 2:2:end, idB);
end
