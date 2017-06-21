%%%%reconstruction de l'hologramme%%%%%%
function [ R ] = Reconst( Img,L, Lo, lambda, zo, Gy,p)

%%% Gy = grandissement 
%%% p = paramétre d'affichage (>1) 
Img=imread(Img);
Ih1 = double(Img);
figure ;
imagesc(Img);
colormap(gray);
axis equal;
axis tight; 
title('Hologramme Numérique');

k=2*pi/lambda;
[N1, N2]= size(Ih1);% taille de l'image
N=min(N1,N2);%% restriction de l'image 
Ih = Ih1(1:N,1:N) - mean2( Ih1(1:N,1:N));%% suppression de la valeur moyenne de l'image d'entrée 
pix=L/N;
%%%%Filtrer l'ordre 0 de l'hologramme 
%pg = input('Filtrer l''ordre 0 de l''hologramme ? Si Oui taper 1 (0/1)'); %A activer si
pg=1;%temporaire cf. ligne ci-dessus.
if pg == 1 ,
    fm = filter2(fspecial('average',3),Ih);
    Ih=Ih-fm;
end 

%%%%%%%%%%%%%%Reconstruction par SFFT%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=-N/2:N/2-1;
x= n*pix;
y=x;
[xx,yy]=meshgrid(x,y);

fresnel = exp(1i*k/2/zo*(xx.^2+yy.^2));
f2=Ih.*fresnel;
Uf=fft2(f2,N,N);
Uf=fftshift(Uf);
ipix=lambda*abs(zo)/N/pix;
xi= n*ipix;
yi=xi;
figure ;
imagesc(xi,yi,abs(Uf).^.75);
colormap(gray);
axis equal;
axis tight; 
title('Ciquer en haut à gauche et en bas à droite sur l''objet');
XY = ginput(2);
%%%%centre et profondeur de l'image
xc=0.5*(XY(1,1)+XY(2,1));
yc=0.5*(XY(1,2)+XY(2,2));
DAX=abs(XY(1,1)-XY(2,1));
DAY=abs(XY(1,1)-XY(2,1));

%%%%Reconstruction à grandissement variable 
Gyi = min(L/DAX,L/DAY);
zi = -Gy*zo ;
zc =1/(1/zo+1/zi);
%% calcul de l'onde sphérique 
sph = exp(1i*k/2/zc*(xx.^2+yy.^2));

%%illuminer l'hologramme par une onde spérique 
f=Ih.*sph; %%multiplier le spectre de l'hologramme par l'onde spférique 
TFUF = fftshift(fft2(f,N,N));
(fft2(f,N,N));
%%% éspace de Fourrier 
du = 1/pix/N;
dv=du ;
fex = 1/pix;
fey = fex; 
fx=[-fex/2:fex/N:fex/2-fex/N];
fy=[-fey/2:fey/N:fey/2-fey/N];
[FX,FY]=meshgrid(fx, fy);


%%%%fréquences spaciales de l'onde de référence 
Ur = xc/lambda/abs(zo);
Vr = yc/lambda/abs(zo);

%%% Fonction de transfert 
Du =abs (Gy*DAX/lambda/zi);
Dv =abs (Gy*DAY/lambda/zi);

Gf = zeros(size(f));
Ir = find(abs(FX-Ur)<Du/2 & abs(FY-Vr)<Dv/2);
Gf(Ir)= exp(-1i*k*zi*sqrt(1-(lambda*(FX(Ir)-Ur)).^2-(lambda*(FY(Ir)-Vr)).^2));

%%%Reconstruction 
if sign(zo) == -1 
    Uo=fft2(TFUF.*Gf,N,N);
elseif sign(zo) == +1 
     Uo=ifft2(TFUF.*Gf,N,N);
end 

Gmax = max(max(abs(Uo).^.75));
Gmin = min(min(abs(Uo).^.75));
figure ;
imagesc(abs(Uo).^.75,[Gmin,Gmax/1]);
colormap(gray);
axis equal;
axis tight;
title('Image reconstruite par DFFT');


while isempty(p) == 0 
    imagesc(abs(Uo).^.75,[Gmin,Gmax/p]);
    colormap(gray);
    axis equal;
    axis tight;
    title('Image reconstruite par DFFT avec ajustement de grandissement');
    if p==0,
        break 
    end 
end 