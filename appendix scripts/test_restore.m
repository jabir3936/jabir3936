%Test for out of focus blur

clear all
clc

% Load 3D image
 m= load('D:\Masterarbeit_Jabir\SravanAdded_Temp\Cups_CameraStraight_JabirSelected.mat');
 n= m.VoxelArray;
 img= voxelarraytest(n);
 
 %Sample slice of 3D image
 f= img(:,:,7);

 %Get the fft transform of the image
 
 F= fft2(f);
 S= fftshift(log(1+abs(F)));
 S=gscale(S);

%Get the padded size of original image for filtering

PQ=paddedsize(size(f));

[U,V]= dftuv(PQ(1), PQ(2));

%Estimate the radius for the out of focus blur model
% Displays the circle and select the radius from the workspace 'radii'
[centers, radii]= imfindcircles(S,[6 10],'Sensitivity',0.95);
imshow(S)
viscircles(centers, radii,'Color','r');


%%
% Using out of focus blur model to get the filter H to use in the wiener
% filter
H= focus(6.973857334126879,U,V);

%Loop for each slice of the 3dimage

G=zeros(size(img));
for i=1:size(img,3)

    f=img(:,:,i);

%Now use the wiener filter with small value in noise

%Theoretical value of snr
snr=10^(12/10);
K= 1./snr;

  W= wiener(H,K);
 g=dftfilt(f,W);
 
 G(:,:,i)=g;

end
% Convert the matrix file to gray scale image based on the range of values
% in the matrix G
G=mat2gray(G);

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

end
