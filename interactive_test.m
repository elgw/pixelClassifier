image = '/srv/backup/jobb/upload1/210208_5weekslung_20x_wholedata_forErik_merge/cyc001_reg001/dw_chan1_002.tif';

%% Load the image
I = df_readTif(image);
I = double(I);
I = max(I, [], 3);

%% Create features
F = px_features_2d(I);

%% Labels
L = 0*I;

%% Create seeds for the classes

fig = figure();
ax = axes(fig);
imagesc(I, 'Parent', ax), axis image, colormap gray

while 1
    title('Select background (end by esc)')
    sel = drawfreehand(ax, 'Closed', false);    
    pos = round(sel.Position);
    if numel(pos) == 0
        break;
    end
    idx = sub2ind(size(I), pos(:,1), pos(:,2));
    L(idx) = 1;
end

while 1
    title('Select nuclei (end by esc)')
    sel = drawfreehand(ax, 'Closed', false);    
    pos = round(sel.Position);
    if numel(pos) == 0
        break;
    end
    idx = sub2ind(size(I), pos(:,2), pos(:,1));
    L(idx) = 2;
end
close all

figure,
imagesc(L)

px_gen_classifier(I, L, 'interactive', F)
model_to_c('interactive')
Q = reshape(F, [size(F,1)*size(F,2), size(F,3)]);
C = cMdl(Q');
C = reshape(C, size(I));
figure, imagesc(C)
axis image

%imwrite(I/max(I(:)), 'interactive.tif');
df_writeTif(uint16(I), 'interactive.tif');
df_writeTif(uint16(C), 'classes.tif')
CL = px_cleanup('classes.tif', 'interactive.tif');
imagesc(CL)
