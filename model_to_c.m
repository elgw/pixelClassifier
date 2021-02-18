function model_to_c(MdlFile)
MdlFile = 'Mdl_ieg728_20x.mat';
load(MdlFile)

% Purpose:
% Create c-code from a TreeBagger model

fid = fopen('trees.c', 'w');

trees = Mdl.Trees;
ntrees = numel(trees);

for kk = 1:ntrees
    genCode(Mdl, kk, fid);
end

fprintf(fid, 'double tree_class(double * X)\n');
fprintf(fid, '{\n');
fprintf(fid, 'double sum = 0;\n');

for kk = 1:ntrees
    fprintf(fid, 'sum += tree%d(X);\n', kk);
end

fprintf(fid, 'return sum / %.1f;\n', ntrees);
fprintf(fid, '}\n');

fclose(fid);

mex -O cMdl.c

fprintf('You can now classify with C = cMdl(F) where F contains one column per pixel\n');

end

function genCode(Mdl, n, fid)
tree = Mdl.Trees{n};

% tree.view() % a string representation
% tree.parent
% tree.children
% tree.CutPoint % Where the cut point is ( < is always used )
% tree.CutPredictor % What variable
% tree.CutType % Empty or 'continuous'
% tree.IsBranchNode % Branching or end
% tree.NodeClass % '1' or '2' cell


fprintf(fid, 'int tree%d(double * x)\n', n);
fprintf(fid, '{\n');

for kk = 1:tree.NumNodes    
    isBranch = tree.IsBranchNode(kk);
    fprintf(fid, 'node%d: ', kk);
    class = tree.NodeClass(kk);
    class = str2num(class{1});
    predictor = tree.CutPredictor(kk);
    predictor = predictor{1};
    predictor = str2num(predictor(2:end));
    pred = sprintf('x[%d]', predictor-1);
    child = tree.Children(kk, :);
    cut = tree.CutPoint(kk);
if(isBranch)
    fprintf(fid, 'if( %s < %f ){ goto node%d; } else { goto node%d; }\n', pred, cut, child(1), child(2));
else
    fprintf(fid, 'return(%d);\n', class);
end
end
fprintf(fid, '}\n\n');

end