%Script to loop through individual .dat RT files from DMDX and aggregate
%into one file.  
%2011-01-13, JJC

SubList = [111	112	123	124	211	212	223	224	311	312	315	324	411	423	424	1111	1112	1123	1124	1211	1213	1214	1224	1311	1312	1313	1314	1323	1411	1414	1423	1424	2111	2112	2114	2115	2125	2126	2128	2215	2216	2217	2222	2224	2225	2227	2230	2312	2314	2315	2316	2317	2323	2326	2327	2411	2412	2413	2414	2416	2423	2425	2428	412	1212	1223	1324	2127];   %This is a list of all SubIDs to aggregate

RootPath = 'P:\UW\StudyData\SAFE\RawData\';
PreFileName = 'RT013_';
TimeOut = -1500;
NumDataTrials = 260;
OutFileName = 'RTData.dat';



%% Create output file with header
header = sprintf('SubID\tTrialNum\tTrialID\tRT\tError\tNR');
dlmwrite([RootPath OutFileName],header,'-append', 'delimiter', '');

%%  Subject loop
OutData = zeros(NumDataTrials,6);  %allocate data array

for i = 1:length(SubList);  %Loop through following commands for each entry in SubList (i.e., for each participant)
    SubID = SubID2Str(SubList(i),4);
    fprintf('\nProcessing SubID: %s \n', SubID);   %display message to screen to track processing   

    %Open Input File
    InputPath = [RootPath SubID '\']; 
    InFID = fopen([InputPath PreFileName SubID '.dat']);
    if InFID < 0  %check that file was successfully opened
        error('Input File Open Error for file: %s\n', [InputPath PreFileName SubID '.dat']) 
    end
    
    %Get header lines, extract info and discard
    FileHeader1 = textscan(InFID,'%s%s%s%s%s%s%s%s',1,'commentStyle', '!'); %discard 'Subjects incorporated to date' line
    
    %verify that SubIDs match
    if ~strcmp(FileHeader1{8},SubID)
        error('SubIDs (%s vs. %s) do not match', SubID, FileHeader1{8})
    end
    FileHeader2 = textscan(InFID,'%s%s',1,'commentStyle', '!'); %get and discard second header line
    clear FileHeader2
    
    %get all data trials from Input file
    InData = textscan(InFID,'%n%n',NumDataTrials,'commentStyle', '!');
    
    %check for any remaining data
    Check = textscan(InFID,'%n%n',1,'commentStyle', '!');
    if ~isempty(Check{1})
       error('Data remains for SubID: %s:', SubID)         
    end
    fclose(InFID);  %close input file
    
    %output data array
    OutData(:,1) = SubList(i);
    OutData(:,2) = 1:NumDataTrials;
    OutData(:,3) = InData{1};   %add trial IDs
    OutData(:,4) = abs(InData{2}); %add RT (all positive)
    OutData(:,5) = (InData{2} < 0);    %code neg RTs as error (1), all others are zero
    OutData(:,6) = (InData{2} == TimeOut);  %code neg timeout as NR (1) all other are zero
    
    %write data to output file as tab delimited
    dlmwrite([RootPath OutFileName],OutData,'-append', 'delimiter', '\t')
end