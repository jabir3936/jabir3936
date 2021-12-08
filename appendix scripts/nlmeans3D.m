%% NL means filter 3d
% Input function is I- 3dIMg to be filtered, V-search volume , T- similary
% window, h- degree of filtering

function g= nlmeans3D(I,V,T,h)

clc;
% adjust the 3d images to gray scale 3d images

% adjust the 3d images to gray scale 3d images
tic
Img= mat2gray(I,[0 max(I(:))]);

%Get the size of 3d image as m,n and k respectively
[m,n,k] = size(I);

%Creating the search volume kernel
ks= 2*T+1;

ker= zeros(ks,ks,ks);

%Initialize search volume kernal
su=1;          %standard deviation of gaussian kernel
sm=0;          % sum of all kernel elements (for normalization)
for x=1:ks
    for  y=1:ks
        for z=1:ks
            a= x-T-1; % x distance of pixel from the center pixel evaluate
            b= y-T-1; % y distance of pixel from the center pixel to be evaulated
            c= z-T-1; % z distance of pixel from the cetner pixel to be evaluated
            ker(x,y,z) = exp(((a*a)+(b*b)+(c*c))/(-2*(su*su)));  %maybe multiply by 100?
            sm = sm + ker(x,y,z);
        end
    end
end
kernel = ker ./ T;       
kernel = kernel / sm;   % normalization

%initialize output of 3D image
g=zeros(m,n,k);
%g=gpuArray(g);
%prepare noise array for filter processing by padding the 3D array
img2 = padarray(Img,[T,T,T],'both');

%% Calculation output of single voxel

% initial for loop that will go through each individual voxel I(r,s,t)
for r=1:m
    for s=1:n
        for t=1:k
            rm=r+T;
            sn=s+T;
            tn=t+T; 
            
            % Neighborhood of evaluated voxel
            Wi=img2(rm-T:rm+T,sn-T:sn+T,tn-T:tn+T);
            
            %Boundaries of search Volume
            vxmin= max(rm-V, T+1);
            vxmax= min(rm+V, m+T);
            
            vymin= max(sn-V, T+1);
            vymax= min(sn+V, n+T);
            
            vzmin= max(tn-V, T+1);
            vzmax= min(tn+V, k+T);
            
            % initial and calculated weight
             
                %Normalizing constant and weighing function
            
          %[NL Z]=weighfunction(vxmin,vxmax,vymin,vymax,vzmin,vzmax,T,img2,kernel,Wi,h);
           
           Z=0;
        NL=0;
   % loop around search volume
   

        for   x=vxmin:vxmax
            for     y=vymin:vymax
                for    z=vzmin:vzmax
                        
                  
                   %Neighborhood of voxel 'j' being compared to with voxel i
                  
                   Wj= img2(x-T:x+T, y-T:y+T, z-T:z+T);
                   
                   %Calculate eucleidian distance
                   d2 = sum(sum(sum(kernel.*(Wi-Wj).*(Wi-Wj).*(Wi-Wj))));
                    
                   % weight of similary : w(i,j)
                   wij= exp(-d2/(h*h));
                   
                   %update Z and NL
                   Z= Z + wij;
                   NL= NL + (wij*img2(x,y,z));     
                end 
            end
        end
              
            % Outuput of the Voxel calulated and the loop starts again for
            %new voxel
            g(r,s,t)=NL./Z;
        end 
    end
       disp(strcat(num2str(r),',',num2str(s),',',num2str(t),'done out of', num2str(r/m*100),'%'))
        
end
     

timerest=toc;
duration(0,0,timerest,'Format','hh:mm:ss')

 % Convert to uint16
% g=uint16(g);


end