function [rawData, tinfo]= loadDNG(dngFilename)   
    if(exist(dngFilename,'file'))
        tinfo = imfinfo(dngFilename);
        t = Tiff(dngFilename,'r');
        offsets = getTag(t,'SubIFD');
        setSubDirectory(t,offsets(1));
        rawData = t.read();
        t.close();
    else
        if(nargin<1 || isempty(dngFilename))
            dngFilename = 'File';
        end
        fprintf(1,'%s could not be found\n',dngFilename);
        rawData = [];
    end
end