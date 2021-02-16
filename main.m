image = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001.tiff';
labels = '/srv/backup/jobb/Tissue-smFISH/ieg728/20x/max_dapi_001_Labels_.png';

I = df_readTif(image);
L = imread(labels);

%% Calculate Features
[F, Fnames] = features(I);
%volumeSlide(F)

%% Create classifier


pos = find(L > 0);
[posx, posy] = find(L > 0);
Training = zeros(numel(pos), size(F,3));
Labels = zeros(numel(pos), 1);
for kk = 1:numel(pos)
    px = posx(kk);
    py = posy(kk);
    Training(kk, :) = squeeze(F(px, py, :))';
    Labels(kk) = L(pos(kk));
end

nTrees = 50;
Mdl = TreeBagger(nTrees, Training, Labels, 'Method', 'classification');

classification = Mdl.predict(Training);
class = cellfun(@(x) str2num(x), classification);
plot(Labels, class)
fprintf('%.0f / %.0f training pixels classified correctly\n', sum(Labels==class), numel(Labels));

%% Classify remaining pixels
Q = reshape(F, [size(F,1)*size(F,2), size(F,3)]);
classification = Mdl.predict(Q);
class = cellfun(@(x) str2num(x), classification);
class = reshape(class, size(I));

figure, imagesc(class)

H = 0.6*ones(size(I));
S = class == 2;
V = double(I)./double(max(I(:)));
V(class==2) = 1;
rgbImage = hsv2rgb(H, S, V);
imshow(rgbImage);

imwrite(rgbImage, 'pixelClassifier.png')
