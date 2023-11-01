% NRT1_EMA_Rolodex.m Creates dat file of date/times to send participant text messages 
% Kate Magruder 7-22-14

%% Variables to Modify for each Subject
% Study Folder
RootPath = 'P:\StudyData\NRT1\RawData\'; % Edit path for specific study

% Subject Information
SubID = '9999'; % 9999 is a fake test sub, you can modify if you use a different SubID

% Set Start Date
Month1 = 7; % Edit month of 1st text
Day1 = 25; % Edit day of 1st text
Year1 = 2014; % Edit year of 1st text

% Set Sunday Wake/Sleep
% Enter Hours in Military Time (1-24)
% If Bedtime is after midnight, 1am = 25, 2am =26, etc.
HrMorn1 = 10; % Edit hour participant normally wakes up on weekdays
MinMorn1 = 30; % Edit minute participant normally wakes up up on weekdays
HrNt1 = 23; % Edit hour participant goes to sleep up on weekdays
MinNt1 = 0; % Edit minute participant goes to sleep up on weekdays

% Set Monday Wake/Sleep
HrMorn2 = 8; % Edit hour participant normally wakes up on weekends
MinMorn2 = 0; % Edit minute participant normally wakes up on weekends
HrNt2 = 23; % Edit hour participant goes to sleep up on weekends
MinNt2 = 0; % Edit minute participant goes to sleep up on weekends

% Set Tuesday Wake/Sleep
HrMorn3 = 8; % Edit hour participant normally wakes up on weekdays
MinMorn3 = 0; % Edit minute participant normally wakes up up on weekdays
HrNt3 = 23; % Edit hour participant goes to sleep up on weekdays
MinNt3 = 0; % Edit minute participant goes to sleep up on weekdays

% Set Wednesday Wake/Sleep
HrMorn4 = 8; % Edit hour participant normally wakes up on weekends
MinMorn4 = 0; % Edit minute participant normally wakes up on weekends
HrNt4 = 23; % Edit hour participant goes to sleep up on weekends
MinNt4 = 0; % Edit minute participant goes to sleep up on weekends

% Set Thursday Wake/Sleep
HrMorn5 = 8; % Edit hour participant normally wakes up on weekdays
MinMorn5 = 0; % Edit minute participant normally wakes up up on weekdays
HrNt5 = 23; % Edit hour participant goes to sleep up on weekdays
MinNt5 = 0; % Edit minute participant goes to sleep up on weekdays

% Set Friday Wake/Sleep
HrMorn6 = 8; % Edit hour participant normally wakes up on weekends
MinMorn6 = 0; % Edit minute participant normally wakes up on weekends
HrNt6 = 23; % Edit hour participant goes to sleep up on weekends
MinNt6 = 0; % Edit minute participant goes to sleep up on weekends

% Set Saturday Wake/Sleep
HrMorn7 = 10; % Edit hour participant normally wakes up on weekdays
MinMorn7 = 30; % Edit minute participant normally wakes up up on weekdays
HrNt7 = 23; % Edit hour participant goes to sleep up on weekdays
MinNt7 = 0; % Edit minute participant goes to sleep up on weekdays

%% Constant Variables
% Weekday/Weekend Arrays
HrMorn = [HrMorn1, HrMorn2, HrMorn3, HrMorn4, HrMorn5, HrMorn6, HrMorn7]; % Wake Hour on weekday(1) and weekend(2)
MinMorn = [MinMorn1, MinMorn2, MinMorn3, MinMorn4, MinMorn5, MinMorn6, MinMorn7]; % Wake Min on weekday(1) and weekend(2)
HrNt = [HrNt1, HrNt2, HrNt3, HrNt4, HrNt5, HrNt6, HrNt7]; % Sleep Hour on weekday(1) and weekend(2)
MinNt = [MinNt1, MinNt2, MinNt3, MinNt4, MinNt5, MinNt6, MinNt7]; % Sleep Min on weekday(1) and weekend(2)

% Set Number of Texts
TextPerDay = 4; % Number of text messages sent per day
NDays = 21; % Total number of days to send texts
TextTotal = TextPerDay*NDays; % Total number of texts per sub over all days

% Day = 1 in datenum format
OneMin = 1/(24*60); % Value of One Minute
OneHour = 1/24; % Value of One Hour

%% Start Program
TextOut = zeros(TextTotal,5); % create matrix of zeros w 5 columns
Today = [Year1, Month1, Day1]; % Initialize Today for 1st day of texting
TodayNum = datenum(Today); % Numeric value of Today's date

a=0; % initialize counter used in for loop below to track each text message/row in matrix

%% Fill TextOut Matrix
for i = 1:NDays % for each day
    [Y, M, D] = datevec(TodayNum); % create a vector of the date
    
    % What day of the week is TodayNum (current day in for loop)?
    
    if (weekday(TodayNum) == 1) % Sunday
        w1 = 1; % weekend wake time
        w2 = 1; % weekday bed time
    elseif (weekday(TodayNum) == 2) % Friday
        w1 = 2; % weekday wake time
        w2 = 2; % weekend bed time
    elseif (weekday(TodayNum) == 3) % Saturday
        w1 = 3; % weekend wake time
        w2 = 3; % weekend bed time
    elseif (weekday(TodayNum) == 4) % Friday
        w1 = 4; % weekday wake time
        w2 = 4; % weekend bed time
    elseif (weekday(TodayNum) == 5) % Saturday
        w1 = 5; % weekend wake time
        w2 = 5; % weekend bed time
    elseif (weekday(TodayNum) == 6) % Friday
        w1 = 6; % weekday wake time
        w2 = 6; % weekend bed time
    elseif (weekday(TodayNum) == 7) % Saturday
        w1 = 7; % weekday wake time
        w2 = 7; % weekday bed time
    end
    
    % Compute 2 Random Prompts for Today
    MornTime = [Today, HrMorn(w1), MinMorn(w1), 0]; % Create array of morning time text
    NtTime = [Today, HrNt(w2), MinNt(w2), 0]; % Create array of night time text
    MornNum = datenum(MornTime); % Convert to numeric value
    NtNum = datenum(NtTime); % Convert to numeric value
    MidTime = (NtNum + MornNum)/2; % Calculate time halfway between wake and sleep (day-less)
    MornRange = (MornNum + OneHour):OneMin:MidTime; % Create Vector of values for every minute from 1 hour after wake time until miday
    AfRange = MidTime:OneMin:(NtNum - OneHour); % Create vector of values for every minute from miday until 1 hour before sleep
    
    %if the morning and afternoon prompt are within 1 hour of each other calculate new times until they are not within 1 hour of each other
    
    RPdiff = OneHour-1;
    while RPdiff < OneHour % repeat if the two prompts are within one hour of each other
        MornRand = randperm(length(MornRange)); % create list of values from 1 to length #minutes in morning, in a  random order
        RP1 = MornRange(MornRand(1)); % use above list to select a random number from  the possible morning text times
        RP1Day = datestr(RP1);  % convert morning text to date string
        [Y1, M1, D1, H1, MN1] = datevec(RP1Day); % convert date string to vector
        AfRand = randperm(length(AfRange)); % create list of values from 1 to length #minutes in afternoon, in a  random order
        RP2 = AfRange(AfRand(1)); % use above list to select a random number from  the possible morning text times
        RP2Day = datestr(RP2); % convert morning text to date string
        [Y2, M2, D2, H2, MN2] = datevec(RP2Day); % convert date string to vector
        RPdiff = RP2 - RP1; % calculate the difference between the numeric values of the random prompt 1 and 2
    end
    
    for j = 1:TextPerDay % for each of 4 texts per day
        if j == 1 % 1st text of the day
            TextOut(a+j,1:5) = [M,D,Y,HrMorn(w1),MinMorn(w1)]; % write year, month, day for all 4 text messages on that day
        end
        if j == 2 % 2nd text of the day
            TextOut(a+j,1:5) = [M,D,Y,H1,MN1]; % write year, month, day for all 4 text messages on that day
        end
        if j == 3 % 3rd text of the day
            if D2 == Today(3)
                TextOut(a+j,1:5) = [M,D,Y,H2,MN2]; % write year, month, day for all 4 text messages on that day
            else
                [Y3, M3, D3] = datevec(TodayNum + 1);
                TextOut(a+j,1:5) = [M3,D3,Y3,H2,MN2]; % write year, month, day for all 4 text messages on that day
            end
        end
        if j == 4 % 4th text of the day
            if HrNt(w2) < 24
                TextOut(a+j,1:5) = [M,D,Y,HrNt(w2),MinNt(w2)]; % write year, month, day for all 4 text messages on that day
            else
                [Y3, M3, D3] = datevec(TodayNum + 1);
                TextOut(a+j,1:5) = [M3,D3,Y3,((HrNt(w2))-24),MinNt(w2)]; % write year, month, day for all 4 text messages on that day
            end
        end
    end
    TodayNum = TodayNum + 1; % update TodayNum to be the next day
    a = a+4; % row place holder
end

disp(TextOut) % display TextOut matrix in command window

%% Write Output File
% Individual Subject RawData folder 
PathName = [RootPath SubID '\'];  % Main Study Path
OutFileName = ['EMArolodex' SubID '.dat']; %File Name
DataSave(TextOut, OutFileName, PathName); % Write dat file to SubID folder on server with EMA Rolodex for that SubID
fprintf('\n\nYour Output File is Here: %s%s \n', PathName, OutFileName); % Print to screen contents of dat file