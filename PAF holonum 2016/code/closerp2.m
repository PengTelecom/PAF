function [ y ] = closerp2( x )
%Trouve la puissance de 2 la plus proche de x
%   
y=2^-10;
x=abs(x);
while y<x
    y=y*2;
end
y=y*2;
end

