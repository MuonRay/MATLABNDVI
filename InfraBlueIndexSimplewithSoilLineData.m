%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG 16-bit images taken using InfraBlue Filter 
%Works with DNG Images only - needs loadDNG script in same directory
%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 


filename = 'DJI_0593.DNG';

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




VIS = B;
NIR = R;


figure(4)
plot(VIS, NIR, '+b')
ax = gca;
ax.XLim  = [0 1];
ax.XTick = 0:0.1:1;
ax.YLim  =  [0 1];
ax.YTick = 0:0.1:1;
axis square
xlabel('VIS level')
ylabel('NIR level')
title('NIR vs. VIS(Blue) Scatter Plot')

%In order to identify pixels most likely to contain significant vegetation, 
%you can apply a simple threshold to the image.


threshold = 0.4;
q = (NDVImag > threshold);
%numel(InfraBlue(q(:))) / numel(InfraBlue);
%The percentage of pixels selected is thus
100*numel(NIR(q(:))) / numel(NIR)

figure(5)
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
figure(6);
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

xlabel('VIS(Blue) level')
ylabel('NIR level')



