function showComparisonTable(datasetPaths, methodNames)
    showFirstN = 5;

    maxMethodNameLength = getMaxMethodNameLength(methodNames);
    printLeftPaddedString("METHOD", maxMethodNameLength + 4);
    for l = 1:showFirstN
        printLeftPaddedString(sprintf("IMAGE %i", l), 16);
    end
    printLeftPaddedString("DATASET AVG.", 16);
    fprintf("\n");

    ndatasets = length(datasetPaths);
    for i = 1:ndatasets
        showComparisonOneDataset(datasetPaths{i}, methodNames, showFirstN);
    end
end

function printLeftPaddedString(string, padding)
    fprintf(sprintf("%%-%is", padding), string);
end

function maxMethodNameLength = getMaxMethodNameLength(methodNames)
    nmethods = length(methodNames);

    maxMethodNameLength = 0;
    for j = 1:nmethods
        maxMethodNameLength = max(maxMethodNameLength,...
                                  strlength(methodNames{j}));
    end
end

function showComparisonOneDataset(datasetPath, methodNames, showFirstN)
    nmethods = length(methodNames);
    maxMethodNameLength = getMaxMethodNameLength(methodNames);

    for j = 1:nmethods
        methodName = methodNames{j};
        methodNameFormat = sprintf("%%-%is", maxMethodNameLength + 2);
        fprintf(methodNameFormat, methodName);
        showComparisonOneDatasetOneMethod(datasetPath, methodName, showFirstN);
    end

    fprintf("\n");
end

function showComparisonOneDatasetOneMethod(datasetPath, methodName, showFirstN)
    filePaths = getFilePaths(datasetPath);
    nimages = length(filePaths);

    % First collect all the errors
    errPsnrs = zeros(nimages, 1);
    errSsims = zeros(nimages, 1);
    for k = 1:nimages
        I = imread(filePaths{k});
        [errPsnrs(k), errSsims(k)] = singleImagePerformance(I, methodName);
    end

    % Then show the errors of the first images
    for k = 1:showFirstN
        fprintf("& %2.2f/%1.4f  ", errPsnrs(k), errSsims(k));
    end

    % Then the average
    fprintf("& %2.2f/%1.4f  \\\\\n", mean(errPsnrs), mean(errSsims));
end

function filePaths = getFilePaths(datasetPath)
    listing = dir(datasetPath);
    nelems = length(listing);
    listingIsDirs = {listing.isdir};
    listingFolders = {listing.folder};
    listingNames = {listing.name};

    filePaths = cell(nelems, 1);

    count = 0;
    for k = 1:nelems
        if ~listingIsDirs{k}
            count = count + 1;
            filePaths{count} = fullfile(listingFolders{k}, listingNames{k});
        end
    end

    filePaths = filePaths(1:count);
end

function [errPsnr, errSsim] = singleImagePerformance(I, methodName)
    sensorAlignment = "rggb";
    mI = immosaic(I, sensorAlignment);

    opts.sensorAlignment = sensorAlignment;
    opts.method = methodName;
    J = imdemosaic(mI, opts);

    errPsnr = psnr(I, J);
    errSsim = ssim(I, J);
end
