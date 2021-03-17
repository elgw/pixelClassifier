
fmask = '/home/erikw/code/pixelClassifier/iXZ060/training_image.tif.clean_rgb.png';
fmask = '/home/erikw/code/pixelClassifier/iXZ060/training_image.tif.clean_binary.png'
fim1 = '/srv/backup/jobb/MYC FISH FFPE/iXZ060_20210203_004_25x/correct_dw/max_dw_dapi_001.tiff'
fim2 = '/srv/backup/jobb/MYC FISH FFPE/iXZ060_20210203_004_25x/correct_dw/max_dw_cy5_001.tiff'

mask = imread(fmask);
im1 = df_readTif(fim1);
im2 = df_readTif(fim2);


L = mask > 0;
bedge = L - imerode(L, strel('disk', 1));
bedge = bedge ~= 0;

H = 0.4*ones(size(im1));
S = double(bedge);
V = 2*double(im1)./double(max(im1(:)));
V(V>1) = 1;

H(bedge==1) = 0.4;
V(bedge==1) = 1;
figure, imshow(hsv2rgb(H, S, V));

% Add the dots
H2 = 0*im2;
S2 = 1 + 0*im2;
V2 = 2*im2/max(im2(:));
V2(V2>1) = 1;
figure, imagesc(hsv2rgb(H2,S2,V2))


RGB = hsv2rgb(H, S, V) + hsv2rgb(H2, S2, V2);
imshow(RGB)

imwrite(RGB, 'iXZ060_001.png')
