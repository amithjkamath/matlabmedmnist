function imds = createmedmnistdatastore(images, labels, nameValueArgs)
    % CREATEMEDMNISTDATASTORE creates imageDatastore for medmnist.
    %
    %    Inputs:
    %        images: 4-D array with image data.
    %        labels: 1-D array with label data.
    %
    %    Outputs:
    %        imds: image datastore ready to use for training/evaluation.
    
    arguments
       images {mustBeNumeric} % How do I test if the number of dimensions is 4?
       labels {mustBeNumeric, mustBeColumn}
       nameValueArgs.savepath string {mustBeFolder} = "."
    end

    if ~exist(nameValueArgs.savepath, 'dir')
       mkdir(nameValueArgs.savepath + filesep + "dataset");
    end

    n_images = size(images, 1);
    assert(length(labels) == n_images, ...
        "Number of images must match number of labels")

    unique_labels = unique(labels);
    for label_idx = 1:numel(unique_labels)
        mkdir(fullfile(nameValueArgs.savepath + filesep + "dataset", ...
              string(unique_labels(label_idx))));
    end

    for i = 1:n_images
        image_data = squeeze(images(i, :, :, :));
        label_data = labels(i);
        i_padded = sprintf('%04d', i);
        imwrite(image_data, fullfile(nameValueArgs.savepath + ...
                filesep + "dataset", ...
                string(label_data), ...
                string(i_padded) + ".png"));
    end
    imds = imageDatastore(nameValueArgs.savepath + ...
                          filesep + "dataset", ...
                          "IncludeSubfolders", true, ...
                          "LabelSource","foldernames");
end