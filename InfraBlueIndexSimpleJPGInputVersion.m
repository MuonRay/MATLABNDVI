%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG 16-bit images taken using InfraBlue Filter 
%Works with JPG Images only - DNG Files need a separate script
%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 
% Read original image.
rgbImage = imread('DJI_0182.JPG');
% Extract colour channels.
redChannel = rgbImage(:,:,1); % Red channel
greenChannel = rgbImage(:,:,2); % Green channel
blueChannel = rgbImage(:,:,3); % Blue channel

figure(1);

subplot(2,2,1)
imshow(redChannel)
title('Red Channel')

subplot(2,2,2)
imshow(greenChannel)
title('Green Channel')


subplot(2,2,3)
imshow(blueChannel)
title('Blue Channel')

B = im2single(blueChannel); %VIS Channel Blue - which is used as a magnitude scale 
R = im2single(redChannel); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 


InfraBlue = (R - B)./(R + B);
InfraBlue = double(InfraBlue);



%% Stretch NDVI to 0-255 and convert to 8-bit unsigned integer
InfraBlue = floor((InfraBlue + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
InfraBlue(InfraBlue < 0) = 0;             % not really necessary, just in case & for symmetry
InfraBlue(InfraBlue > 65535) = 65535;         % in case the original value was exactly 1
InfraBlue = uint16(round(InfraBlue));             % change data type from double to uint16
% InfraBlue = uint8(InfraBlue);             % change data type from double to uint8

NDVImag = double(InfraBlue);


figure(3);

myColorMap = jet(65535); % Whatever you want.
rgbImage = ind2rgb(NDVImag, myColorMap);

imagesc(rgbImage,[0 1]), colorbar

%imshow(rgbImage), colorbar
%c = colorbar % Add a color bar to indicate the scaling of color


imwrite(rgbImage, 'InfraBlueJPGInput.png');