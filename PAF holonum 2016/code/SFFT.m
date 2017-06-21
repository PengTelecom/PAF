function [ Uf ] = SFFT( Img, Lo, lambda, zo)
%S-FFT (utilisé quand la distance de diffraction est grande). Cet algorithme donne une image reconstruite qui ne prend pas tout l'écran.
%* *Img* est la matrice 2D qui correspond à l'image. Les coefs de la matrice
%correspondent à l'intensité lumineuse sur  1 octet.(pasde couleur !)
%* *Lo* est la taille désirée de Img en m (indépendamment du nb de pixels)

% Toutes les unités sont en metres (U.S.I)
k=2*pi/lambda; % vecteur d'onde

Img=imread('outWRP.png');% il semble que passer l'image en argument n'est pas terrible.

% On fait un 0-padding de l'image liée à la matrice Img. Le but est juste d'en faire un carré. 
[M,N] = size(Img);
if mod(M,2)==1
    Img=[Img,zeros(M,1)];
end
if mod(N,2)==1
    Img=[Img;zeros(N,1)];
end
[M,N] = size(Img);
Max=max(M,N);
Z1 = zeros(Max, (Max-N)/2);
Z2 = zeros((Max-M)/2,N);
Img_padd = [Z1,[Z2;Img;Z2],Z1]; %[;] fait une concaténation sur les lignes. [,] fait une concaténation sur les colonnes.

%zmin est la distance minimale entre le CCD et l'image reconstituée pour que le théorème de Shannon soit vérifié. 
%Le calcul est optimisé par rapport à lambda et à l'échantillonage (nb de pixels maximal du CCD), (p.85 du livre en Anglais)
zmin= Lo^2/(Max*lambda);
fprintf('La valeur de z0 doit être supérieure à %f \n', zmin);

Uo = double(Img_padd);%Uo = Champ des amplitudes complexes liées à Img_padd, la précision de chaque coef passe de 1 octet à 2 octets

%affichage de l'image avec padding
%figure(2), imagesc(real(Img_padd)), colormap(gray); 
axis equal;
axis tight;
ylabel('pixels');
xlabel(['Côté de l''image d''origine = ', num2str(Lo),'m']);
title('Champ des amplitudes de l''image originale');

%%%%%%%%%%%%%%%%%%%%%
%Calcul de la S-FFT
n=0:(Max-1); %vecteur avec des entiers compris entre 1 et Max correspondant aux pixels sur l'axe X
%pasX = pasY = Lo/Max = taille de chaque pixel.
x= -Lo/2 + Lo*n/Max; % coordonnées en x comprises entre -Lo/2 et Lo/2 par incréments d'1 pasX sur l'image d'origine
y=x;
%Soit une fonction z= f(x,y) (où z, x, y sont des réels). On veut exécuter ce calcul pour une série de points répartis dans le plan (x,y) et obtenir 
%les résultats comme une matrice dont le coefficient [i,j] est z =f(Xi,Yj).
%Pour cela, il suffit de créer une meshgrid [xx,yy]=meshgrid(-Max:1:Max,-Max:1:Max), et d'écrire zz= f(xx,yy).
[xx,yy]=meshgrid(x,y);
propag= exp(1i*k/2/zo*(xx.^2 +yy.^2));% le.^2 fait le carré pour chaque coef et non pas la multiplication de matrices xx*xx.
tmp= Uo.*propag;
Uf=fft2(tmp,Max,Max);
Uf=fftshift(Uf);
L=lambda*abs(zo)*N/Lo;
fprintf('Normalement L=Lo cf. livre qui doit être calculé en fonction du n : Lo=L=(zo*lambda*largeurdelimage)^0.5\n');
x= -Lo/2 + Lo*n/Max; % coordonnées en x comprises entre -Lo/2 et Lo/2 par incréments d'1 pasX sur l'image restituée.
y= x;
[xx,yy]=meshgrid(x,y);
phase=exp(1i*k*zo)/(1i*lambda*zo)*exp(1i*k/2/zo*(xx.^2+yy.^2));
Uf=Uf.*phase;

%affichage de l'image après propagation
Intensite=abs(Uf);
figure(3), imagesc(Intensite), colormap(gray); 
axis equal;
axis tight;
ylabel('pixels');
xlabel(['Côté de l''image d''origine = ', num2str(L),'m']);
title(['Champ des amplitudes de l''image diffractée après  par S-FFT sur la distance z = ',num2str(zo),' m']);
end

