%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG 16-bit images taken using InfraBlue Filter 
%Works with DNG Images only - needs loadDNG script in same directory
%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 


filename = 'DJI_0592.DNG';

warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning

%DNG is just a fancy form of TIFF. So we can read DNG with TIFF class in MATLAB

rawData = loadDNG(filename);


meta = imfinfo(filename); 

bitdepth = meta.BitDepth;

%Transpose Matrices for image data because DNG image format is row-major, and Matlab matrix format is column-major.

%rawData = permute(rawData, [2 1 3]);

%Assume Bayer mosaic sensor alignment.
%Seperate to mosaic components.
J1 = rawData(1:2:end, 1:2:end);
J2 = rawData(1:2:end, 2:2:end);
J3 = rawData(2:2:end, 1:2:end);
J4 = rawData(2:2:end, 2:2:end);


figure(1);

subplot(2,2,1)
imshow(J1)
title('Red Channel')

subplot(2,2,2)
imshow(J2)
title('Green Channel 1')

subplot(2,2,3)
imshow(J3)
title('Green Channel 2')

subplot(2,2,4)
imshow(J4)
title('Blue Channel')


J1 = imadjust(J1, [0.09, 0.91], [], 0.45); %Adjust image intensity, and use gamma value of 0.45

J1(:,:,1) = J1(:,:,1)*0.80; %Reduce the overall colour temperature by factor of 0.80

B = im2single(J4(:,:,1)); %VIS Channel Blue - which is used as a magnitude scale 
R = im2single(J1(:,:,1)); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 


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


imwrite(rgbImage, 'InfraBlueFin.jpg');
%imwrite(rgbImage, 'InfraBlueFin.jpg'); 
%imwrite(undistortImage(imread(filename), cameraParams2cof, 'OutputView', 'valid'), (strcat(rgbImage, 'InfraBlueFin.jpg'), 'jpg', 'comment', k3));

%Preserve EXIF Data

%imwrite(rgbImage, 'InfraBlueFin.jpg','JPEG','Quality',100);

%t = Tiff('InfraBlueTIFF.tif','w');  

%tagstruct.ImageLength = size(rgbImage,1); 
%tagstruct.ImageWidth = size(rgbImage,2);
%tagstruct.Photometric = Tiff.Photometric.rgbImage;
%tagstruct.BitsPerSample = 8;
%tagstruct.SamplesPerPixel = 3;
%tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
%tagstruct.Software = 'MATLAB'; 

%setTag(t,tagstruct)
%write(t,rgbImage);
%close(t);