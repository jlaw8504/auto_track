function [imMat] = readTiffStack(filename)
%readTiffStack Read a tiff stack
%   Uses MATLAB's built in iminfo and imread to read in multi-page tiff
%   stack files.
%
%   Input :
%       filename : Character string of the filename
%
%   Output :
%       imMat : A 2D or 3D matrix of the image
%
%   Written by Josh Lawrimore, 1/15/2019

info = imfinfo(filename);
numImages = numel(info);
%pre-allocate matrices
imMat = zeros([info(1).Height, info(1).Width, numImages]);
for n = 1:numImages
    imMat(:,:,n) = imread(filename, n);
end
end

