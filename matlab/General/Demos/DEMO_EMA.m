% DEMO_EMA.m v1
% Jesse Kaye released 12-22-10
% Generates a list of scheduled outgoing text messages to be sent to a
% participant. Sends one text message at the participants wake and bed time
% and one random time in the first half and another in the second half of
% the day. Adjusts based on their weekday vs weekend sleep patterns.
% Currently set for 4 text messages per day. 
% Creates 1 dat file put in the subjects RawData folder and appends
% to a master .apl file with all subjects rolodex info.
% This program was made to function with mCore SMS Component.

%% Variables to Modify for each Subject
% Study Folder
RootPath = 'P:\UW\StudyData\LABEMA1\'; % Edit path for specific study


% Subject Information
SubID = '9999'; % 9999 is a fake test sub, you can modify if you use a different SubID
PhoneNumber = 9146293455; % 10-digit phone number

% Set Start Date
Month1 = 12; % Edit month of 1st text
Day1 = 23; % Edit day of 1st text
Year1 = 2010; % Edit year of 1st text, current program assumes 2010 below

% Set Weekday Wake/Sleep
HrMorn1 = 9; % Edit hour participant normally wakes up on weekdays
MinMorn1 = 15; % Edit minute participant normally wakes up up on weekdays
HrNt1 = 21; % Edit hour participant goes to sleep up on weekdays
MinNt1 = 30; % Edit minute participant goes to sleep up on weekdays

% Set Weekend Wake/Sleep
HrMorn2 = 10; % Edit hour participant normally wakes up on weekends
MinMorn2 = 00; % Edit minute participant normally wakes up on weekends
HrNt2 = 22; % Edit hour participant goes to sleep up on weekends
MinNt2 = 50; % Edit minute participant goes to sleep up on weekends

%% Constant Variables

% Weekday/Weekend Arrays
HrMorn = [HrMorn1, HrMorn2]; % Wake Hour on weekday(1) and weekend(2)
MinMorn = [MinMorn1, MinMorn2]; % Wake Min on weekday(1) and weekend(2)
HrNt = [HrNt1, HrNt2]; % Sleep Hour on weekday(1) and weekend(2)
MinNt = [MinNt1, MinNt2]; % Sleep Min on weekday(1) and weekend(2)

% Set Number of Texts
TextPerDay = 4; % Number of text messages sent per day
NDays = 21; % Total number of days to send texts
TextTotal = TextPerDay*NDays; % Total number of texts per sub over all days

% Day = 1 in datenum format
OneMin = 1/(24*60); % Value of One Minute
OneHour = 1/24; % Value of One Hour

%% Start Program
TextOut = zeros(TextTotal,7); % create matrix of zeros
Today = [Year1, Month1, Day1]; % Initialize Today for 1st day of texting
TodayNum = datenum(Today); % Numeric value of Today's date

a=0; % initialize counter used in for loop below to track each text message/row in matrix


%% Fill TextOut Matrix

for i = 1:NDays % for each day
    [Y, M, D] = datevec(TodayNum); % create a vector of the date
    
    % Is Today (current day in for loop) a weekend? 1 = no; 2 = yes
    
    if (weekday(TodayNum) > 1) && (weekday(TodayNum) < 7) 
        w = 1;
    else 
        w = 2;
    end

    % Compute 2 Random Prompts for Today
    MornTime = [Today, HrMorn(w), MinMorn(w), 0]; % Create array of morning time text
    NtTime = [Today, HrNt(w), MinNt(w), 0]; % Create array of night time text
    MornNum = datenum(MornTime); % Convert to numeric value
    NtNum = datenum(NtTime); % Convert to numeric value
    MidTime = (NtNum + MornNum)/2; % Calculate time halfway between wake and sleep (day-less)
    MornRange = (MornNum + OneHour):OneMin:MidTime; % Create Vector of values for every minute from 1 hour after wake time until miday
    AfRange = MidTime:OneMin:(NtNum - OneHour); % Create vector of values for everyminute from miday until 1 hour before sleep

    % if the morning and afternoon prompt are within 1 hour of each other
    % calculate new times until they are not within 1 hour of each other
    
    RPdiff = OneHour-1;
    while RPdiff < OneHour % repeat if the two prompts are within one hour of each other
        MornRand = randperm(length(MornRange)); % create list of values from 1 to length #minutes in morning, in a  random order
        RP1 = MornRange(MornRand(1)); % use above list to select a random number from  the possible morning text times
        RP1Day = datestr(RP1);  % convert morning text to date string
        [Y1, M1, D1, H1, MN1, S1] = datevec(RP1Day); % convert date string to vector
        AfRand = randperm(length(AfRange)); % create list of values from 1 to length #minutes in afternoon, in a  random order
        RP2 = AfRange(AfRand(1)); % use above list to select a random number from  the possible morning text times
        RP2Day = datestr(RP2); % convert morning text to date string
        [Y2, M2, D2, H2, MN2, S2] = datevec(RP2Day); % convert date string to vector
        RPdiff = RP2 - RP1; % calculate the difference between the numeric values of the random prompt 1 and 2
    end

    for j = 1:TextPerDay % for each of 4 texts per day
        TextOut(a+j,2:4) = [M,D,Y]; % write year, month, day for all 4 text messages on that day
        
        if j == 1 % 1st text of the day
            TextOut(a+1,5:6) = [HrMorn(w),MinMorn(w)]; % write hour and minute
        end
        if j == 2 % 2nd text of the day
            TextOut(a+2,5:6) = [H1,MN1]; % write hour and minute
        end
        if j == 3 % 3rd text of the day
            TextOut(a+3,5:6) = [H2,MN2]; % write hour and minute
        end
        if j == 4 % 4th text of the day
            TextOut(a+4,5:6) = [HrNt(w),MinNt(w)]; % write hour and minute
        end
    end
    TodayNum = TodayNum + 1; % update TodayNum to be the next day
    a = a+4; % row place holder
end

fprintf('%s% 10d\n%i\n', SubID, PhoneNumber, TextTotal); % display to command window
disp(TextOut) % display TextOut matrix in command window

%% Write Output File
% Individual Subject RawData folder
PathName = [RootPath 'RawData\' SubID '\'];  %
OutFileName = ['EMArolodex' SubID '.dat']; %
fid = fopen([PathName, OutFileName],'w'); % 'w' = open file for writing, will write over files with same name without asking user
fprintf(fid,'%s% 10.0f\r\n% i\r\n', SubID,PhoneNumber,TextTotal);
fclose(fid);
dlmwrite([PathName OutFileName] ,TextOut,'-append', 'delimiter',' ', 'newline','pc', 'precision',5) % pc implies carriage return/line feed

% Append Mater EMA File
PathName = [RootPath 'RawData\'];  %
OutFileName = 'EMArolodex.apl'; %
fid = fopen([PathName, OutFileName],'a'); % 'w' = open file for writing, will write over files with same name without asking user
fprintf(fid,'%s% 10.0f\r\n% i\r\n', SubID,PhoneNumber,TextTotal);
fclose(fid);
dlmwrite([PathName OutFileName] ,TextOut,'-append', 'delimiter',' ', 'newline','pc', 'precision',5) % pc implies carriage return/line feed


fprintf('\n\nYour Output File is Here: %s%s \n', PathName, OutFileName);
fprintf('\nTextOutLogV2_2 Complete!\n');
