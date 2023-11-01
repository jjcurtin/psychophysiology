%Demo M-file to index and extract particular values from arrays created by shock assess scripts to be analyzed. 
%Example: first used to extract,for comparison, two different "high shock values" from DOSE2 study array to gauge effectiveness of special proecedure
%Released on 12-01-2010, DEB, JJC
%Please report any bugs or problems to Daniel B. 

%% Manage Info for Full Reduction (SubID list,Root path,Label indentify,)
SubList = [0011 0012 0013 0014 0015 0016 0021 0022 0023 0024 0025 0026 0111 0112 0113 0114 0115 0116 0121 0122 0123 0124 0125 0126 1011 1012 1013 1014 1015 1016 1021 1022 1023 1024 1025 1026 1111 1112  1113  1114 1115 1116 1121 1122 1123 1124 1125 1126 2011 2012 2013 2014 2015 2016 2021 2022 2023 2024 2025 2026 2111 2112 2113 2114 2115 2116 2121 2122 2123 2124 2125 2126 3011 3012 3013 3014 3015 3016 3021 3022 3023 3024 3025 3026 3111 3112 3113 3114 3115 3116 3121 3122 3123 3124 3125 3126];

Label1=1100; %change to indicate which rows you want to look for 
Label2=2100; %change to indicate which rows you want to look for (additional labels(more than two) can be added

%Establish root path
RootPath = 'P:\UW\StudyData\DOSE2\RawData\'; 

%Array to hold shock values for all subjects;   Col1= subid, col2= Shock1, col3 = shock2
SData=zeros(length(SubList),3); %change according to how many values you will be extracting

%% Main Reduction Loop
for i = 1:length(SubList);  %Loop through following commands for each entry in SubList (i.e., for each participant)
       
    %Manage Subject Specific info and paths
    SubID = SubID2Str(SubList(i),4);%Convert SubID for list to string for use in filenames, etc.   4 is the number of digits in the SubID.  SubID2Str will maintain leading zeros in SubID if used
    fprintf('\nProcessing SubID: %s \n', SubID);   %display message to screen to track processing

    InputPath = [RootPath SubID '\'];  %Change this to reflect Subjects' folder name with the RawData Folder.  In this case, folder name is SubID + \

    %open and format shock assessment in cell array
    fid = fopen ([InputPath 'ShockSensitivity2r(v1)_' SubID '.txt'],'r');
    SD1 = textscan(fid,'%u %u');
    fclose(fid);  
    
    %convert to standard array of type double
    ShockArray = [double(SD1{1}) double(SD2{2})];
    
    Index1 = find(ShockArray(:,1)==Label1); %find particular row for first high shock     
    Shock1 = SD2(Index1,2); %in that row tell me what value was recorded
   
    Index2 = find(ShockArray(:,1)==Label2); %find particular row for second low shock   
    Shock2 = SD2(Index2,2); %in that row tell me what value was recorded
          
    %hold value for this subject in array
    SData(i,1) = SubList(i); %put subid in first column
    SData(i,2) = Shock1; %put first high shock in second column
    SData(i,3) = Shock2; %%put second high shock in third column              
end 

%writing out array
dlmwrite([RootPath 'ShockData.dat'],SData,'-append', 'delimiter', '\t')    
fprintf('Shock Processing Complete\n');



