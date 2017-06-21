function WRP = ob2wrp(M, N, Lw, Lo, d, k)
%* *M* est une matrice de taille    Nbpoints x 3    représentant un objet 3D. (coordonnées en x y et z de chaque point) l'unité est le m.
%* *N* la largeur totale en pixel du WRP.
%* *Lw* la largeur utile en m du WRP.
%* *Lo* la largeur totale en m du WRP
%* *d* la distance entre le 1er plan de l'objet (+ éventuel padding dans la fonction shape3D)  WRP. (cf. schéma du rapport)

sampling = Lo/N;
Nw= floor((N - (Lo-Lw)/sampling)/2)*2; %Taille utile en pixels (N inclut les pixels du 0-padding)

%fprintf('Taille utile du WRP Nw=%d px \n', Nw);

a0 = 10; %amplitude de l'onde emise par chaque point, supposee constante
WRP = zeros(Nw, Nw); %WRP carre

range=Lw/2;
ipx=(-1*range):sampling:range; %coordonnees x des pixels en metres, centre sur 0
ipy=(-1*range):sampling:range; %coordonnees y des pixels en metres, centre sur 0

h=waitbar(0, 'Début du calcul'); %creation d'une barre de progression

theta=0.5;
tng = tand(theta);%tangente avec l'argument en degré (inclinaison de l'onde de référence par rapport aux axes y et z (cf. schéma));

for xWRP = 1:Nw
    waitbar(xWRP/Nw,h,sprintf('Calcul pour xWRP = %d sur %d valeurs \n', xWRP, Nw)) %actualisation de la barre de progression
    for yWRP = 1:Nw
        a=0;
        for j=1:size(M,1)
            xj = M(j, 1); %coordonnee x du point de l'objet
            yj = M(j, 2); %coordonnee y du point de l'objet
            zj = M(j, 3); %coordonnee z du point de l'objet
            Rwj = sqrt((ipx(xWRP)-xj)^2+(ipy(yWRP)-yj)^2+(zj+d)^2); %distance objet-point du WRP
            %WRP(xWRP, yWRP) = WRP(xWRP, yWRP) + (a0/Rwj)*exp(1i*k*Rwj);
            a = a + (a0/Rwj)*exp(1i*k*Rwj); %on calcule l'onde objet de tous les points en (xWRP, YWRP)
        end
    WRP(xWRP, yWRP) = sqrt  (abs(a+exp( 1i*k*tng*ipx(xWRP) + 1i*k*ipy(yWRP)))^2   - 1 - abs(a)^2); %amplitude complexe sur le WRP : on supprime l'ordre 0 avec la formule |Ao+Ar|²-|Ao|²-|Ar|²
    end
end


%WRP = sqrt(abs(WRP+1).^2 -1-abs(WRP).^2);% On enlève l'ordre 0 (dans le cas où l'onde de référence est 1 i.e onde de référence de direction z)

%matriceLCD=[zeros(290,1080);zeros(Nw,290),WRP,zeros(Nw,);zeros(290,1080)];

delete(h); %fermeture automatique de la barre de progression


WRP = [zeros((N-Nw)/2,Nw);WRP;zeros((N-Nw)/2,Nw)]; %ajout d'un padding pour atteindre 1080 x 1080
WRP = [zeros(N,(N-Nw)/2),WRP,zeros(N,(N-Nw)/2)];

figure(2), imagesc(real(WRP)), colormap(gray);

end

