# Demosaicing methods
Implementation of some demosaicing methods.
- Bilinear demosaicing.
- W. T. Freeman, "Median filter for reconstructing missing color samples", US Patent, no. 4724395, 1988.
- C. A. Laroche and M. A. Prescott, "Apparatus and method for adaptively interpolating a full color image utilizing chrominance gradients", US Patent, no. 5373322, 1994.
- H. S. Malvar, L.-w. He, and R. Cutler, "High-quality linear interpolation for demosaicing of bayer-patterned color images" in 2004 IEEE International Conference on Acoustics, Speech, and Signal Processing, IEEE, vol. 3, 2004, pp. iii–485.
- A new demosaicing method inspired by Malvar *et al.*'s.


## Usage
PSNR/SSIM comparison between different methods can be done using `showComparisonTable`.
```matlab
% The following assumes that the user has the datasets *Kodak*, *McM*,
% *Urban100* and *CBSD68* in the folder `data`.
showComparisonTable(...
    ["data/kodak",...
     "data/McM",...
     "data/Urban100",...
     "data/CBSD68"],...
    ["bilinear",...
     "freeman1988",...
     "laroche1994",...
     "malvar2004",...
     "proposed"]);
```

The results of demosaicing for a given method can be checked visually in the following way.
```matlab
I = imread("image.png");

% Create a mosaic from I using the Bayer pattern with alignment RGGB.
mI = immosaic(I, "rggb");

% Demosaic mI using bilinear demosaicing.
optsBil.sensorAlignment = "rggb";
optsBil.method = "bilinear";
bilJ = imdemosaic(mI, optsBil);

% Demosaic mI using Malvar et al.'s demosaicing.
optsMal.sensorAlignment = "rggb";
optsMal.method = "malvar2004";
malJ = imdemosaic(mI, optsMal);

% Show the original and the two demosaiced images.
displayRatio = 4/3;
imShowZoomable(displayRatio, I, bilJ, malJ);
```


## Notes
- These functions were not created with maintainability or performance (time) in mind. They were created just with the intention of having something that works. Hence the overall lack of documentation.
- The methods implemented are rather obsolete nowadays, since there exist methods which produce much better results.
