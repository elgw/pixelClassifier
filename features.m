function [F, names] = features(I)
% Create a similar set of features as Ilastic has by default

if ~exist('I', 'var')
    I = rand(100,100)+2;        
    keyboard
end

assert(numel(size(I)) == 2);
I = double(I);

%% Pixel values
F = I;
names = {'pixel'};

sigmas_ilastic = [0.3, 0.7, 1, 1.6, 3.5, 5, 10];
sigmas = sigmas_ilastic;

for kk = 1:numel(sigmas)
    sigma = sigmas(kk);
    %% Gaussian
    G = gsmooth(I, sigma);
    
    F = cat(3, F, G);
    names{end+1} = sprintf('smooth_%.1f', sigma);
    clear G
    
    %% Partial derivatives
    dx = gpartial(I, 1, sigma);
    dy = gpartial(I, 2, sigma);    
    
    dxx = gpartial(dx, 1, sigma);
    dxy = gpartial(dx, 2, sigma);
    dyy = gpartial(dy, 2, sigma);
    
    %% Laplacian of Gaussian
    F = cat(3, F, dxx+dyy);
    names{end+1} = sprintf('LoG_%.1f', sigma);
    %% Gaussian gradient magnitude
    F = cat(3, F, (dx.^2+dy.^2).^(1/2));
    names{end+1} = sprintf('Gaussian_Gradient_Magnitude_%.1f', sigma);
    %% Difference of Gaussians
    % Slipping this one, almost the same as Laplacian of Gaussians
    
    %% Structure tensor eigenvalues
    % [a c ; c b]
    a = dx.*dx;
    c = dx.*dy;
    b = dy.*dy;
    F = cat(3, F, 1/2*(a+b+((a-b).^2 + 4*c.^2).^(1/2)));
    names{end+1} = sprintf('Structure_tensor_ev1_%.1f', sigma);
    F = cat(3, F, 1/2*(a+b - ((a-b).^2 + 4*c.^2).^(1/2)));
    names{end+1} = sprintf('Structure_tensor_ev1_%.1f', sigma);
    clear a
    clear b
    clear c
    
    %% Hessian of Gaussians Eigenvalues
    % [a c ; c b]
    a = dxx;
    c = dxy;
    b = dyy;
    F = cat(3, F, 1/2*(a+b+((a-b).^2 + 4*c.^2).^(1/2)));
    names{end+1} = sprintf('Hessian_ev1_%.1f', sigma);
    F = cat(3, F, 1/2*(a+b - ((a-b).^2 + 4*c.^2).^(1/2)));
    names{end+1} = sprintf('Hessian_ev2_%.1f', sigma);
end


% Normalize
for kk = 1:size(F,3)
    pmax = max(max(F(:,:,kk)));
    if(pmax > 0)
        F(:,:,kk) = F(:,:,kk)/pmax;
    else
        pmin = min(min(F(:,:,kk)));
        if pmin < 0
            F(:,:,kk) = F(:,:,kk)/abs(pmin);
        end
    end
end

end

function partial = gpartial(I, d, sigma)
% Gaussian partial derivative of image I
% along dimension d

% Length of the filter, w
w=round(8*sigma+2); % Width in pixels
if mod(w,2)==0 % Always use a filter with odd number of elements
    w=w+1;
end

% Derivative of gaussian, dg
g = fspecial('gaussian', [w,1], sigma);
x=(-(w-1)/2:(w-1)/2)';
k0=1/sqrt(2*pi*sigma^2); k1=1/(2*sigma^2);
dg=-2*k0*k1.*x.*exp(-k1*x.^2);

if d==1
    filter = reshape(dg, [w,1]);
else
    filter = reshape(dg, [1,w]);
end

partial=convn(I, filter, 'same')./convn(ones(size(I)), filter, 'same');    

end

function G = gsmooth(I, sigma)

% Length of the filter, w
w=round(8*sigma+2); % Width in pixels
if mod(w,2)==0 % Always use a filter with odd number of elements
    w=w+1;
end

% Derivative of gaussian, dg
filter = fspecial('gaussian', [w,1], sigma);
G = I;
G = convn(G, filter, 'same')./convn(ones(size(I)), filter, 'same');    
filter = filter';
G = convn(G, filter, 'same')./convn(ones(size(I)), filter, 'same');    

end