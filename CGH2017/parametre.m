clear all;
close all;

lambda = 633*10^-9;		%longeur d'onde du laser (en m)
k = 9.9260e+06;		    %vecteur d'onde (en m^-1)
pas_pixel = 8*10^-6;	  %pas de la plaque SLM (en m)
w=1920;                          %largeur de la plaque SLM (en pixels)
h=1080;                           %longueur de la plaque SLM (en pixels)
L=h*pas_pixel;               %On calcule la largeur en mètres du SLM. A partir de maintenant, pour utiliser les calculs du livre, on considère le SLM carr?de taille L^2.
Lo=L;                               % taille totale (en m) du WRP. Ce paramètre est optimal d'après le livre (p.85)


dwrp_slm=4*Lo*L/(lambda*h);          %distance entre le plan du WRP et le plan du SLM (Equation 5.20 p.173 du livre anglais).
zr=inf;                                             %distance entre le point source de l'onde sphérique de référence et le plan du SLM.        Cette onde est virtuelle zr=inf correspond en fait ?une onde plane.
zc=inf;                                            %distance entre le point source de l'onde sphérique de reconstruction et le plan du SLM. Cette onde est réelle zc=inf correspond en fait ?une onde plane.
zi=-1/(1/dwrp_slm + 1/zc - 1/zr);              %distance entre le plan du SLM et le plan de l'image reconstruite.                                      Ce calcul permet d'avoir une image nette dans le plan de reconstruction
Gi= -zi/dwrp_slm;                                       %Grossissement de l'image recosntruite(Gy dans le livre)

dob_wrp=0.1;         %!!!!!!                        % Distance entre le 1er plan de l'objet3D M et le WRP.                                                       %%%%Comment le choisir ???
