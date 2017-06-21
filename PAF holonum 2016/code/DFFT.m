function [ Uf ] = DFFT( Img, Lo, lambda, zo)
%S-FFT
%* *Img* est la matrice 2D qui correspond à l'image. Les coeffs de la matrice
%correspondent à l'intensité lumineuse sur  1 octet.(pas de couleur !)
%* *Lo* est la taille désirée de Img en m (indépendamment du nb de pixels)

% Toutes les unités sont en m (U.S.I)
k=2*pi/lambda; % vecteur d'onde

Img=imread('outWRP.png');%test car il semble que passer l'image en argument n'est pas terrible.

% On fait un 0-padding de l'image liée à la matrice Img. Le but est juste d'en faire un carré. 
%Pour cela on commence par s'assurer que que les nombres de pixels en largeur
%et hauteur sont pairs.
[M,N] = size(Img);
if mod(M,2)==1
    Img=[Img,zeros(N,1)];
end
if mod(N,2)==1
    Img=[Img,zeros(M,1)];
end
%Ensuite on fait le padding proprement dit.
[M,N] = size(Img);
Max=max(M,N);
Z1 = zeros(Max, (Max-N)/2);
Z2 = zeros((Max-M)/2,N);
Img_padd = [Z1,[Z2;Img;Z2],Z1]; %[;] fait une concaténation sur les lignes. [,] fait une concaténation sur les colonnes.

%zmax est la distance maximale entre le CCD et l'image reconstituée pour que le théorème de Shannon soit vérifié. 
%Le calcul est optimisé par rapport à lambda et à l'échantillonage (nb de pixels maximal du CCD), (p.89 du livre en Anglais)
zmax= Lo^2/(Max*lambda);
fprintf('La valeur de z0 doit être inférieure à %f cm\n', zmax*10^2);

Uo = Img_padd;%Uo = Champ des amplitudes complexes liées à Img_padd, la précision de chaque coef passe de 1o à un double

%Affichage de l'image avec padding
figure(2), imagesc(real(Img_padd)), colormap(gray); 
axis equal;
axis tight;
ylabel('pixels');
xlabel(['Côté de l''image d''origine = ', num2str(Lo),'m']);
title('Champ des amplitudes de l''image originale');

%%%%%%%%%%%%%%%%%%%%%
%Calcul de la D-FFT
Uf=fft2(Uo,Max,Max);
Uf= fftshift(Uf);
fex=Max/Lo;
fey=fex;
fx=[-fex/2 : fex/Max : fex/2-fex/Max];
fy=[-fey/2 : fey/Max : fey/2-fey/Max];
[FX,FY]=meshgrid(fx,fy);
G=exp(1i*k*zo*sqrt(1-(lambda*FX).^2-(lambda*FY).^2));
result=Uf.*G;
Uf=ifft2(result,Max,Max);
%Fin de calcul de la D-FFFT
%%%%%%%%%%%%%%%%%%%%%%%


%Affichage de l'image après propagation
Intensite=abs(Uf);%real ou abs ?(ça inverse les bandes d'ombres et de lumière selon que l'on prend l'un ou l'autre).
figure(3), imagesc(Intensite), colormap(gray); 
axis equal;
axis tight;
ylabel('pixels');
xlabel(['Côté de l''image d''origine = ', num2str(Lo),'m']);
title(['Champ des amplitudes de l''image diffractée après calcul par D-FFT sur la distance ',num2str(zo),'m']);
end

