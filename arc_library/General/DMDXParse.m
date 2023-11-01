function DMDXParse(SubID, TimeOut, CopyData, NumDataTrials, AzkPath, AzkFN, CompPath, CompFN)
%v3, created by John J. Curtin (jjcurtin@wisc.edu)
%usages
%No input needed: DMDXParse(SubID, NumDataTrials, TimeOut, CopyData, AzkPath, AzkFN, CompPath, CompFN)
%Prompted for filenames/paths only: DMDXParse(SubID, NumDataTrials, TimeOut, CopyData)
%Prompted for all input: DMDXParse
%
%DMDXParse takes DMDX AZK file as input and reformats and appends to a %composite file that includes all participants.  Composite file includes
%nine data columns (SubID, Date, Time, Computer, Refresh, TrialNum, TrialID, RT, and Outcome (0=correct, 1= error, 2= no response).
%
%An optional full copy of the subjects data can also be saved in addition to appending to composite file.
%
%A report of number of trials, number of error and number of NRs is provided at command line
%
%Can parse one subject or full AZK file according to the SubID parameter (see below)
%
%INPUTS:
%SubID:  Subject ID for subject to parse.  At this point, must be an integer value.  [] = parse all subjects
%TimeOut:  Time out value from DMDX script. Used to identify NRs
%CopyData: (T)rue or (F)alse to save a copy of the subjects individual responses in addition to adding to composite file
%NumDataTrials:  Number of data trials to parse per subject.  Used for error checking. [] = determine # trials from azk file.
%AzkPath, AzkFN: file path and name for the AZK  input file
%CompPath, CompFN: file path and name for the composite output file

%Revision history
%2008-07-29:  First release, v1, JJC
%2008-08-11; fixed delimit (= '') character to avoid finding extra files, fixed [] as paraeter in GUI, added syntax output. v2 JJC 
%2008-10-24: added [] to output that describes syntax fro calling script when SubID or NumDataTrials are blank, v3, JJC
%2009010-16:  Fixed issue with change to str2double 
%
%CONSIDER
%ADD COTs to output file if exist?
%Speed up code


if nargin < 8  %need to get some paramters at least (can provide all, 4 or no parameters)

    if nargin < 4  %need to get all parameters if nargin < 4.  Some users, may provide first four from command line
        promptstr    = {'Subject ID to parse ([] = all):', 'Number of Trials ([]=Determine from azk file): ', 'Time Out: ', 'Save Copy of Subject''s Data (T or F):'};
        inistr       = {'', '', '1500', 'T'};
        result       = inputdlg( promptstr, 'Enter Parse Parameters', 1,  inistr);
        if isempty( result ); return; end;
        
        SubID = result{1};
        if strcmp(SubID, '[]') || strcmp(SubID, '[ ]')  %if set to empty via brackets make empty
            SubID = '';
        end
        SubID = str2double(SubID);  %Convert to integer
        
        NumDataTrials = result{2};
        if strcmp(NumDataTrials, '[]') || strcmp(NumDataTrials, '[ ]')  %if set to empty via brackets make empty
            NumDataTrials = '';
        end        
        NumDataTrials = str2double(NumDataTrials);
        
        TimeOut = str2double(result{3});
        
        CopyData = result{4}; 
    end
    
    %Will likely always need filenames/paths if nargin < 8
    [AzkFN AzkPath] = uigetfile('*.azk', 'Open AZK file to parse');
    if isequal(AzkFN,0) || isequal(AzkPath,0)
        error('User cancelled selection of AZK file.  Parse Terminated')
    end
        
    [CompFN CompPath] = uiputfile('*.dat', 'Select COMPOSITE file for output', AzkPath);  %default save in AzkPath
    if isequal(CompFN,0) || isequal(CompPath,0)
        error('User cancelled selection of COMPOSITE file.  Parse Terminated')
    end
end

    %Parameter Integrity checks
    if TimeOut < 0  %TimeOut should be positive
        TimeOut = TimeOut *-1;
    end

    CopyData = upper(CopyData); %CopyData should be T or F
    if ~(strcmp(CopyData,'T') || strcmp(CopyData, 'F'))
        error('CopyData(%s) must be either T or F\n', CopyData);
    end
    
    if isempty(SubID)  %if no SubID provided, reduce all subjects.
        ParseAll = true;
    else
        ParseAll = false;
    end
    
%Document version number and output command line for subsequent use
fprintf('DMDXParse, version 3\n');
if isempty(SubID)
    sSubID = '[]';
else
    sSubID = int2str(SubID);
end
if isempty(NumDataTrials)
    sNumDataTrials = '[]';
else
    sNumDataTrials = int2str(NumDataTrials);
end
fprintf('DMDXParse(%s, %d, ''%s'', %s, ''%s'', ''%s'', ''%s'', ''%s'')\n', sSubID, TimeOut, CopyData, sNumDataTrials, AzkPath, AzkFN, CompPath, CompFN)

    %if composite file doesnt exist, create it and add header. Otherwise, nothing needed at this time
    CompFID = fopen([CompPath CompFN]);
    if CompFID < 0  
        header = sprintf('SubID\tDate\tTime\tComputer\tRefresh\tTrialNum\tTrialID\tRT\tOutcome');
        dlmwrite([CompPath CompFN],header,'-append', 'delimiter', '');
    else
        fclose(CompFID);
    end
        
    %Open AzkFile
    AzkFID = fopen([AzkPath AzkFN]);
    if AzkFID < 0  %check that file was successfully opened
        error('AZK File Open Error: %s\n',[AzkPath AzkFN]) 
    end
    
    %Get header lines and discard
    FileHeader1 = textscan(AzkFID,'%s%s%s%s%s',1,'commentStyle', '!'); %discard 'Subjects incorporated to date' line
    clear FileHeader1;
    FileHeader2 = textscan(AzkFID,'%s%s%s%s%s%s',1,'commentStyle', '!'); %discard 'Data file started on machine' line
    clear FileHeader2;
    FileHeader3 = textscan(AzkFID,'%s',1,'commentStyle', '!');  %discard '*****' line; Considered header at first, later considered end of sub data
    clear FileHeader3

    %Loop through Azk file one subject at a time until SubID is found(if only one subject) or 
    %end of file (if all subjects or subject never found)
    SubIDFound = false;
    Done = false; %Done is true if (SubID is found and ParseAll is false)
    while ~(Done || feof(AzkFID))
        TextLine = textscan(AzkFID, '%s', 1, 'delimiter', ''); %get 'Subject' header line as one cell
        SubHeader1 = textscan(char(TextLine{1}),'%s%s%s%s%s%s%s%s%s%s',1);  %parse this header
        %e.g., Subject 1, 02/14/2008 10:02:13 on COLT45, refresh 16.59ms, ID 1005
        
        %Test to see if SudID is missing.  If so, exit.  This will force correction of incomplete AZK files
        %Also check if this subject needs to be parsed
        if ~strcmpi(SubHeader1{9}, 'ID')
            fclose(AzkFID);
            error('No SubID assigned to Subject %s collected on %s\n',char(SubHeader1{2}),char(SubHeader1{3}));
        else
            %Test that SubID is numeric.  Exit if not
            if isnan(str2double(char(SubHeader1{10})));
                fclose(AzkFID)
                error('SubID (%s) must be numeric\n', char(SubHeader1{10}))
            end            
            
            if ~ParseAll && (SubID == str2double(SubHeader1{10}))  %if parsing only one sub and matches
                SubIDFound = true;
                Done = true;  %No need to loop again but finish this loop
            else
                if ParseAll   %If parsing all, then every subject will be parsed.
                    SubIDFound = true;
                end
            end
        end
        
        if (strcmp(CopyData, 'T') && SubIDFound)  %Get Copy Files Path and Name and output first line (from above) to file copy
            Title = sprintf('Save COPY of Subject %s''s AZK data', char(SubHeader1{10}));
            DefaultFN = sprintf('RT%s.dat', char(SubHeader1{10}));
            [CopyFN CopyPath] = uiputfile({'*.dat', 'DAT files (*.dat)'}, Title,[AzkPath DefaultFN]);
            if isequal(CopyFN,0) || isequal(CopyPath,0)  %check that user didnt press cancel
                fclose(AzkFID);
                error('User cancelled selection of COPY file.  Parse Terminated')
            else
                dlmwrite([CopyPath CopyFN],TextLine{1},'-append', 'delimiter', '');
            end
            
        end
        
        TextLine = textscan(AzkFID, '%s', 1, 'delimiter', '@#$#%@#'); %get 'Item  RT (and maybe COT)' line
        if (strcmp(CopyData, 'T') && SubIDFound)  %output to file copy if requested
            dlmwrite([CopyPath CopyFN],TextLine{1},'-append', 'delimiter', '');
        end
        
        %check if COTs are included for later data parsing
        if isempty(strfind(char(TextLine{1}),'COT'))
            COTIncluded = false;
        else
            COTIncluded = true;
        end

        MoreData = true;  %assumes at least one row of data
        TrialNum = 0;
        NumErrors = 0;
        NumNRs = 0;
        SubDataArrayStr = [];  %set Sub's data array to empty to start
        while (MoreData && ~feof(AzkFID))  %loop row by row through one subject's data
            TextLine = textscan(AzkFID, '%s', 1, 'delimiter', ''); %get a row of data
            if (strcmp(CopyData, 'T') && SubIDFound)  %output to file copy if requested
                dlmwrite([CopyPath CopyFN],TextLine{1},'-append', 'delimiter', '');
            end                                
            
            if ~(isempty(TextLine{1}) || strncmp(char(TextLine{1}),'!',1))   %Skip if empty row or row with display error
                if strncmp(char(TextLine{1}),'*',1)  %found **** that indicates end of subject.
                    MoreData = false;
                else
                    %if not empty, display error or **** then must be data record
                    %Get data
                    if COTIncluded
                        %SubDataCells = textscan(char(TextLine{1}),'%n%n%n',1, 'commentStyle', '!');  %parse row of data but skip display error info
                        SubDataCells = textscan(char(TextLine{1}),'%n%n%n',1);  %parse row of data with COT
                    else
                        %SubDataCells = textscan(char(TextLine{1}),'%n%n',1, 'commentStyle', '!');  %parse row of data but skip display error info
                        SubDataCells = textscan(char(TextLine{1}),'%n%n',1);  %parse row of data with no COT
                    end                         
                    TrialNum = TrialNum + 1;
                                        
                    %Determine outcome
                    if abs(SubDataCells{2}) == TimeOut  %NR can be - or + depending on experiment
                        NumNRs = NumNRs + 1;
                        Outcome = '2';  %No response
                    else
                        if SubDataCells{2} < 0
                            NumErrors = NumErrors + 1;
                            Outcome = '1';       %error
                        else
                            Outcome = '0';  %correct response
                        end
                    end       
                    %Create one data record/trial for subject and save in subject array
                    %SubID, Date, Time, Computer, Refresh, TrialNum, TrialID, RT, Outcome
                    SI = char(SubHeader1{10});
                    TheDate = char(SubHeader1{3});
                    TheTime = char(SubHeader1{4});
                    Computer = char(SubHeader1{6});
                    Computer = Computer(1:length(Computer)-1);  %remove ,
                    Refresh = char(SubHeader1{8});
                    Refresh = Refresh(1:length(Refresh)-1);  %remove ,
                    
                    DataRecord = sprintf([SI '\t' TheDate '\t' TheTime '\t' Computer '\t' Refresh '\t' int2str(TrialNum) '\t' int2str(SubDataCells{1})  '\t' num2str(abs(SubDataCells{2})) '\t' Outcome]);
                    SubDataArrayStr = strvcat(SubDataArrayStr, DataRecord); %Add record to end of data array                                   
                end
            end
        end %loop through one subject
        
        %Set NumDataTrials based on first subject if not provided by user.  This will force all subsequent partcipants to have correct number.  
        %Will be skipped if already provided by user
        if isempty(NumDataTrials)
            NumDataTrials = TrialNum;
        end

        if SubIDFound %If the last loop was for a subject to be parsed (target or all) then check and output
            

            
            %Check that correct number of trials were detected for this subject
            if TrialNum ~= NumDataTrials
                fclose(AzkFID)
                error('Incorrect number of trials (%d) detected for Subject %s\n', TrialNum, char(SubHeader1{10}));
            else  %report number of trials, errors and non-responses
                fprintf('   Subject %s: %d trials parsed, %d errors, %d non-responses.\n',char(SubHeader1{10}),TrialNum, NumErrors,NumNRs);
                dlmwrite([CompPath CompFN],SubDataArrayStr,'-append', 'delimiter', '');
            end
        end
    end %loop through AZK file
    

    if ~SubIDFound
        fclose(AzkFID);
        error('SubID %d not found in AZKFile: %s\n)',SubID, [AzkPath AzkFN]);
    end
    
    fclose(AzkFID);
end