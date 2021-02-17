% Example usage of the pixel classification pipeline

%% Input 
% Image to be classified
% If 3D, a max projection will be used.
image = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001.tiff';
% Manually labels:
% 0 : ignored
% 1 : background
% 2 : nuclei
labels = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001_Labels_.png';
% Give the model a recognizable name
MdlName = 'Mdl_ieg728_20x.mat';

%% Output
% The name that the file with classification results
% do not change, this is set to match the code in 
% px_classify_image
cimage = [image '.classes.png']; 
% and from px_cleanup:
outname_rgb = sprintf('%s.clean_rgb.png', cimage);
outname_binary = sprintf('%s.clean_binary.png', cimage);

%% Run
% Generate the model
px_gen_classifier(image, labels, MdlName);
% Classify the whole image
px_classify_image(MdlName, image)
% Clean up the segmentation by removing small objects etc
px_cleanup(cimage, image);