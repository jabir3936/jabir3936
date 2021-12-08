% Out of focus blur transfer function

function H= focus(R,U,V)

%Bessel function of first kind nu=1 and the radius multiplied by square
%root of u2 and v2

%Estimate for blur
if R<12
r= -0.16427*(R^5) + 5.96525*(R^4)-84.90475*(R^3)+593.7951*(R^2)-2047.95*R+2844.03;
else
    r=2.39010*(exp(-6))*(R^4)-0.000628*(R^4)+0.05973*(R^2)-2.54973*R+47.02154;
end


x=r.*sqrt(U.^2+V.^2);

J1= besselj(1,x);




H=J1./x;


%Eliminate any NAn that can occur especially on H1,1()
H(isnan(H))=0;

% Show frequency response
end