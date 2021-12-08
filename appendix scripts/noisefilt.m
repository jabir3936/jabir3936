%Noise filter loop using adaptive local noise filter

clear all;
clc;
% Specify the folder where the files live.
myFolder = 'D:\Masterarbeit_Jabir\Images_Captured\Cups_New\txt';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

% Looping through the text files
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
   
    
    M=txt2Matrix(baseFileName);           
    % change from 16 bit to 12 bit gray scale image
    Ze=uint16((2^12-1)*mat2gray(M));

     fprintf(1, 'Now reading %s\n', baseFileName);
    %%  Adaptive local noise reduction filter
       % filter size of m x n  and use odd integer and modify size as needed
    Zefilt= adaploc(Ze,155,155);

    %% Write new noise filtered image
    % imwrite rescale back to 8bit
    Zfilt = uint8(Zefilt / 16);
    
    %save file
    str1="filt2";
    str2=erase(baseFileName,".txt");
    str3=".png";
    file=append(str1,str2,str3);
    imwrite (Zfilt, file);

end
