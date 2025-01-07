classdef tcreatemedmnistdatastore < matlab.unittest.TestCase
    methods (Test)
        function base_syntax(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(".."));
            
            save_path = "../derma-data-test";
            mkdir(save_path);
            
            dermadata = readmedmnist("derma");
            imds = createmedmnistdatastore(dermadata.train_images, ...
                                           dermadata.train_labels, ...
                                           "savepath", save_path);
            testCase.verifyClass(imds, "matlab.io.datastore.ImageDatastore")
            rmdir(save_path, 's')
        end
    end
end