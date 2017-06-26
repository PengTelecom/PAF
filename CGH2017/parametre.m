clear all
close all
rho=1;
lambda = 633*10^-9;		%longeur d'onde du laser (en m)
k = 9.9260e+06		    %vecteur d'onde (en m^-1)
pas_pixel = 8*10^-6;	  %pas de la plaque SLM (en m)
w=1920;                          %largeur de la plaque SLM (en pixels)
h=1080;                           %longueur de la plaque SLM (en pixels)
L=h*pas_pixel;               %On calcule la largeur en mètres du SLM. A partir de maintenant, pour utiliser les calculs du livre, on considère le SLM carr?de taille L^2.
Lo=L;                               % taille totale (en m) du WRP. Ce paramètre est optimal d'après le livre (p.85)


z0=rho*4*Lo*L/(lambda*h);          %distance entre le plan du WRP et le plan du SLM (Equation 5.20 p.173 du livre anglais).
zr=inf;                                             %distance entre le point source de l'onde sphérique de référence et le plan du SLM.        Cette onde est virtuelle zr=inf correspond en fait ?une onde plane.
zc=inf;                                            %distance entre le point source de l'onde sphérique de reconstruction et le plan du SLM. Cette onde est réelle zc=inf correspond en fait ?une onde plane.
zi=-1/(1/z0 + 1/zc - 1/zr);              %distance entre le plan du SLM et le plan de l'image reconstruite.                                      Ce calcul permet d'avoir une image nette dans le plan de reconstruction
Gi= -zi/z0;                                       %Grossissement de l'image recosntruite(Gy dans le livre)

d=0.1;         %!!!!!!                        % Distance entre le 1er plan de l'objet3D M et le WRP.                                                       %%%%Comment le choisir ???
N=closerp2(Lo^2/(lambda*z0));    % Largeur totale en pixels du plan WRP.  N doit être une puissance de 2 pour améliorer l'algorithme de la FFT.
%pas_px_wrp = Lo/N;                       % taille d'un pixel sur le plan WRP.

Li=rho*4*Gi*Lo;                            %Largeur du plan de l'image reconstruite (Equation 5.19 p.173 du livre anglais). L'image reconstruite en elle-même est plus petite.
%Li=lambda*z0*w/L;%même résultat que ci-dessus. Quelles expression est la meilleure?
%Calcul de Lw, la largeur de la partie utile du WRP. (On complète le pland du WRP avec des zéros (0-padding) pour occuper toute la longueur Lo)
Lw= d*lambda/sqrt((L/h)^2-(lambda^2)/4); %calcul qui tient compte de la diffraction angulaire
%ou bien : il faudra choisir.
%Lw= L*(d+Nm*pm)/(d+Nm*pm+z0);%Calcul qui tient compte de la profondeur du cube (puis th de Thalès, cf. schéma dans le rapport)

Nm= 50;                                       % Nombre de points utilisés pour générer l'objet 3D Si M n'est pas déj?une matrice. (arbitraire. Plus c'est élev? plus l'image 3D est continue. influe seulement sur le temps de calcul). Mais il  y  a un seuil pour respecter Shannon.
Lm=Lo;                                         %Largeur du cube contenant l'objet 3D Si M n'est pas déj?une matrice. (arbitraire. Plus c'est élev? plus l'image 3D est continue. influe seulement sur le temps de calcul).
pm= Lm/Nm;                               % Nombre de points utilisés pour générer l'objet 3D Si M n'est pas déj?une matrice. (le choix de pm donc de Lw est un peu arbitraire).
paddm = floor(Nm*0.1);             % Espace entre les bord du cube de côt?Nm contenant l'objet 3D et celui-ci, si M n'est pas déj?une matrice. (arbitraire, mais peut permettre de centrer et rétrécir l'objet en même temps sur l'image recostruite. A tester).