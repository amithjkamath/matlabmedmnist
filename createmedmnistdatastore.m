function imds = createmedmnistdatastore(images, labels)
    % CREATEMEDMNISTDATASTORE creates imageDatastore for medmnist.
    %
    %    Inputs:
    %        images: 4-D array with image data.
    %        labels: 1-D array with label data.
    %
    %    Outputs:
    %        imds: image datastore ready to use for training/evaluation.
    
    n_images = size(images, 1);
    assert(length(labels) == n_images, ...
        "Number of images must match number of labels")

    save_dir = uigetdir(".", "Choose folder to save image data in:");

    unique_labels = unique(labels);
    for label_idx = 1:numel(unique_labels)
        mkdir(fullfile(save_dir, string(unique_labels(label_idx))));
    end

    for i = 1:n_images
        image_data = squeeze(images(i, :, :, :));
        label_data = labels(i);
        i_padded = sprintf('%04d', i);
        imwrite(image_data, fullfile(save_dir, string(label_data), ...
                string(i_padded) + ".png"));
    end
    imds = imageDatastore(save_dir, "IncludeSubfolders", true, "LabelSource","foldernames");
end