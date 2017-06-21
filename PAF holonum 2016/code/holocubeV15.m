function [ SLM ] = holocubeV15( M, rho)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%%  Ce programme reprend holocubeV14. Le but est de produire l'image qui sera affich�e sur le capteur LCD qu'on va diffracter avec le laser (= onde de r�f�rence)
%
% * *M* est l'objet d'origine. On entre une matrice de taille (Nombredepointsdel'objet,3), o� les colonnes sont les coordonn�es  des points (x,y,z), l'origine �tant prise en haut � gauche de l'image (consid�rer "dans un coin" pour les images sym�triques)
On pourra aussi tester directement avec les arguments 'cube', 'tube', 'sphere', 'pt', etc..
%* *rho* est un param�tre >=1

Toutes les unit�s sont celles du Syst�me International ( en gros pas de mm).
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda = 633*10^-9;		%longeur d'onde du laser (en m)
k = 2*pi/lambda;		    %vecteur d'onde (en m^-1)
pas_pixel = 8*10^-6;	  %pas de la plaque SLM (en m)
w=1920;                          %largeur de la plaque SLM (en pixels)
h=1080;                           %longueur de la plaque SLM (en pixels)
L=h*pas_pixel;               %On calcule la largeur en m�tres du SLM. A partir de maintenant, pour utiliser les calculs du livre, on consid�re le SLM carr� de taille L^2.
Lo=L;                               % taille totale (en m) du WRP. Ce param�tre est optimal d'apr�s le livre (p.85)


z0=rho*4*Lo*L/(lambda*h);          %distance entre le plan du WRP et le plan du SLM (Equation 5.20 p.173 du livre anglais).
zr=inf;                                             %distance entre le point source de l'onde sph�rique de r�f�rence et le plan du SLM.        Cette onde est virtuelle zr=inf correspond en fait � une onde plane.
zc=inf;                                            %distance entre le point source de l'onde sph�rique de reconstruction et le plan du SLM. Cette onde est r�elle zc=inf correspond en fait � une onde plane.
zi=-1/(1/z0 + 1/zc - 1/zr);              %distance entre le plan du SLM et le plan de l'image reconstruite.                                      Ce calcul permet d'avoir une image nette dans le plan de reconstruction
Gi= -zi/z0;                                       %Grossissement de l'image recosntruite(Gy dans le livre)

d=z0/5;         %!!!!!!                        % Distance entre le 1er plan de l'objet3D M et le WRP.                                                       %%%%Comment le choisir ???
N=closerp2(Lo^2/(lambda*z0));    % Largeur totale en pixels du plan WRP.  N doit �tre une puissance de 2 pour am�liorer l'algorithme de la FFT.
%pas_px_wrp = Lo/N;                       % taille d'un pixel sur le plan WRP.

Li=rho*4*Gi*Lo;                            %Largeur du plan de l'image reconstruite (Equation 5.19 p.173 du livre anglais). L'image reconstruite en elle-m�me est plus petite.
%Li=lambda*z0*w/L;%m�me r�sultat que ci-dessus. Quelles expression est la meilleure?
%Calcul de Lw, la largeur de la partie utile du WRP. (On compl�te le pland du WRP avec des z�ros (0-padding) pour occuper toute la longueur Lo)
Lw= d*lambda/sqrt((L/h)^2-(lambda^2)/4); %calcul qui tient compte de la diffraction angulaire
%ou bien : il faudra choisir.
%Lw= L*(d+Nm*pm)/(d+Nm*pm+z0);%Calcul qui tient compte de la profondeur du cube (puis th de Thal�s, cf. sch�ma dans le rapport)

Nm= 50;                                       % Nombre de points utilis�s pour g�n�rer l'objet 3D Si M n'est pas d�j� une matrice. (arbitraire. Plus c'est �lev�, plus l'image 3D est continue. influe seulement sur le temps de calcul). Mais il  y  a un seuil pour respecter Shannon.
Lm=Lo;                                         %Largeur du cube contenant l'objet 3D Si M n'est pas d�j� une matrice. (arbitraire. Plus c'est �lev�, plus l'image 3D est continue. influe seulement sur le temps de calcul).
pm= Lm/Nm;                               % Nombre de points utilis�s pour g�n�rer l'objet 3D Si M n'est pas d�j� une matrice. (le choix de pm donc de Lw est un peu arbitraire).
paddm = floor(Nm*0.1);             % Espace entre les bord du cube de c�t� Nm contenant l'objet 3D et celui-ci, si M n'est pas d�j� une matrice. (arbitraire, mais peut permettre de centrer et r�tr�cir l'objet en m�me temps sur l'image recostruite. A tester).

%Si M est une forme particuli�re (string entr�e en param�tre) et non une matrice en entr�e de la fonction, 
%on fait une disjonction des cas pour choisir arbitrairement un padding qui donne un bon r�sultat.
if isa(M,'char')
    switch M
         case 'cube'
             M=shape3D( 'cube', Nm, paddm*2, pm);
        case 'tube'
            M=shape3D( 'tube', Nm, paddm*2, pm);
        case 'sphere'
            M=shape3D( 'sphere', Nm, paddm*2, pm);
        case 'pt'
            M=shape3D( 'pt', Nm, 0, pm);
        case '2pts'
            M=shape3D( '2pts', Nm, 0, pm);
        case 'ptdd'
            M=shape3D( 'ptdd', Nm, 0, pm);
        case 'carre'
            M=shape3D( 'carre', Nm, paddm*3, pm);
        case 'carrevide'
            M=shape3D( 'carrevide', Nm, paddm, pm);
        case 'cercle'
            M=shape3D( 'cercle', Nm, paddm*3, pm);
        otherwise
            if strcmp(M(1:3),'img')
                M=imgpts(M(4:size(M,2)), Nm, paddm, pm);
            else
                M=shape3D( M, N, paddm, pm);
            end
    end
end

if size(M,2) ~= 3 %Si la matrice M ne colle pas avec notre repr�sentation de l'objet 3D � ce stade
    fprintf('Le 1er param�tre de la fonction ne correspond � aucun objet.\n');
    return
end


%recentrage des points de M (d�placement de l'origine en x et y).
M(:,1)=M(:,1)-Lm/2;
M(:,2)=M(:,2)-Lm/2;

% On trace la fonction � partir des coordonn�es de M dans le plan 3D pour bien voir l'objet dont on fait l'hologramme.
figure(1),scatter3(M(:,1), M(:,2), M(:,3));
set(gca,'DataAspectRatio',[1,1,1]);% Pour que le trac� de la figure 1 soit dans un rep�re orhtonorm�

% A ce stade, on a soit l'objet M entr� comme matrice, soit une celle correspondant � la forme demand�e de  taille Lo^2 (m) ou Nm^2 (px).

%Est-ce qu'on retire des points ? (car non visibles)

%On r�cup�re l'objet 2D qui contient la somme des ondes �mises pour tous les points de l'objet � la distance d.

WRP = ob2wrp(M, N, Lw, Lo, d, k); 


%On fait la propagation de Fresnel sur la distance z0
WRP=real(WRP);
imwrite(WRP, 'outWRP.png');
SLM = SFFT( WRP, Lo, lambda, z0);% On pourrait faire un switch case  en fonction de z pour utiliser soit la DFFT soit la SFFT
SLM= real(SLM);
imwrite(SLM, 'outFresnel.png');


fprintf('Largeur du SLM L=%f mm \n',L*10^3);
fprintf('Distance entre le SLM et le WRP z0=%f cm \n',z0*10^2);
fprintf('Distance entre le SLM et le  plan de l''image reconstruite=%f m \n',zi);
fprintf('Taille minimale du plan de l''image reconstruite Li=%f cm \n',Li*10^2);
fprintf('Taille utile en mm du plan du WRP Lw=%f mm \n',Lw*10^3);
fprintf('Taille totale en pixels du plan du WRP N=%d pixels\n',N);

Nw= floor((Lw/Lo)*N/2)*2; %Taille utile en pixels (N inclut les pixels du 0-padding, contrairement � Nw)
fprintf('Taille utile du WRP Nw=%d px \n', Nw);


%Cr�ation du LUT pour les calculs + threads +  GPU?
end

