function pts = imgpts(img_name, N, padding, pas_pixel )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

img=imread(['lettres/',img_name,'.png'],'png','BackgroundColor',[1 1 1]); %permet de differencier le fond transparent de la couleur noire
pixels = double(img);
h=size(pixels,1); %hauteur de l'image donnee
w=size(pixels,2); %largeur de l'image donnee
seuil = 128; %on ne prend que les couleurs en-dessous de ce seuil (plus proche du blanc que du noir)
pts=zeros(h*w,3); %preallocation de la memoire avec le pire cas possible : tous les pixels de l'image sont a garder

bar=waitbar(0, 'Début du calcul'); %creation d'une barre de progression
ligne=1;

for i=1:h %parcours des lignes de l'image
    waitbar(i/h,bar,sprintf('Calcul pour ligne = %d sur %d valeurs \n', i, h)) %actualisation de la barre de progression
    for j=1:w %parcours des colonnes de l'image
        if img(i,j)<seuil
            pts(ligne,:)=pas_pixel*[i j -10]; %coordonnees reelles [x y z] de l'image
            ligne=ligne+1;
            pts(ligne,:)=pas_pixel*[i+5 j+5 -14];
            ligne=ligne+1;
        end
    end
end

pts=pts(1:ligne-1,:); %on retire les lignes de 0 non utilisees

delete(bar); %on retire la barre de progression

figure(1),scatter3(pts(:,1), pts(:,2), pts(:,3)); % On trace les points de l'image qu'on a gardes
view(90,90)  % vue X Y adaptee
axis equal
