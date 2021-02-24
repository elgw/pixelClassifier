function L = px_cleanup(classname, imagename)

% Clean up a segmentation/ make it ready for nuclei statistics
outname_rgb = sprintf('%s.clean_rgb.png', imagename);
outname_binary = sprintf('%s.clean_binary.png', imagename);

I = df_readTif(imagename);
I = max(I, [], 3);
I = double(I);
I = I/max(I(:));

class = imread(classname);

%% Clean up classification
nuclei = (class == 2);
nuclei2 = bwpropfilt(nuclei, 'Area', [81, 1000*1000]);

% TODO: Only accept holes up to a certain size
if 0
fprintf('Filling holes')
nuclei3 = imfill(nuclei2, 'holes');
else
fprintf('Not filling holes')
nuclei3 = nuclei2;
end

d = bwdist(~nuclei3);
d = imdilate(d, strel('disk', 5));
d = -d;
d(~nuclei3) = Inf;

L = watershed(d);
L(~nuclei3) = 0;

fprintf('Writing binary image %s\n', outname_binary);
imwrite(L>0, outname_binary);

figure, imagesc(L>0)
title('Cleaned up mask')

if 0 % solid nuclei
    H = 0.6*ones(size(I));
    S = (class == 2);
    V = double(I)./double(max(I(:)));
    V(class==2) = 1;
else % edges
    bedge = L - imerode(L, strel('disk', 1));
    bedge = bedge ~= 0;
    H = 0.4*ones(size(I));
    S = double(bedge);
    V = double(I)./double(max(I(:)));
    V(bedge==1) = 1;
end
rgbImage = hsv2rgb(H, S, V);
imshow(rgbImage);

fprintf('Writing RGB image %s\n', outname_rgb);
imwrite(rgbImage, outname_rgb);

end