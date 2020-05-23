%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG (raw image) +
%JPEG 16-bit combo images taken using InfraBlue Filter 
%This version is for Batch Processing of Images for ease of use to output to 3D Mapping Software

%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 

%requestion directory for files 



dname = uigetdir('C:\');


%number of images to output (i.e. 10 tif images to output using 10 jpg and
%10 DNG images to process.)

prompt = 'Enter Number Range of Files:';

answer = input(prompt); 
imgnum = answer;

for n=1:imgnum
    
    

rawData{n} = loadDNG(sprintf('DJI_%03d.DNG',n)); % load it "functionally" from the command line

%DNG is just a fancy form of TIFF. So we can read DNG with TIFF class in MATLAB

warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning

% 2019 update: Determine Here rows and columns of image to match DNG and JPG

[rows{n}, columns{n}, depth{n}]=size(rawData{n});


imtool(rawData{n});                   % display it as proof of concept.

jpgData{n}  = imread(sprintf('DJI_%03d.JPG',n));

%Update for Mavic Pro 2 : must resize jpgData to match DNG (or vice-versa?)

jpgData{n} =imresize(jpgData{n} ,[rows{n} columns{n}]); 

%Transpose Matrices for image data because DNG image format is row-major, and Matlab matrix format is column-major.

rawData{n} = permute(rawData{n}, [2 1 3]);
jpgData{n} = permute(jpgData{n}, [2 1 3]); 

%The following demosaic colour filter array (CFA) option forces the mosaic componenets in the Bayer sensor allignment diagonal
%with red and blue across green.

options.filter='rggb';

RAWimg{n} = demosaic(rawData{n},options.filter);
RAWimg{n} = imadjust(RAWimg{n}, [0.04, 0.96], [], 0.45); %Adjust image intensity, and use gamma value of 0.45

RAWimg{n}(:,:,2) = RAWimg{n}(:,:,2)*0.95; %Reduce the green by factor of 0.95

%Assuming Bayer mosaic sensor alignment create separate mosaic components for each colour channel
J4{n} = RAWimg{n}(1:2:end, 1:2:end);   %'True colour' i.e VIS Channel
J1{n} = jpgData{n}(2:2:end, 2:2:end);  % Constructed NIR Channel

%% Make InfraBlue Index Calculations - needs to be a modified version of the standard NDVI with a calbration RAW file which contains transparancy details of the filter used to create our NIR extra channel

VIS{n} = im2single(J4{n}(:,:,1)); %VIS Channel RED - which is the highest intensity NIR used as a magnitude scale 
NIR{n} = im2single(J1{n}(:,:,1)); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 


ndvi{n} = (VIS{n} - NIR{n})./(VIS{n} + NIR{n});
ndvi{n} = double(ndvi{n});


%Main Image in here looks "dark"
figure(1);
imshow(RAWimg{n});
figure(2);
imshow(jpgData{n});



%figure(3);
%imshow(ndvi);


%% Stretch NDVI to 0-255 and convert to 8-bit unsigned integer
ndvi{n} = floor((ndvi{n} + 1) * 32767); % [-1 1] -> [0 256] for 8-bit display range(*128), [0, 65535] for 16-bit display range (*32500)
ndvi{n}(ndvi{n} < 0) = 0;             % not really necessary, just in case & for symmetry
ndvi{n}(ndvi{n} > 65535) = 65535;         % in case the original value was exactly 1
ndvi{n} = uint16(round(ndvi{n}));             % change data type from double to uint16
% ndvi = uint8(ndvi);             % change data type from double to uint8

NDVImag{n} = double(ndvi{n});

% split
%imshow(img, []);
[nrows ncols dim] = size(NDVImag{n});
% Get the slices colums wise split equally
img1{n} = NDVImag{n}(:,1:ncols/3,:);
img2{n} = NDVImag{n}(:,(ncols/3)+1:2*ncols/3,:);
img3{n} = NDVImag{n}(:,(2*ncols/3)+1:ncols,:);

figure(3),
subplot(1,3,1), imshow(img1{n},[]); title('first part');
subplot(1,3,2), imshow(img2{n},[]); title('second part');
subplot(1,3,3), imshow(img3{n},[]); title('third part');

figure(4);

myColorMap = jet(65535); % Whatever you want.
rgbImage{n} = ind2rgb(img2{n}, myColorMap);

imagesc(rgbImage{n},[0 1]), colorbar

%imshow(rgbImage), colorbar
%c = colorbar % Add a color bar to indicate the scaling of color

imwrite(rgbImage{n}, sprintf('InfraBlue0%03d.tif',n));



end