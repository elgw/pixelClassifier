function px_classify_image(classifier, imagename)
% Classify the pixels of an image using a classifier created by
% px_gen_classifier.
% imagename: the file name of the image to be classified
% classifier: the file name (.mat) containing the classifier

if nargin == 0
    close all
imagename = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001.tiff';
classifier = 'classifier_001.mat';
dbstop error 
end

load(classifier, 'Mdl');
assert(isvarname('Mdl'));

I = df_readTif(imagename);

I = max(I, [], 3);

tilesize = 512;
overlap = 52;
tiles = tiles_generate_tiling(size(I), tilesize, overlap);
C = 0*I;
figure, imagesc(C), axis image, drawnow
fprintf('\n');
for kk = 1:numel(tiles)
    progressbar(kk, numel(tiles));
    C = classify_tile(Mdl, tiles{kk}, I, C);
    imagesc(C)
    drawnow
end

imwrite(C, sprintf('%s.classes.png', imagename));

end

function T = tiles_generate_tiling(sz, ts, ol)
assert(numel(sz) == 2);
ntiles = ceil(sz/ts);
ex = round(linspace(1, sz(1)+1, ntiles(1)));
ey = round(linspace(1, sz(2)+1, ntiles(2)));
T = {};
for kk = 1:numel(ex)-1
    for ll = 1:numel(ey)-1
        t.x0 = [ex(kk), ex(kk+1)-1];
        t.y0 = [ey(ll), ey(ll+1)-1];
        t.x = t.x0;
        t.y = t.y0;
        t.x(1) = max(1, t.x0(1)-ol);
        t.x(2) = min(sz(1), t.x0(2)+ol);
        t.y(1) = max(1, t.y0(1)-ol);
        t.y(2) = min(sz(2), t.y0(2)+ol);
        T{end+1} = t;
    end
end
end

function C = tile_crop(tile, I)
% Crop out the padding from I
% I has size tile.x/y and is cropped to tile.x0/y0

xstart = tile.x0(1)-tile.x(1)+1;
h = tile.x0(2)-tile.x0(1)+1;

ystart = tile.y0(1)-tile.y(1)+1;
w = tile.y0(2)-tile.y0(1)+1;

C = I(xstart:xstart+h-1, ystart:ystart+w-1);
assert( size(C,1) == numel(tile.x0(1):tile.x0(2)));
assert( size(C,2) == numel(tile.y0(1):tile.y0(2)));
end

function C = classify_tile(Mdl, tile, I, C)
% Classify a tile and put the result back in C
im = I(tile.x(1):tile.x(2), tile.y(1):tile.y(2));
c = px_classify_region(Mdl, im);
c = tile_crop(tile, c);
C(tile.x0(1):tile.x0(2), tile.y0(1):tile.y0(2)) = c;
end