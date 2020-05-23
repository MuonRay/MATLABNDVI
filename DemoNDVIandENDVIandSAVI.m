% Read original image.
rgbImage = imread('DJI_0078.JPG');
% Extract colour channels.
redChannel = rgbImage(:,:,1); % Red channel
greenChannel = rgbImage(:,:,2); % Green channel
blueChannel = rgbImage(:,:,3); % Blue channel

B = im2single(blueChannel); %VIS Channel Blue - which is used as a magnitude scale 
R = im2single(redChannel); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 
G = im2single(redChannel); %For ENDVI For a Given Green Narrow/Low Pass Filter
L = 0.5; % Soil Reflectance Correction Factor for SAVI Index

%InfraBlue NDVI
InfraBlue = (R - B)./(R + B);
InfraBlue = double(InfraBlue);


%% Stretch NDVI to 0-255 and convert to 8-bit unsigned integer
InfraBlue = floor((InfraBlue + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
InfraBlue(InfraBlue < 0) = 0;             % may not really be necessary, just in case & for symmetry
InfraBlue(InfraBlue > 65535) = 65535;         % in case the original value was exactly 1
InfraBlue = uint16(round(InfraBlue));             % change data type from double to uint16
% InfraBlue = uint8(InfraBlue);             % change data type from double to uint8

NDVImag = double(InfraBlue);



%ENDVI - Green Leveraged

ENDVI = ((R+G) - (2*B))./((R+G) + (2*B));
ENDVI = double(ENDVI);

%% Stretch ENDVI to 0-255 and convert to 8-bit unsigned integer
ENDVI = floor((ENDVI + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
ENDVI(ENDVI < 0) = 0;             % may not really be necessary, just in case & for symmetry
ENDVI(ENDVI > 65535) = 65535;         % in case the original value was exactly 1
ENDVI = uint16(round(ENDVI));             % change data type from double to uint16
% InfraBlue = uint8(InfraBlue);             % change data type from double to uint8

ENDVImag = double(ENDVI);


%SAVI - Soil Reflectance Leveraged 
%The SAVI is structured similar to the NDVI but with the addition of a
%“soil reflectance correction factor” L.
%L is a constant (related to the slope of the soil-line in a feature-space plot)
%Hence the value of L varies by the amount or cover of green vegetation: in very high vegetation regions, 
%L=0; and in areas with no green vegetation, L=1. Generally, an L=0.5 works
%well in most situations (i.e. mixed vegetation cover)
%So 0.5 (half) is the default value used. When L=0, then SAVI = NDVI.

SAVI = (((R-B)*(1+L))./(R+B+L));
SAVI = double(SAVI);

%% Stretch ENDVI to 0-255 and convert to 8-bit unsigned integer
SAVI = floor((SAVI + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
SAVI(SAVI < 0) = 0;             % may not really be necessary, just in case & for symmetry
SAVI(SAVI > 65535) = 65535;         % in case the original value was exactly 1
SAVI = uint16(round(SAVI));             % change data type from double to uint16
% InfraBlue = uint8(InfraBlue);             % change data type from double to uint8

SAVImag = double(SAVI);


% Display them all.
subplot(3, 3, 2);
imshow(rgbImage);
fontSize = 20;
title('Captured Image', 'FontSize', fontSize)
subplot(3, 3, 4);
imshow(redChannel);
title('Red Channel', 'FontSize', fontSize)
subplot(3, 3, 5);
imshow(greenChannel)
title('Green Channel', 'FontSize', fontSize)
subplot(3, 3, 6);
imshow(blueChannel);
title('Blue Channel', 'FontSize', fontSize)
subplot(3, 3, 7);
myColorMap = jet(65535); % Whatever you want.
rgbImage = ind2rgb(NDVImag, myColorMap);
imagesc(rgbImage,[0 1])
%imshow(recombinedRGBImage);
title('NDVI Image', 'FontSize', fontSize)
subplot(3, 3, 8);
myColorMap = jet(65535); % Whatever you want.
rgbImage2 = ind2rgb(ENDVImag, myColorMap);
imagesc(rgbImage2,[0 1])
%imshow(recombinedRGBImage);
title('ENDVI Image', 'FontSize', fontSize)
subplot(3, 3, 9);
myColorMap = jet(65535); % Whatever you want.
rgbImage3 = ind2rgb(SAVImag, myColorMap);
imagesc(rgbImage3,[0 1])
%imshow(recombinedRGBImage);
title('SAVI Image', 'FontSize', fontSize)
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo NDVI Poster', 'NumberTitle', 'Off')