clear all
close all
parametre;
M=shape3D( 'cube', Nm, paddm*2, pm);


%fprintf('Taille utile du WRP Nw=%d px \n', Nw);
theta=0.5;
tng = tand(theta);%tangente avec l'argument en degr?(inclinaison de l'onde de référence par rapport aux axes y et z (cf. schéma));

a0 = 10; %amplitude de l'onde emise par chaque point, supposee constante
coordWRP = zeros(1920*1080,3);%WRP 1920*1080
for long = 1:1920
    for haut = 1:1080
        coordWRP((long-1)*1080+haut,:) = [(long-960)*pas_pixel,(haut-540)*pas_pixel,d];
    end
end  

% %coordWRP = gpuArray(coordWRP);
% rangex=1919*pas_pixel/2.;
% rangey=1079*pas_pixel/2.;
% ipx=(-1*rangex):pas_pixel:rangex; %coordonnees x des pixels en metres, centre sur 0
% ipy=(-1*rangey):pas_pixel:rangey; %coordonnees y des pixels en metres, centre sur 0


%h=waitbar(0, 'Debut du calcul'); %creation d'une barre de progression


WRP(1:1080,1:1920) = 0;
for x =1:1920*1080
    dxyz = M - coordWRP(x,:);
    dis = sqrt( dxyz(:,1).^2+dxyz(:,2).^2+dxyz(:,3).^2);
    Matrix_1 = ones(1,344);
    MatrixA0 = a0 * ones(344,1);
    MatrixA0_Rwj = MatrixA0 ./ dis;
    Matrixcos = cos(-k * dis);
    Matrixsin = sin(-k * dis);
    Matrixreel = MatrixA0_Rwj .* Matrixcos;
    Matriximg = MatrixA0_Rwj .* Matrixsin;
    Sum_reel = Matrix_1 * Matrixreel+a0;
    Sum_img = Matrix_1 * Matriximg;
    Module = sqrt(Sum_reel.^2+Sum_img.^2);
    WRP(floor((x-1)/1920)+1,x-1920*floor((x-1)/1920)) = Module;
end



% a0 = 10; %amplitude de l'onde emise par chaque point, supposee constante
% coordWRP = zeros(1920*1080,2);%WRP 1920*1080
% for long = 1:1920
%     for haut = 1: 1080
%         coordWRP((long-1)*1080+haut,:) = [long*pas_pixel,haut*pas_pixel];
%     end
% end  
% for x =1:1920*1080
%     deltaxyz = M() - coordWRP(x);
%     Rwj = sqrt( deltaxyz(:,1).^2+deltaxyz(:,2).^2+deltaxyz(:,3).^2);
%     Matrix_1 = ones(1,344);
%     MatrixA0 = a0 * ones(344,1);
%     MatrixA0_Rwj = MatrixA0 ./ Rwj;
%     Matrixcos = cos(k * Rwj);
%     Matrixsin = sin(k * Rwj);
%     Matrixreel = MatrixA0_Rwj .* Matrixcos;
%     Matriximg = MatrixA0_Rwj .* Matrixsin;
%     Sum_reel = Matrix_1 * Matrixreel;
%     Sum_img = Matrix_1 * Matriximg;
%     Module = sqrt(Sum_reel.^2+Sum_img.^2);
%     WRP(floor((x-1)/1080)+1,x-1080*floor((x-1)/1080)) = Module;
% end
% 
%     





 figure(2), imagesc(real(WRP)), colormap(gray);
 imwrite(WRP, 'outWRP.png');