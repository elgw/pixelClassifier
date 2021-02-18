function class = px_classify_region(Mdl, I)
% Classify the image/region in I using Mdl

F = px_features_2d(I);
Q = reshape(F, [size(F,1)*size(F,2), size(F,3)]);


if 1
    warning('Experimental stuff, don''t use!')
    class = cMdl(Q');
    class = reshape(class, size(I));
else 
    classification = Mdl.predict(Q);
    class = cellfun(@(x) str2num(x), classification);
    class = reshape(class, size(I));
end

end