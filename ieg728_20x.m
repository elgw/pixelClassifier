% Example usage of the pixel classification pipeline

%% Input 
% Image to be classified
% If 3D, a max projection will be used.
training_image = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001.tiff';
% Manually labels:
% 0 : ignored
% 1 : background
% 2 : nuclei
training_labels = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001_Labels_.png';
% Give the model a recognizable name
MdlName = 'Mdl_ieg728_20x.mat';

%% Run
% Generate the model
fprintf('Generating the classifier\n')
px_gen_classifier(training_image, training_labels, MdlName);

%% Classify an image:
% The training image or some other image.
% image = training_image;
image = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/dapi_001.tiff';

%% Output
% The name that the file with classification results
% do not change, this is set to match the code in 
% px_classify_image
cimage = [image '.classes.png']; 
% and from px_cleanup:
outname_rgb = sprintf('%s.clean_rgb.png', image);
outname_binary = sprintf('%s.clean_binary.png', image);

% Classify the whole image
fprintf('Classifying %s\n', image);
px_classify_image(MdlName, image)
% Clean up the segmentation by removing small objects etc
fprintf('Cleaning up the output in %s\n', cimage);
px_cleanup(cimage, image);
fprintf('All done, generated files:\n');
fprintf('Classifier: %s\n', MdlName);
fprintf('Classification result: %s\n', cimage);
fprintf('Cleaned up mask: %s\n', outname_binary);
fprintf('RGB image: %s\n', outname_rgb);
