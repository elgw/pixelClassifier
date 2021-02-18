function px_gen_classifier(image, labels, outname)
% Pixel classification of a 2D image
% with a label image where 0=unlabelled

I = df_readTif(image);
L = imread(labels);

%% Calculate Features
[F, Fnames] = px_features_2d(I);
%volumeSlide(F)

%% Extract the training data from the image
pos = find(L > 0);
[posx, posy] = find(L > 0);
Training = reshape(F, [size(F,1)*size(F,2), size(F,3)]);
Training = Training(pos, :);
Labels = double(L(pos));

%% Configure and create the classifier
nTrees = 51;
Mdl = TreeBagger(nTrees, Training, Labels, 'Method', 'classification');
fprintf('Saving classifier to %s\n', outname);
save(outname, 'Mdl')

% Classify the training data to see that all is fine
classification = Mdl.predict(Training);
class = cellfun(@(x) str2num(x), classification);


fprintf('%.0f / %.0f training pixels classified correctly\n', sum(Labels==class), numel(Labels));
end

function removeme
%% Classify all pixels of the image
Q = reshape(F, [size(F,1)*size(F,2), size(F,3)]);
classification = Mdl.predict(Q);
class = cellfun(@(x) str2num(x), classification);
class = reshape(class, size(I));
clear Q

figure, imagesc(class), axis image
title('Classification result')

if 0 % solid nuclei
    H = 0.6*ones(size(I));
    S = (class == 2);
    V = double(I)./double(max(I(:)));
    V(class==2) = 1;
else % edges
    bedge = edge(double(class>1), 'canny');
    H = 0.4*ones(size(I));
    S = double(bedge);
    V = double(I)./double(max(I(:)));
    V(bedge==1) = 1;
end
rgbImage = hsv2rgb(H, S, V);
imshow(rgbImage);

imwrite(rgbImage, 'pixelClassifier2_edge.png')
end