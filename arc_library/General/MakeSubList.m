function [OutSubList,OutSubDateList,BadSubIDs] = MakeSubList(HowMuch, RawDataPath, CNTFileNames, OutFileNames,SpecialProcess)
%[OutSubList,BadSubIDs] = MakeSubList(HowMuch, RawDataPath, CNTFileNames, OutFileNames)
%
%Builds Cell array of SubIDs as strings to use in data reduction scripts;
%by default, the script creates a list of unprocessed subjects.
%However, if HowMuch is set to 'full', all subjects are processed.
%Bad subjects (missing CNT files) can also be identified and removed from
%list of subjects to process
% 
%INPUT/OUTPUT
%HowMuch:       'partial' creates an array of unprocessed subjects; 'full'
%               creates an array of all subjects, prompts user to rename or
%               delete output file(s)
%RawDataPath:   path to raw data folder for study (must end with a backslash)
%CNTFileNames:  Cell array of strings containing data file name prefixes 
%               (eg, {'stim1_startlebaseline_','stim1_maintask_'}
%OutFileNames   Cell array of file names for output files from previous data processing 
%               (eg, {'STLMain.dat','STLBase.dat'}
%SpecialProcess cell array of good subjects with non-CNT data files 

%OutSubList:    Nx1 cell array of string SubIDs to pass to reduction script
%BadSubIDs:     Nx1 cell array of string SubIDs that are missing CNT files 

%Revision history
%2011-06-16:    Released version 1, MJS
%2011-06-17:    major change - added input parameter CNTFileNames. if passed, script checks if 
%               data files are present, adds subjects with missing data to BadSubIDs array and
%               removes their IDs from SubList; passes list of bad subjects back to reduction
%               script for future use (ie, BadSubIDs), MJS
%2011-06-23     major update to use cell arrays for data containers and
%               save SubIDs as strings.  Other small changes, JJC
%2011-08-08     minor update - fixed errors in cell logic, improved textscan use, added comments, MJS
%2011-08-10     minor update - added SpecialProcess input parameter to handle subjects with non-CNT data files
%               SpecialProcess is well suited for partial processing of subjects whose CNT files 
%               required pre-reduction cleaning, event marker fixes, etc
%2011-09-07:    fixed bug with str2double converstion of folder name, JJC

%% early work

    fprintf('Generating new SubList...');

    %set default to partial
    if nargin < 1
        HowMuch='partial';
    end

    %browse to raw data folder if not provided as function parameter
    if nargin < 2
        RawDataPath = [uigetdir('','Select the RawData folder.') '\'];
    end

    %optional parameter.  Set to null if not provided
    if nargin < 3
        CNTFileNames={};
    end

    if nargin < 4
        OutFileNames = {}; 
    end

    if nargin < 5
        SpecialProcess = {}; 
    end    
    
    %must provide OutFileNames if partial reduction requested
    if strcmpi(HowMuch, 'partial') && isempty(OutFileNames)
        error('OutFileNames must be provided for PARTIAL reduction')
    end

    contents = dir(RawDataPath); %get contents of raw data folder
    
    SubList = cell(length(contents),1); %pre-allocate SubList cell array
    SubDateList = cell(length(contents),1); %pre-allocate SubList cell array    
    BadSubIDs = cell(length(contents),1); %pre-allocate BadSubIDs cell array

    %add folders with integer labels to SubList or BadSubIDs (if no data
    %are present).  Add as strings to preserve leading 0's if present
    for i=1:length(contents)
        if contents(i).isdir && ~isempty(str2num(contents(i).name)) %if a folder and name is a number. NOTE: str2num is necessary here
            if isempty(CNTFileNames)  %if no CNTFileNames provided, will not check for missing data;  Assign to SubList
                SubList{find(cellfun('isempty', SubList),1)} = contents(i).name;
                SubDateList{find(cellfun('isempty', SubDateList),1)} = contents(i).date;
            else  %check for missing data and put in SubList or BadSubIDs
                DataPresent = true; %set initial value of DataPresent
                for j=1:length(CNTFileNames) %check for presence of data files if CNTFileNames was provided
                    if ~exist([RawDataPath contents(i).name '\' CNTFileNames{j} contents(i).name '.cnt'], 'file')                
                        DataPresent = false;
                    end
                end
                if DataPresent %if data was found, or if CNTFileNames was not provided, add SubID to SubList
                    SubList{find(cellfun('isempty', SubList),1)} = contents(i).name; %assign to first empty cell        
                else %if no data found, and CNTFileNames was specified, add SubID to BadSubIDs
                    BadSubIDs{find(cellfun('isempty',BadSubIDs),1)} = contents(i).name; 
                end
            end
        end
    end
    
    %add SubIDs for subjects with non-CNT data files to SubList, remove these SubIDs from BadSubIDs 
    if ~isempty(SpecialProcess) 
        for i = 1:length(SpecialProcess)
            SubList{find(cellfun('isempty', SubList),1)} = SpecialProcess{i}; %assign to first empty cell
        end

        DeleteEntries = zeros(length(BadSubIDs),1); %allocate array to indicate indices to delete                
        for j = 1:length(BadSubIDs) %check if SpecialProcess SubIDs are in BadSubIDs, where found, tag for removal
           if ismember(str2double(BadSubIDs{j}),str2double(SpecialProcess))
               DeleteEntries(j) = 1;
           end                
        end
        BadSubIDs(logical(DeleteEntries)) = []; %remove processed subids from OutSubList          
    end
    
    SubList(cellfun('isempty', SubList)) = []; %clear non-assigned cells
    SubDateList(cellfun('isempty', SubDateList)) = []; %clear non-assigned cells
    BadSubIDs(cellfun('isempty', BadSubIDs)) = []; % %clear non-assigned cells

    %% process new data (incremental mode)
    switch upper(HowMuch)
        case('PARTIAL')
            fid = fopen([RawDataPath OutFileNames{1}]); %open file with list of processed subjects; if more than one outfile specified, assumes same subs in each file     
            if fid < 0 %no file exists b/c it is the first partial reduction
                fprintf('WARNING: OutFileNames not present.  All subjects will be reduced\n')
                OutSubList = SubList;
                OutSubDateList = SubDateList;
            else
                PSubList=textscan(fid, '%f %*[^\n]','HeaderLines',1,'delimiter','/t'); %copy list of processed subIDs from column 1; ignore all other data in file
                fclose(fid); %close file
                PSubList=cell2mat(PSubList); %convert PSubList to array
                PSubList=unique(PSubList); %remove duplicate entries

                %check for unprocessed subjects. Compare entries in SubList to PSubList.  
                %Compare as double to avoid issues with leading zeros
                OutSubList = SubList;
                OutSubDateList = SubDateList;
                DeleteEntries = zeros(length(OutSubList),1); %allocate array to indicate indices to delete                
                DeleteDateEntries = zeros(length(OutSubDateList),1); %allocate array to indicate indices to delete                
                for j = 1:length(OutSubList) %create index of processed subs in OutSubList, tag as 1 in DeleteEntries
                   if ismember(str2double(OutSubList{j}),PSubList)
                       DeleteEntries(j) = 1;
                   end                
                end
                OutSubList(logical(DeleteEntries)) = []; %remove processed subids from OutSubList
            end

        case ('FULL')
            OutSubList=SubList;
            OutSubDateList=SubDateList;
            %check if OutFileNames already exist
            OutFilesPresent = false;
            for j = 1:length(OutFileNames)
                if exist([RawDataPath OutFileNames{j}], 'file')
                    OutFilesPresent = true;
                end
            end

            if OutFilesPresent %if old OutFileName exists, ask if script should rename or delete them; limits potential for duplicate entries
                answer = questdlg('Rename or Delete Previous Output Files?','Old Output Files','Delete','Rename','Delete');
                for j = 1:length(OutFileNames)
                    if strcmp(answer,'Delete')
                        delete([RawDataPath OutFileNames{j}]);
                    else %if rename selected, append current date to end of file name                        
                        fileinfo = dir([RawDataPath OutFileNames{j}]);        
                        movefile([RawDataPath OutFileNames{j}],[RawDataPath OutFileNames{j} '_' datestr(fileinfo.datenum, 'yyyy-mm-dd') '.dat']); %rename outfile with last modified date
                    end
                end            
            end
        otherwise
            error('HowMuch (%s) must be Partial or Full\n')
    end
    
    %sort output variables 
    OutSubList=sort(OutSubList);
    BadSubIDs=sort(BadSubIDs);
    
    %% clean up
    if ~isempty(BadSubIDs) %print list of bad subjects; requires user input to terminate script
        fprintf('\nThese subjects are missing CNT files and will not be processed:\n');
        disp(BadSubIDs);
        fprintf('Press any key to continue processing.');
        pause;     
    end
    fprintf('\nSubject List created and returned!\n');
end