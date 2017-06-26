clear all
close all
parametre;
a0 = 1;
W=1920; %largeur du la matrice CCD
H=1080; %hauteur de la matrice CCD
M=shape3D( 'cube', Nm, paddm*2, pm); %matrice de l'objet 
WRP = ones(W,H);
WRP = WRP * a0;
for n=1:334
    parfor slmx=1:W
        for slmy=1:H
            coord=[(slmx-W/2)*pas_pixel,(slmy-H/2)*pas_pixel,d];
            kxyz = M(n,:)-coord;
            norm = sqrt( kxyz(:,1).^2+kxyz(:,2).^2+kxyz(:,3).^2);
            kxyz = kxyz./ norm;
            kxyz = kxyz*2*pi/lambda;
            phase=coord.*kxyz;  
            a = a0 * exp(1i*(phase(1)+phase(2)+phase(3))) / norm;
            WRP(slmx,slmy) = WRP(slmx,slmy) + a;
        end
    end
end
            
 figure(2), imagesc(real(WRP)), colormap(gray);
 imwrite(WRP, 'outWRP.png');          
        


