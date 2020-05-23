%Experimental Vegetation Index Mapping program using DJI Mavic Pro DNG 16-bit images taken using InfraBlue Filter 
%This version is for Batch Processing of Images for ease of use to output to 3D Mapping Software
%Works with DNG Images only - needs loadDNG script in same directory
%(c)-J. Campbell MuonRay Enterprises Drone-based Vegetation Index Project 2017-2019 

%requestion directory for files 



%dname = uigetdir('C:\');


%number of images to output (i.e. 10 tif images to output using
%10 DNG images to process.)

prompt = 'Enter Number Range of Files:';

answer = input(prompt); 
imgnum = answer;

for n=1:imgnum
    
    

rawData{n} = loadDNG(sprintf('DJI_0%03d.DNG',n)); % load it "functionally" from the command line

%DNG is just a fancy form of TIFF. So we can read DNG with TIFF class in MATLAB

warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning

%Assume Bayer mosaic sensor alignment.
%Seperate to mosaic components.
J1{n} = rawData{n}(1:2:end, 1:2:end);
J4{n} = rawData{n}(2:2:end, 2:2:end);

J1{n} = imadjust(J1{n}, [0.09, 0.91], [], 0.45); %Adjust image intensity, and use gamma value of 0.45

J1{n}(:,:,1) = J1{n}(:,:,1)*0.80; %Reduce the overall colour temperature by factor of 0.80

B{n} = im2single(J4{n}(:,:,1)); %VIS Channel Blue - which is used as a magnitude scale 
R{n} = im2single(J1{n}(:,:,1)); %NIR Chaneel RED which is the IR reflectance of healthy vegeation 

%% Make InfraBlue Index Calculations - needs to be a modified version of the standard NDVI with a calbration RAW file which contains transparancy details of the filter used to create our NIR extra channel


ndvi{n} = (R{n} - B{n})./(R{n} + B{n});
ndvi{n} = double(ndvi{n});


%Main Image in here looks "dark"
figure(1);
imshow(rawData{n});



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


figure(2);

myColorMap = jet(65535); % Whatever you want.
rgbImage{n} = ind2rgb(NDVImag{n}, myColorMap);

imagesc(rgbImage{n},[0 1]), colorbar

%imshow(rgbImage), colorbar
%c = colorbar % Add a color bar to indicate the scaling of color

imwrite(rgbImage{n}, sprintf('InfraBlue0%03d.tif',n));



end