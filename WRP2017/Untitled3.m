k=2*pi/lambda;
lambda = 6.33e-07;
Lo = 0.0086;
Img = test(:,420:1499);
z= 0.43;

[ny, nx] = size(Img); 

Lx = pas_pixel * nx;
Ly = pas_pixel * ny;

dfx = 1./Lx;
dfy = 1./Ly;

u = ones(nx,1)*((1:nx)-nx/2)*dfx;    
v = ((1:ny)-ny/2)'*ones(1,ny)*dfy;   

O = fftshift(fft2(Img));

H = exp(1i*k*z).*exp(-1i*pi*lambda*z*(u.^2+v.^2));  

Uf = ifft2(O.*H);  
