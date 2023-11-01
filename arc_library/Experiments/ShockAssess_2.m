function ShockAssess_2()
%USAGE: ShockAssess_2()
%Script to conduct shock sensitivy assessment.
%Saves ShockRatings_StudyName_SubID.mat as output to local study folder
%Copies mat file to study folder on server

%Revision History
%2010-03-16:  Released version 1, JJC, MJS
%2010-03-29:  Added StudyName parameter, JJC
%2010-04-12:  Changed trial loop parameters; fixed bug where script would crash if 25 shocks were administered, MJS, DEB
%2010-05-20:  Script now creates raw data folder if needed.  Now requires SubID as a string rather than numeric
%2010-05-25:  Fixed bug with mkdir, JJC
%2010-05-25:  Change SubID arguement to numeric, JJC
%2010-06-25:  Modified to allow call from within other PTB script when providing W, DIO, & PortC
%2010-08-23:  Modified to give an error message the first time a value >100 is entered, DEB
%2011-02-08:  Changed SubID to string to revert to old procedures, JJC, DEB
%2011-04-13:  Modified to save output locally, JJC, DEB
%2011-03-22:  Added '_'after study name in case study name ends with number,DEB
%2011-04-23:  Modified to copy local output into subject folder on server, DEB
%2011-04-29:  Fine tuned new copy functions, DEB, JJC
%2013-11-08:  Ask RA to enter SubID and StudyName instead of input argument, JTK

%2015-11-09:  Changes to increase range of shocks recieved: Changed intervals between shocks to 12 from 10; Changed starting shock value to 3 from 11.
%This resulted in participant recieving 22 possible shocks in assessment from previous number of 25; changed name to ShockAssess_2, DEB
%2016-08-05:  Added to CurtinLibrary svn version control. Updated to make port assignment more flexible. Use IOOut instead of io32. JTK

try
    %% Poll user for SubID and study name
    SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
    StudyName = input('Enter Study Name (case sensitive)\n', 's'); %RA input StudyName as str
    
    %% Set path and filename to save data (info provided via function args or dialog box
    %Create Path to Local Directory on Computer
    if ispc
        LocalPath = ['C:\Local\Local' StudyName '\ShockAssessments\' SubID '\' ]; %local path on pc
    elseif isunix
        LocalPath = ['/home/ra/LocalCurtin/Local' StudyName '/ShockAssessments/' SubID '/' ]; %local path on linux
    end
    FileName = ['ShockRatings_'  StudyName '_' SubID '.dat']; %assumes that a ShockAssessments folder has already been made prestudy!
    
    %% Set up PTB and IO Hardware if not already setup (i.e., if not called within PTB script with 5 arguments
    %Setup PTB and IO hardware
    AssertOpenGL; %Check if PTB is properly installed on your system.
    WaitSecs(.001); GetSecs; %Move into memory for later high precision use
    
    %Open Window and configure text options
    W = Screen('OpenWindow', 0, 0, [], 32, 2);
    HideCursor; %On Linux this needs to occur after W is assigned for the first time
    Screen('TextFont',W, 'Calibri');
    Screen('TextSize',W, 36);
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black
    
    %IO card
    [DIO, PortA, PortB, PortC, UseIO] = ConfigIO; %Set up DIO card (PortB=Neuroscan; PortC = Shocker)
    ShockPort = PortC; %Assign shock output to portC
    IOOut(DIO, ShockPort, 0, UseIO) %Set Shock to 0
    
    %% Experiment Parameters and Data Arrays
    ShockValues = [3 15 27 39 51 63 75 87 99 111 123 135 147 159 171 183 195 207 219 231 243 255];
    ShockRatings = zeros(23,3); %array for shock ratings. Col1=SubID, Col2=ShockValues, Col3= rating;  22 rows for up to 22 shocks; will put max value in row 23
    ShockRatings(:,1) = str2double(SubID);
    CurrentRating = 0;
    ShockCnt = 0; %counter for shocks
    
    %Timing
    RateFeedDur = 3;  %Duration of Rating Feedback
    PrepMsgDur =  3;  %Duration of preparation message
    ShockMsgDur = .5;  %Shock is displayed on screen for .5s
    
    %% Trial Loop
    PauseMsg(W,'Turn box to READY\n\nPress SPACEBAR\n\n to start the assessment', TxtColor, BackColor);
    RateFeedTime = GetSecs;    %start with this timestamp to enter loop
    while ((ShockCnt < 22) && (CurrentRating < 100))
        ShockCnt = ShockCnt + 1;
        
        %Prep for shock
        DrawFormattedText(W, 'Prepare for Shock', 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);
        PrepMsgTime = Screen('Flip', W, RateFeedTime + RateFeedDur);
        
        %Present shock msg & shock
        DrawFormattedText(W, 'Shock', 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);
        ShockMsgTime = Screen('Flip', W, PrepMsgTime + PrepMsgDur);
        IOOut(DIO, ShockPort, ShockValues(ShockCnt), UseIO) %Admin Shock
        WaitSecs(.010); %wait 10ms
        IOOut(DIO, ShockPort, 0, UseIO) %clear port C after 10ms wait
        WaitSecs('UntilTime', ShockMsgTime+ShockMsgDur);
        
        %Rate intensity
        RateString = Ask(W,'Please rate the shock intensity (0 - 100)', TxtColor, BackColor,'GetString','center','center',36); % Accept keyboard input, but don't show it.
        Screen('Flip', W);
        
        if str2double (RateString) > 100
            RateString = Ask(W,'Error: Please reenter the shock intensity', TxtColor, BackColor,'GetString','center','center',36); % Accept keyboard input, but don't show it.
            Screen('Flip', W);
        end
        
        %Show rating immediately after entered
        DrawFormattedText(W, ['Participant''s rating was ' RateString], 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);
        RateFeedTime = Screen('Flip', W);
        
        %update shock intensity record
        ShockRatings(ShockCnt,2)= ShockValues(ShockCnt);
        CurrentRating = str2double(RateString);
        ShockRatings(ShockCnt,3)= CurrentRating;
    end
    WaitSecs(RateFeedDur)   %for last rating feedback
    
    %Report last shock value and rating in 23rd row to record max threshold
    ShockRatings(23,2)=ShockValues(ShockCnt);
    ShockRatings(23,3)= CurrentRating;
    
    %Prepare End Procedure Message
    DrawFormattedText(W, 'Procedure Complete\n\nThank you\n\nSwitch Box to Standby', 'center', 'center', TxtColor, 36)
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    Screen('Flip', W);
    WaitSecs(5);
    
    %% End of Shock Assess Program
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ListenChar(1);
    ShowCursor; %Show cursor again, if it has been disabled
    clear mex
    
    %% Save and Copy ShockAssessment dat file
    %Save Data
    fprintf('\n\nSaving files.\nDo not close Matlab yet.\n\n')
    DataSave(ShockRatings, FileName, LocalPath); % Write mat file to local computer with SubID (1), ShockValues(2), ShockRatings (3)
    fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
    
    %Copy Data
    if ispc
        if exist('P:\StudyData','dir') == 7 %if directory exists
        DataCopy (FileName, LocalPath, ['P:\StudyData\' StudyName '\RawData\' SubID]); %Copy mat file to server
        fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')
        end
    elseif isunix
        if exist('/home/ra/CurtinServer','dir') == 7 %if directory exists
        DataCopy (FileName, LocalPath, ['/home/ra/CurtinServer/KAYE2RawData/' SubID]); %Copy mat file to server
        fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')
        end
    end
    
catch TheError
    Screen('CloseAll'); %Close display windows
    Priority(0); %Shutdown realtime mode
    ShowCursor; %Show cursor again, if it has been disabled
    ListenChar(1);
    clear mex  %clear io32()
    
    %try to save mat files in case of PTB error
    DataSave(ShockRatings, FileName, LocalPath);
    
    rethrow(TheError);
end