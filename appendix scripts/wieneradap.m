%%function adaptive 3d Wiener filter

function Z = wieneradap(G,R,M)
% input for the function is G (3d image) R(patch size) and  M(3D mask)

%MAke padarray if the input image is not a square matrix on x and y

%Note input matrix(3D matrix) on x and y should be square matrix if not then padding 
%done to make it square matrix

%Also test if R is multiple of 3d Matrix x and y

%Using padarray for it to get equal RxR matrix (modify when necessary)
G = padarray(G,[2 2],0,'both');

% Create output same size as the input image
Z = zeros(size(G));

%Create for image planes
J= zeros(size(G));

%initialize covariance matrix
cov= zeros(R,R);

%Initialize result of loop for eigenvalue
res=zeros(size(cov,1),size(cov,2),size(G,3)); 

%initialize minimal eigenvalue 
var=zeros(1,size(G,3));




%Slices of Zaxis
for z=1:size(G,3)
   J(:,:,z)= G(:,:,z);
end

% % Create patches of every slice (Z axis) of image of size RxR
% for z=1:size(G,3)
% J(:,:,z) = mat2cell(G(:,:,z), R*ones(1,size(G,1)/R), R*ones(1,size(G,1)/R));
% end

% create pathces of every slice (Z axis) of image RxR


% loop to make covariance matrix
for z=1:size(G,3)
    mt= mat2cell(J(:,:,z),R*ones(size(G,1)/R,1),R*ones(size(G,2)/R,1));
for i=1:size(G,1)/R
for p=1:size(G,2)/R    
cov= cov + mt{i,p}*transpose(mt{i,p});

end
end
% save result of every slice
res(:,:,z)= cov/(size(G,1)/R);

% Save variance of every slice as minimal eigenvalue of result
var(z)= min(eig(res(:,:,z)));
end
disp('Done with variance ...')
%% local mean intensistiers 2 
% 3d mask M , should be odd integer mls 


 mls=zeros(size(G));

G1= padarray(G,[M,M,M],0,'both');  %R R
% 
for i=1+M:size(G1,1)-M
    for j= 1+M:size(G1,2)-M
        for k=1+M:size(G1,3)-M
              ls= zeros(M,M,M);    % initialize 3dmask
      ls= G1(i-((M-1)/2):i+((M-1)/2),j-((M-1)/2):j+((M-1)/2),k-((M-1)/2):k+((M-1)/2)); %take the intensity values at 3d mask
        mls(i-M,j-M,k-M)=sum(ls(:))/(M*M*M); %calculate local means intensities
        end
    end
end 
disp('Done with local means (halfway done) ...')
%% local variance of intensites
% calculate local variance with local mean intensities lvar , with 3dmask R

lvar= zeros(size(G));
G2= padarray(G,[M,M,M],0,'both');  %R R
Gs= G2.^2;
for i=1+M:size(Gs,1)-M
    for j= 1+M:size(Gs,2)-M
        for k=1+M:size(Gs,3)-M
              las= zeros(M,M,M);    % initialize 3dmask
      las= Gs(i-((M-1)/2):i+((M-1)/2),j-((M-1)/2):j+((M-1)/2),k-((M-1)/2):k+((M-1)/2)); %take the intensity values at 3d mask
        lvar(i-M,j-M,k-M)=sum(las(:))/(M*M*M)- mls(i-M,j-M,k-M)^2; %calculate local variance intensities
        end
    end
end
disp('Done with local variance (Almost done) ...')
%% calculate output of each intensity

for r=1:size(G,1)
    for s=1:size(G,2)
        for t=1:size(G,3)
             if t==1 
                 mvar= (var(t)+var(t+1))/2;%mean var, previous current and next band %variance
             elseif t ==size(G,3)
                     mvar= (var(t)+var(t-1))/2
                 else
                 mvar= (var(t-1)+var(t)+var(t+1))/3;
             end
            Z(r,s,t)=  mls(r,s,t)+ ((lvar(r,s,t)-mvar)/lvar(r,s,t))*(G(r,s,t)-mls(r,s,t));
        end
    end
end
disp('Calculating output ...')
Z(isnan(Z))=0;
end            
             
                
            
