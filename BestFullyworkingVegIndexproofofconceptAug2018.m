%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG (raw image) +
%JPEG 16-bit combo images taken using InfraBlue Filter 

%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 

rawData = loadDNG('DJI_0182.DNG'); % load it "functionally" from the command line

%DNG is just a fancy form of TIFF. So we can read DNG with TIFF class in MATLAB

warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning

% 2019 update: Determine Here rows and columns of image to match DNG and JPG

[rows, columns, depth]=size(rawData);


imtool(rawData);                   % display it as proof of concept.

jpgData = imread('DJI_0182.JPG');

%Update for Mavic Pro 2 : must resize jpgData to match DNG (or vice-versa?)

jpgData =imresize(jpgData ,[rows columns]); 

%Transpose Matrices for image data because DNG image format is row-major, and Matlab matrix format is column-major.

%rawData = permute(rawData, [2 1 3]);
%jpgData = permute(jpgData, [2 1 3]); 

%The following demosaic colour filter array (CFA) option forces the mosaic componenets in the Bayer sensor allignment diagonal
%with red and blue across green.

options.filter='rggb';

RAWimg = demosaic(rawData,options.filter);
RAWimg = imadjust(RAWimg, [0.06, 0.94], [], 0.45); %Adjust image intensity, and use gamma value of 0.45

RAWimg(:,:,2) = RAWimg(:,:,2)*0.90; %Reduce the green by factor of 0.90

%Assuming Bayer mosaic sensor alignment create separate mosaic components for each colour channel
J4 = RAWimg(1:2:end, 1:2:end);   %'True colour' i.e VIS Channel
J1 = jpgData(2:2:end, 2:2:end);  % Constructed NIR Channel

%% Make InfraBlue Index Calculations - needs to be a modified version of the standard NDVI with a calbration RAW file which contains transparancy details of the filter used to create our NIR extra channel

VIS = im2single(J4(:,:,1)); %VIS Channel RED - which is the highest intensity NIR used as a magnitude scale 
NIR = im2single(J1(:,:,1)); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 


ndvi = (VIS - NIR)./(VIS + NIR);
ndvi = double(ndvi);


%Main Image in here looks "dark"
figure(1);
imshow(RAWimg);
figure(2);
imshow(jpgData);



%figure(3);
%imshow(ndvi);


%% Stretch NDVI to 0-255 and convert to 8-bit unsigned integer
ndvi = floor((ndvi + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
ndvi(ndvi < 0) = 0;             % not really necessary, just in case & for symmetry
ndvi(ndvi > 65535) = 65535;         % in case the original value was exactly 1
ndvi = uint16(round(ndvi));             % change data type from double to uint16
% ndvi = uint8(ndvi);             % change data type from double to uint8

NDVImag = double(ndvi);

% split
%imshow(img, []);
[nrows ncols dim] = size(NDVImag);
% Get the slices colums wise split equally
img1 = NDVImag(:,1:ncols/3,:);
img2 = NDVImag(:,(ncols/3)+1:2*ncols/3,:);
img3 = NDVImag(:,(2*ncols/3)+1:ncols,:);

figure(3),
subplot(1,3,1), imshow(img1,[]); title('first part');
subplot(1,3,2), imshow(img2,[]); title('second part');
subplot(1,3,3), imshow(img3,[]); title('third part');

figure(4);

myColorMap = jet(65535); % Whatever you want.
rgbImage = ind2rgb(img2, myColorMap);

imagesc(rgbImage,[0 1]), colorbar

%imshow(rgbImage), colorbar
%c = colorbar % Add a color bar to indicate the scaling of color


imwrite(rgbImage, 'InfraBlue6.tif');


figure(5)
plot(VIS, NIR, '+b')
ax = gca;
ax.XLim  = [0 1];
ax.XTick = 0:0.1:1;
ax.YLim  =  [0 1];
ax.YTick = 0:0.1:1;
axis square
xlabel('VIS level')
ylabel('NIR level')
title('NIR vs. VIS Scatter Plot')

%In order to identify pixels most likely to contain significant vegetation, 
%you can apply a simple threshold to the image.


threshold = 0.5;
q = (img2 > 10*threshold);
%numel(ndvi(q(:))) ./ numel(ndvi);
100 * numel(NIR(q(:))) / numel(NIR)

figure(6)
imshow(q)
colormap([0 0 1; 0 1 0]);
title('NDVI with Threshold Applied')



% Link Spectral and Spatial Content
%To link the spectral and spatial content, you can locate above-threshold pixels 
%on the NIR-red scatter plot, re-drawing the scatter plot with the above-threshold pixels
%in a contrasting color (green) and then re-displaying the threshold NDVI image using the 
%same blue-green color scheme. As expected, the pixels having an NDVI value above the threshold appear 
%to the upper left of the rest and correspond to the redder pixels in the CIR composite displays.



% Create a figure with a 1-by-2 aspect ratio
figure(8);
% Need to Create the scatter plot with a linear regression to find slope (indicates
% soil line)

plot(VIS, NIR, '+b', 'DisplayName', 'Background')
hold on

%Plot Soil Line

%b0=0.4; b1=2;
% x= linspace(0.4,1, 20); % Adapt n for resolution of graph
 % y= b0+b1*x;
% plot(x,y,'ok')
 
% make some space in the legend:
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'+b');
h(2) = plot(NaN,NaN,'+r');
h(3) = plot(NaN,NaN,'+g');
legend(h, 'Low Vegetation Cover','Mixed Vegetation Cover','High Vegetation Cover', 'Location', 'Southeast');

plot(VIS(q(:)),NIR(q(:)),'+g', 'DisplayName', 'Vegetation')


%Don't forget that the total image is 0.5*VIS + 0.5*NIR
%Hence the mixed pixels identifier should be x = 0.5*VIS + (1-0.5)*NIR
hold on

X = 0.5*VIS + (1-0.5)*NIR ;

plot(X(q(:)),NIR(q(:)),'+r', 'DisplayName', 'mixed pixels');

p = polyfit(X(q(:)),NIR(q(:)), 1);

xlabel('VIS level')
ylabel('NIR level')




figure(9)
title('NIR vs. VIS Scatter Plot')


% Display the thresholded NDVI
imshow(q)

title('NDVI with Threshold Applied')





%% Simplified Tree Search Process

% Distance transform
im_dist=bwdist(rgbImage<threshold);
%Gaussian Image Kernel Blur

sigma=4;

hsize = 10; % Whatever you want.  More blur for larger numbers.
kernel = fspecial('gaussian', hsize, sigma);
blur = imfilter(im_dist, kernel, 'symmetric'); % Blur the image.

figure(10)

imshow(blur), colorbar

%hold on

% choosing only the red colour to analyse

%imred=blur(:,:,1);

% Watershed
%L = watershed(max(imred(:))-imred);
%[x,y]=find(L==0);

%hold on, plot(y,x,'r.','MarkerSize',3)




