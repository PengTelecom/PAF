function [ object ] = shape3D( shape, N, padding, pas_pixel)
%Sert ?g�n�rer un objet 3D comme une matrice de points. Cela sert dans HolocubeV15 pour calculer les amplitudes complexes du plan objet.
%* *shape* soit _'cube'_, soit  _'sphere'_, soit'Z= f(X,Y)' (en rempla�ant * par .* et ^ par .^ dans ce dernier cas), soit '_cercle'_ soit _'carre'_ soit _'carrevide'_ soit _'pt'_ soit _'2pts'_, soit _'pdd'_ (points devant-derri�re)
%* *N* l'objet est contenu dans un cube de taille N^3 pixels. Il y a souvent moins de points. N doit �tre pair.
%* *padding* d�crit le nombre de pixels laiss�s libres au bord du cube N^3 pour que la shape soit inscrit dedans avec des "marges"
%* *pas_pixel* influe sur la fen�tre dans laquelle on �value la fonction.
%* *rot*=['axis','phi'] o?axis est dans {'x','y','z'} et phi est un angle en radian. Cela permet de changer l'angle de vue de la figure par une rotration de phi autour de l'axe s�lectionn?

% L'origine des figures est toujours dans un coin du cube de taille N^3. Les coordonn�es sont donc toujours positives dans les figures donn�es ici.
%Attention on devra peut-�tre modifier le fen�trage des fonctions pour obtenir des objets sans "trous" (exemple de la sph�re).

rot=['x','0'];%il faudrait en fait que rot soit un argument de la fonction, mais nous n'avons pas encore int�gr?cela au programme.

if mod(N,2)~=0;
    fprintf('La valeur du param�tre N dans la fonction shape3D doit �tre paire ! \n')
    return
end

switch shape %le switch en matlab ne marche pas comme le switch en C. Notamment les breaks sont inutiles.
    case 'cube'
        object = zeros((N-2*padding)*4+(N-2*padding-2)*8,3);% Nombre de points=pixels qui repr�sentent le cube (12 arr�tes. Il y a 8 points qu'on compte 2 fois car il  y a 8 sommets)       
        dim_side = (N-2*padding); % Taille d'une ar�te en points=pixels.
        for m = 1 : 1 : dim_side
            %on remplit les coordonn�es des ar�tes qui sont sur l'axe Z
            object(m,           :) = [padding+1, padding+1, m+padding];%coordonn�es en pixels des points de l'arr�te 0 (cf. sch�ma correspondant dans le rapport)
            object(m+1*dim_side,:) = [N-padding, padding+1, m+padding];%coordonn�es en pixels des points de l'ar�te 1 (cf. sch�ma correspondant dans le rapport)
            object(m+2*dim_side,:) = [padding+1,N-padding, m+padding];%coordonn�es en pixels des points de l'ar�te 2 (cf. sch�ma correspondant dans le rapport)
            object(m+3*dim_side,:) = [N-padding, N-padding, m+padding];%coordonn�es en pixels des points de l'arr�te 3 (cf. sch�ma correspondant dans le rapport)
        end
        dim_side2 = dim_side-2;%(en effet, les 1�re ar�tes trac�es contiennent les 8 sommets du cube. On ne veut pas les r�p�ter : toutes les autres arr�tes n'ont pas de sommets).
        last = 4*dim_side;
        for m = 1 : 1 : dim_side2
            %on remplit les coordonn�es des arr�tes qui sont sur l'axe X
            object(m+last,:) = [m+padding+1, padding+1, padding+1];%coordonn�es en pixels des points de l'ar�te 4 (cf. sch�ma correspondant dans le rapport)
            object(m+last+1*dim_side2,:) = [m+padding+1, padding+1, N-padding];%coordonn�es en pixels des points de l'ar�te 5 (cf. sch�ma correspondant dans le rapport)
            object(m+last+2*dim_side2,:) = [m+padding+1, N-padding, padding+1];%coordonn�es en pixels des points de l'ar�te 6 (cf. sch�ma correspondant dans le rapport)
            object(m+last+3*dim_side2,:) = [m+padding+1, N-padding, N-padding];%coordonn�es en pixels des points de l'ar�te 7 (cf. sch�ma correspondant dans le rapport)
             %on remplit les coordonn�es des ar�tes qui sont sur l'axe Y
            object(m+last+4*dim_side2,:) = [padding+1, m+padding+1, padding+1];%coordonn�es en pixels des points de l'ar�te 8 (cf. sch�ma correspondant dans le rapport)
            object(m+last+5*dim_side2,:) = [N-padding, m+padding+1, padding+1];%coordonn�es en pixels des points de l'ar�te 9 (cf. sch�ma correspondant dans le rapport)
            object(m+last+6*dim_side2,:) = [padding+1, m+padding+1, N-padding];%coordonn�es en pixels des points de l'ar�te 10 (cf. sch�ma correspondant dans le rapport)
            object(m+last+7*dim_side2,:) = [N-padding, m+padding+1, N-padding];%coordonn�es en pixels des points de l'ar�te 11 (cf. sch�ma correspondant dans le rapport)
        end
        object= pas_pixel*(object-1);%On retourne les coordonn�es en m et non plus en pixels. De plus , on met bien l'orgine ?0 et non ?(1,1).
        
    case 'sphere'
        object = zeros(N^3,3);
        % On place l'origine de la fonction au centre du cube de c�t?N
        xx = (-N/2+1 : 1 : N/2);
        yy = (-N/2+1 : 1 : N/2);
        [X, Y] = meshgrid(xx, yy);
        R=(N/2-padding);% Rayon de la sph�re dont on veut g�n�rer les coordonn�es.
        Z= ( R^2    -   (X.^2  + Y.^2) ).^(1/2); %Equation de la sph�re : Z(k,l) est la valeur en Z  pour (x=k, y=l) qui permet de tracer la demi-sph�re (Z>0).
        m=1;
        for k=xx+N/2
            for l=yy+N/2
                    coef = Z(k,l);
                    if imag(coef)==0
                        object(m,:)=(pas_pixel*[k, l, coef + N/2]);%On remet l'origine en haut ?gauche par l'ajout du N/2 aux coordonn�es.
                        object(m+1,:)=(pas_pixel*[k, l, -coef + N/2]);%On remet l'origine en haut ?gauche par l'ajout du N/2 aux coordonn�es.
                        m = m+2;
                    %else
                    %    Z(k,l)=0;
                    end
            end
        end
     %figure(4),surf(X,Y,Z);%trace la surface correspondant ?la demi-sph�re.
     object = object(1:m-1,:);%On avait allou?trop de m�moire avec la matrice Z�ros au d�but. On retire les points non n�cessaires.
     %On recentre la sph�re dans le plan XY, pour que l'origine soit bien O et non (1,1) (les matrices en matlab commencent ?1).
     object(:,1) = object(:,1)-pas_pixel;
     object(:,2) = object(:,2)-pas_pixel;
     
    case 'tube' %padding conseill?lors de tests . Exemple : shape3D('tube',100,5,0);
        object = zeros(N^3,3);
        R = N/2-padding;% Rayon du cercle du tube dont on veut g�n�rer les coordonn�es
        m=1;
        for xx = (-N/2+1 : 1 : N/2)
            for yy = (-N/2+1 : 1 : N/2)%Pour chaque couple xx yy du plan centr?en O dans une fen�tre de taille N^2
                if abs(xx^2+yy^2-R^2)<= N/3 %Si ce couple v�rifie ?peu pr�t l'�quation d'un cercle.
                    for zz=(-N/2+1 : 1 : N/2) + padding %On enregistre les coordonn�es de ce point pour Z dans toute la profondeur du cube de taille N^3
                        object(m,:)=(pas_pixel*([xx, yy, zz]+N/2));%On remet en plus l'origine en haut ?gauche par l'ajout du N/2 aux coordonn�es.
                        m = m+1;
                    end
                end
            end
        end
        object = object(1:m-1,:);%On avait allou?trop de m�moire avec la matrice Z�ros au d�but. On retire les points non n�cessaires.
        object = object - pas_pixel;% On met bien l'origine en 0 et non en (1,1).

    case 'cercle' %padding conseill?lors de tests . Exemple : shape3D('tube',100,5,0);
        object = zeros(N^2,3);
        R = N/2-padding;% Rayon du cercle du tube dont on veut g�n�rer les coordonn�es
        m=1;
        for xx = (-N/2+1 : 1 : N/2)
            for yy = (-N/2+1 : 1 : N/2)%Pour chaque couple xx yy du plan centr?en O dans une fen�tre de taille N^2
                if abs(xx^2+yy^2-R^2)<= N/3 %Si ce couple v�rifie ?peu pr�t l'�quation d'un cercle.
                        object(m,:)=(pas_pixel*([xx+N/2, yy+N/2, 0]));%On remet en plus l'origine en haut ?gauche par l'ajout du N/2 aux coordonn�es.
                        m = m+1;
                end
            end
        end
        object = object(1:m-1,:);%On avait allou?trop de m�moire avec la matrice Z�ros au d�but. On retire les points non n�cessaires.
        %On recentre le cercle dans le plan XY, pour que l'origine soit bien O et non (1,1) (les matrices en matlab commencent ?1).
       object(:,1) = object(:,1)-pas_pixel;
       object(:,2) = object(:,2)-pas_pixel;
        
    case 'carrevide'
        object = zeros((N-2*padding)*2+(N-2*padding-2)*2,3);% Nombre de points=pixels qui repr�sentent le cube (12 arr�tes. Il y a 8 points qu'on compte 2 fois car il  y a 8 sommets)       
        dim_side = (N-2*padding); % Taille d'une ar�te en points=pixels.
        for m = 1 : 1 : dim_side
            %on remplit les coordonn�es des arr�tes qui sont sur l'axe X
            object(m+0*dim_side,:) = [m+padding, padding+1, 0];%coordonn�es en pixels des points de l'ar�te 5 (cf. sch�ma correspondant dans le rapport)
            object(m+1*dim_side,:) = [m+padding, N-padding, 0];%coordonn�es en pixels des points de l'ar�te 7 (cf. sch�ma correspondant dans le rapport)
             %on remplit les coordonn�es des ar�tes qui sont sur l'axe Y
            object(m+2*dim_side,:) = [padding+1, m+padding, 0];%coordonn�es en pixels des points de l'ar�te 10 (cf. sch�ma correspondant dans le rapport)
            object(m+3*dim_side,:) = [N-padding, m+padding, 0];%coordonn�es en pixels des points de l'ar�te 11 (cf. sch�ma correspondant dans le rapport)
        end
        object= pas_pixel*object;%On retourne les coordonn�es en m et non plus en pixels.
        
    case 'carre'       
        dim_side = (N-2*padding); % Taille d'une ar�te en points=pixels.
        object = zeros(dim_side^2,3);% Nombre de points=pixels qui repr�sentent le cube (12 arr�tes. Il y a 8 points qu'on compte 2 fois car il  y a 8 sommets)
        for m = 1 : 1 : dim_side     
            for l = 1:1:dim_side
                object(m+(l-1)*(dim_side),:) = [padding+l-1, m+padding-1, 0];
            end
        end
        object= pas_pixel*object;%On retourne les coordonn�es en m et non plus en pixels.
        
    case 'pt'
        object=[floor(N/2), floor(N/2), 0];
        object= pas_pixel*object;%On retou2ptsrne les coordonn�es en m et non plus en pixels.
        
    case 'ptdd'
        object=[[floor(N/2), floor(N/2), 0];[floor(N/2), floor(N/2), floor(N/2)]];
        object= pas_pixel*object;%On retou2ptsrne les coordonn�es en m et non plus en pixels.
        
    case '2pts'
        object=[[floor(N/3), floor(N/2), 0];[floor(2*N/3), floor(N/2), 0]];
        object= pas_pixel*object;%On retourne les coordonn�es en m et non plus en pixels.
        
    otherwise
        %expression = input('Quelle fonction voulez-vous tracer ?\n   Z=f(X,Y) =  ','s');
        
        %tester cette fonction en tapant lors de l'input :'(12*cos((X.^2+Y.^2)/4))./(3+X.^2+Y.^2)' et
        %en r�glant N=50 pour les valeurs de pas_pixel dans {0.5;1;5}
        %Attention, si Z=f(X,Y), les produits se notent .* et les exposants .^ dans l'espace es matrices pour faire du calcul point ?point.
        
        object = zeros(N^3,3);
        % On place l'origine de la fonction au centre du cube de c�t?N
        xx = (-N/2+1 : 1 : N/2);
        yy = (-N/2+1 : 1 : N/2);
        [X, Y] = meshgrid(xx, yy);
        X = pas_pixel*X;%ignorer le warning
        Y=pas_pixel*Y;%ignorer le warning
        Z=eval(shape);%dans "shape" rentr�e en param�tre de la fonction shape3D doivent appara�tre X et Y (c'est pour �a qu'on a un warning au-dessus)
        m=1;
        for k=xx+N/2
            for l=yy+N/2
                    coef = Z(k,l)/pas_pixel;
                    if imag(coef)==0
                        object(m,:)=(pas_pixel*[k, l, coef + N/2]);%On remet l'origine en haut ?gauche par l'ajout du N/2 aux coordonn�es.
                        m = m+1;
                   % else
                    %    Z(k,l)=0;
                    end
            end
        end
        object = object(1:m-1,:);%On avait allou?trop de m�moire avec la matrice Z�ros au d�but. On retire les points non n�cessaires.
end

% Rotation de la figure obtenu en fonctin de l'argument rot.
%Extraction des valeurs de phi et axis.
axis = rot(:,1);
phi = str2double(rot(:,2));
%calcul de la matrice de rotation correspondante.
switch axis
    case 'x'
        omega=[[1 0 0];[0 cos(phi) -sin(phi)];[0 sin(phi) cos(phi)]];
    case 'y'
        omega=[[cos(phi) 0 sin(phi)];[0 1 0];[-sin(phi) 0 cos(phi)]];
    case 'z'
        omega=[[cos(phi) -sin(phi) 0];[sin(phi) cos(phi) 0];[0 0 1]];
    otherwise
        omega=ones(3,3);
        fprintf('?cause d''un probl�me dans les param�tres de la rotaion dans shape3D, on a �x�cut?aucune rotation');
end
object = object*transpose(omega); %Il s'agit bien d'une multiplication matricielle pour la rotation. la notation"A.'" permet de faire la transpos�e.
%Remettre les coordon�es en positif.
%Recentrer l'origine.

%figure(6),surf(X,Y,Z);
figure(1),scatter3(object(:,1), object(:,2), object(:,3));% On trace la fonction ?partir des coordonn�es ainsi trouv�es.
set(gca,'DataAspectRatio',[1,1,1]);% A commenter lorsqu'on veut visualiser par exemple 'X.*Y' car alors l'axe en Z ne doit pas �tre ?la m�me �chelle que les autres axes pour avoir une vue int�ressante.
end

