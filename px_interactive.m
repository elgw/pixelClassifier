function px_interactive()

close all

% This is just used indicate what folder to open from
image = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/dw_dapi_001.tiff';
image = '/srv/backup/jobb/Tissue-smFISH/ieg728/60x/dapi_25_iter/dw_dapi_001.tiff';
image = '/srv/backup/jobb/Tissue-smFISH/ieg728/60x/dw_dapi_001.tiff'; % 50 iter

%image = '/srv/backup/jobb/MYC FISH FFPE/iXZ060_20210203_004_25x/correct_dw/dw_dapi_001.tiff';

[image, path] = uigetfile(image);
if isequal(image, 0)
    fprintf('No file selected, quitting\n');
    return
end
image = [path filesep() image];

outfolder = uigetdir([], 'Select a folder to store the classifier');
if isequal(outfolder, 0)
    fprintf('No output folder selected, quitting\n');
    return;
end

%% Load the image
fprintf('Loading image ...\n');
[I, scaling] = df_readTif(image);
I = double(I);
if scaling ~= -1
    fprintf('Dividing by scale %f\n', scaling);
    I = I./scaling;    
end
I = max(I, [], 3);

%% TODO:
% Select subregion

%I = I(950:1400, 500:950);

%% Create features
fprintf('Extracting features ...\n');
F = px_features_2d(I);

%% Labels
L = 0*I;



%% Create seeds for the classes
fig = figure();

ax = axes(fig);
img = imagesc(I, 'Parent', ax); axis image, colormap gray
% Todo: implement wait feature in climSlider to set
% the limits for future visualizations
slider = climSlider(img, 'wait');
disp('Adjust the contrast, then type dbcont')
keyboard

clims = get(ax, 'Clim');

disp('Waiting for background labels')
while 1
    title('Select background (end by esc)')
    sel = drawfreehand(ax, 'Closed', false, 'FaceAlpha', 0);    
    pos = round(sel.Position);
    if numel(pos) == 0
        break;
    end
    %idx = sub2ind(size(I), pos(:,2), pos(:,1));
    %L(idx) = 1;
    bw = createMask(sel);
    L(bw) = 1;
    delete(sel)   
    updateLabelImage(img, I, L, clims);    
end
disp('done')

disp('Waiting for nuclei labels')
while 1
    title('Select nuclei (end by esc)')
    sel = drawfreehand(ax, 'Closed', true);    
    %pause
    pos = round(sel.Position);
    if numel(pos) == 0
        break;
    end        
    bw = createMask(sel);
    L(bw) = 2;
	delete(sel)
    updateLabelImage(img, I, L, clims);
end
disp('done')

labelfile = [outfolder filesep() 'labels.png'];
fprintf('Saving labels to %s\n', labelfile);
imwrite(uint8(L), labelfile);
keyboard

px_gen_classifier(I, L, [outfolder filesep() 'classifier'], F)

dbstop error
model_to_c([outfolder filesep() 'classifier'])

Q = reshape(F, [size(F,1)*size(F,2), size(F,3)]);
fprintf('Classifying ... \n');
here = pwd();
cd(outfolder)
mexfun = @cMdl;
cd(here);
C = mexfun(Q');
fprintf('Done\n');
C = reshape(C, size(I));

%figure, imagesc(C)
%axis image

%imwrite(I/max(I(:)), 'interactive.tif');
outimage = [outfolder filesep() 'training_image.tif'];
df_writeTif(uint16(I), outimage);
outclasses = [outfolder filesep() 'training_classes.tif'];
df_writeTif(uint16(C), outclasses);

px_cleanup(outclasses, outimage);

end

function updateLabelImage(img, I, L, clims)
% Draw image colored by labels

H = L/3;
S = .5*double(L>0);

V = I; 
V = V - clims(1); 
V(V<0) = 0;
V = V/(clims(2)-clims(1));
V(V>1) = 1;

% V = I/max(I(:));

V(L>0) = .5 + V(L>0);
V(V>1) = 1;


set(img, 'CData', hsv2rgb(H, S, V))

%imagesc(ax, hsv2rgb(H, S, V));
%axis image
end