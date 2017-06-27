
clear all;
close all;

lambda = 633*10^-9;		%longeur d'onde du laser (en m)
k = 9.9260e+06;		    %vecteur d'onde (en m^-1)
pas_pixel = 8*10^-6;	  %pas de la plaque SLM (en m)
w=1920;                          %largeur de la plaque SLM (en pixels)
h=1080;                           %longueur de la plaque SLM (en pixels)
L=h*pas_pixel;               %On calcule la largeur en mètres du SLM. A partir de maintenant, pour utiliser les calculs du livre, on considère le SLM carr?de taille L^2.
Lo=L;                               % taille totale (en m) du WRP. Ce paramètre est optimal d'après le livre (p.85)


dwrp_slm=4*Lo*L/(lambda*h); %distance entre le plan du WRP et le plan du SLM (Equation 5.20 p.173 du livre anglais).
pixel_WRP = 640;
dob_wrp = 0.5
% dob_wrp=dwrp_slm *  pixel_WRP/ (h - pixel_WRP) ;               


WRP = cube_WRP(dob_wrp,800,0.6,24000,0,0,30,0,0,0,pixel_WRP);
WRPpadding = zeros(1080,1080); %on ajoute 0 padding(ou padding de l'intensite a0 par ones(1080,1080))
WRPpadding((1080-pixel_WRP)/2+1:(1080+pixel_WRP)/2, (1080-pixel_WRP)/2+1:(1080+pixel_WRP)/2) = WRP;

% WRPpadding = 50*ones(1920,1920);
% WRPpadding((1920-pixel_WRP)/2+1:(1920+pixel_WRP)/2, (1920-pixel_WRP)/2+1:(1920+pixel_WRP)/2) = WRP;



%%%%%%%%%%%%%%
%%%  DFFT  %%%
%%%%%%%%%%%%%%
tic;
[ny, nx] = size(WRPpadding); 

Lx = pas_pixel * nx;
Ly = pas_pixel * ny;

dfx = 1./Lx;
dfy = 1./Ly;

u = ones(nx,1)*((1:nx)-nx/2)*dfx;    
v = ((1:ny)-ny/2)'*ones(1,ny)*dfy;   

UO = fftshift(fft2(WRPpadding));

H = exp(1i*k*(u.^2+v.^2)/(2*dwrp_slm));  

Uf = exp(1i * k * dwrp_slm).* ifft2(UO.*H)./(1i * lambda * dwrp_slm); 
toc;


figure(1)
imshow(WRP);

figure(2)
imshow(Uf);