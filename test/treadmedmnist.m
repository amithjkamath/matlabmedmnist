classdef treadmedmnist < matlab.unittest.TestCase
    methods (Test)
        function base_syntax(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(".."));

            dermadata = readmedmnist("derma");
            % Verify two fields
            testCase.verifyEqual(length(fields(dermadata)), 2)
            % Verify training images exists
            testCase.verifyEqual(size(dermadata.train_images, 1), 7007)
            % Verify training labels exists
            testCase.verifyEqual(size(dermadata.train_labels, 1), 7007)

            % Verify dimension of one training image
            first_image = squeeze(dermadata.train_images(1, :, :, :));
            testCase.verifyEqual(size(first_image), [28, 28, 3])
        end

        function im_size_syntax(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(".."));

            dermadata = readmedmnist("derma", "size", 64);
            % Verify two fields
            testCase.verifyEqual(length(fields(dermadata)), 2)
            % Verify training images exists
            testCase.verifyEqual(size(dermadata.train_images, 1), 7007)
            % Verify training labels exists
            testCase.verifyEqual(size(dermadata.train_labels, 1), 7007)

            % Verify dimension of one training image
            first_image = squeeze(dermadata.train_images(1, :, :, :));
            testCase.verifyEqual(size(first_image), [64, 64, 3])
        end

        function split_syntax(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture(".."));

            dermadata = readmedmnist("derma", "size", 64, "split", "val");
            % Verify two fields
            testCase.verifyEqual(length(fields(dermadata)), 2)
            % Verify training images exists
            testCase.verifyEqual(size(dermadata.val_images, 1), 1003)
            % Verify training labels exists
            testCase.verifyEqual(size(dermadata.val_labels, 1), 1003)

            % Verify dimension of one training image
            first_image = squeeze(dermadata.val_images(1, :, :, :));
            testCase.verifyEqual(size(first_image), [64, 64, 3])
        end
    end
end