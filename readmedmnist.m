function medmnistdata = readmedmnist(variant, nameValueArgs)
    % READMEDMNIST reads medmnist data files from the zenodo server.
    %
    % Inputs:
    %    variant: string, required
    %        Could be "derma", "breast", "organ3d" ... 
    %        see full list at https://medmnist.com
    %
    %    split: string, optional: default = "train"
    %        One of three choices: "train", "val" and "test". 
    %        Currently, "test" returns nothing so there's no chance to
    %        cheat while playing around with the models. This can be easily
    %        circumvented by looking at the file and editing it. 
    %
    %    im_size: positive integer, optional: default: 32
    %        This parameter includes the image size, 64, 128 are reasonable
    %        options depending on what image sizes are available from
    %        https://medmnist.com 
    %
    % Outputs:
    %    medmnistdata: struct
    %        This structure contains fields titled <split>_images for 
    %        image data, and <split>_labels for label data from the
    %        requested data set. Note that the number of elements in the
    %        structure can be different depending on the data downloaded.

    % Dependency: many thanks to https://github.com/kwikteam/npy-matlab
    % for their .npy MATLAB reading utilities.

    arguments
       variant {mustBeMember(variant,["derma", "pneumonia", "breast", "organs"])}
       nameValueArgs.split {mustBeMember(nameValueArgs.split,["train", "val"])} = "train"
       nameValueArgs.size {mustBeMember(nameValueArgs.size,[0, 64, 128])} = 0
    end

    if nameValueArgs.size == 0
        nameValueArgs.size = "";
    else
        nameValueArgs.size = "_" + string(nameValueArgs.size);
    end

    path_to_save = tempdir;
    zenodo_path = "https://zenodo.org/records/10519652/files/" + ...
                  variant + "mnist" + nameValueArgs.size + ...
                  ".npz?download=1";
    
    t_download = tic;
    try
        fprintf("Downloading " + variant + " medmnist data. " + ...
                "This can take some time ... \n");
        websave(fullfile(path_to_save, variant + ".npz"), zenodo_path);
    catch
        fprintf("The file requested does not exist. Please check variant name and size\n");
    end

    fprintf("Completed download in " + toc(t_download) + " seconds. \n")

    unzip(fullfile(path_to_save, variant + ".npz"), path_to_save);
    files = dir(fullfile(path_to_save,'*.npy'));
    datafiles = string(fullfile({files.folder},{files.name}));

    medmnistdata = struct();
    for npy_file = datafiles
        [~, fname, ~] = fileparts(npy_file);
        if contains(npy_file, nameValueArgs.split)
            fprintf("Extracting: " + fname + " structure. \n")
            data = readNPY(npy_file);
            medmnistdata.(fname) = data;
        end
        delete(npy_file);
    end
end


function data = readNPY(filename)
    % Function to read NPY files into matlab.
    % *** Only reads a subset of all possible NPY files, specifically N-D 
    % arrays of certain data types.
    % See https://github.com/kwikteam/npy-matlab/blob/master/tests/npy.ipynb 
    % for more.
    %
    
    [shape, dataType, fortranOrder, littleEndian, totalHeaderLength, ~] = readNPYheader(filename);
    
    if littleEndian
        fid = fopen(filename, 'r', 'l');
    else
        fid = fopen(filename, 'r', 'b');
    end
    
    try
    
        [~] = fread(fid, totalHeaderLength, 'uint8');
    
        % read the data
        data = fread(fid, prod(shape), [dataType '=>' dataType]);
    
        if length(shape)>1 && ~fortranOrder
            data = reshape(data, shape(end:-1:1));
            data = permute(data, length(shape):-1:1);
        elseif length(shape)>1
            data = reshape(data, shape);
        end
    
        fclose(fid);
    
    catch me
        fclose(fid);
        rethrow(me);
    end
end


function [arrayShape, dataType, fortranOrder, littleEndian, totalHeaderLength, npyVersion] = readNPYheader(filename)
    % function [arrayShape, dataType, fortranOrder, littleEndian, ...
    %       totalHeaderLength, npyVersion] = readNPYheader(filename)
    %
    % parse the header of a .npy file and return all the info contained
    % therein.
    %
    % Based on spec at http://docs.scipy.org/doc/numpy-dev/neps/npy-format.html
    
    fid = fopen(filename);
    
    % verify that the file exists
    if (fid == -1)
        if ~isempty(dir(filename))
            error('Permission denied: %s', filename);
        else
            error('File not found: %s', filename);
        end
    end
    
    try
        
        dtypesMatlab = {'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double', 'logical'};
        dtypesNPY = {'u1', 'u2', 'u4', 'u8', 'i1', 'i2', 'i4', 'i8', 'f4', 'f8', 'b1'};
        
        
        magicString = fread(fid, [1 6], 'uint8=>uint8');
        
        if ~all(magicString == [147,78,85,77,80,89])
            error('readNPY:NotNUMPYFile', 'Error: This file does not appear to be NUMPY format based on the header.');
        end
        
        majorVersion = fread(fid, [1 1], 'uint8=>uint8');
        minorVersion = fread(fid, [1 1], 'uint8=>uint8');
        
        npyVersion = [majorVersion minorVersion];
        
        headerLength = fread(fid, [1 1], 'uint16=>uint16');
        
        totalHeaderLength = 10+headerLength;
        
        arrayFormat = fread(fid, [1 headerLength], 'char=>char');
        
        % to interpret the array format info, we make some fairly strict
        % assumptions about its format...
        
        r = regexp(arrayFormat, '''descr''\s*:\s*''(.*?)''', 'tokens');
        if isempty(r)
            error('Couldn''t parse array format: "%s"', arrayFormat);
        end
        dtNPY = r{1}{1};    
        
        littleEndian = ~strcmp(dtNPY(1), '>');
        
        dataType = dtypesMatlab{strcmp(dtNPY(2:3), dtypesNPY)};
            
        r = regexp(arrayFormat, '''fortran_order''\s*:\s*(\w+)', 'tokens');
        fortranOrder = strcmp(r{1}{1}, 'True');
        
        r = regexp(arrayFormat, '''shape''\s*:\s*\((.*?)\)', 'tokens');
        shapeStr = r{1}{1}; 
        arrayShape = str2num(shapeStr(shapeStr~='L'));
    
        
        fclose(fid);
        
    catch me
        fclose(fid);
        rethrow(me);
    end
end