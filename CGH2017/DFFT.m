function [ Uf ] = DFFT( Img, Lo, lambda, z,pas_pixel)

%* *Img* est la matrice 2D qui correspond ?l'image. Les coeffs de la matrice
%correspondent ?l'intensit?lumineuse sur  1 octet.(pas de couleur !)
%* *Lo* est la taille désirée de Img en m (indépendamment du nb de pixels)
k=2*pi/lambda;
[ny, nx] = size(Img); 

Lx = pas_pixel * nx;
Ly = pas_pixel * ny;

dfx = 1./Lx;
dfy = 1./Ly;

u = ones(nx,1)*((1:nx)-nx/2)*dfx;    
v = ((1:ny)-ny/2)'*ones(1,ny)*dfy;   

O = fftshift(fft2(Img));

H = exp(1i*k*z).*exp(-1i*pi*lambda*z*(u.^2+v.^2));  

Uf = ifft2(O.*H);  

end

