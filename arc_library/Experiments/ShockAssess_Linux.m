function ShockAssess_Linux()
%USAGE: ShockAssess_Linux()
%Script to conduct shock sensitivity assessment.
%Saves ShockRatings_StudyName_SubID.dat as output to local study folder
%Copies dat file to study folder on server

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
%2016-07-18:  Created Linux-compatible ShockAssessLinux, JTK, JJC

try
    %% Generate Startle Probe Presentation Time
    SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
    StudyName = input('Enter Study Name (case sensitive)\n', 's'); %RA input StudyName as str
    
    %% Set path and filename to save data (info provided via function args or dialog box
    %Create Path to Local Directory on Computer
    LocalPath = ['/home/ra/LocalCurtin/Local' StudyName '/ShockAssessments/' SubID '/' ]; %local path on linux
    FileName = ['ShockRatings_'  StudyName '_' SubID '.dat']; %assumes that a ShockAssessments folder has already been made prestudy!
    
    %% Set up PTB and IO Hardware if not already setup (i.e., if not called within PTB script with 5 arguments
    %Setup PTB and IO hardware
    AssertOpenGL; %Check if PTB is properly installed on your system.
    Priority(1);
    WaitSecs(.001);  %Move into memory for later high precision use
    GetSecs; %Move into memory for later high precision use

    %Open Window and configure text options
    W = Screen('OpenWindow', 0, 0, [], 32, 2);
    HideCursor(W);
    Screen('TextFont',W, 'Calibri');
    Screen('TextSize',W, 50); %50pt font     
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black

    %% Set up DIO card
    %PortA = Shock Box; PortB = Event Codes to Grael/Curry; PortC = Input
    [DIO, PortA, PortB, PortC, UseIO] = ConfigIO;
    ShockPort = PortA;
    IOOut(DIO, ShockPort, 0, UseIO) %Set Shock to 0
    
    %% Experiment Parameters and Data Arrays
    ShockValues = [11 21 31 41 51 61 71 81 91 101 111 121 131 141 151 161 171 181 191 201 211 221 231 241 251];
    ShockRatings = zeros(26,3); %array for shock ratings. Col1=SubID, Col2=ShockValues, Col3= rating;  25 rows for up to 25 shocks put max value in row 26
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
    while ((ShockCnt < 25) && (CurrentRating < 100))   
        ShockCnt = ShockCnt + 1;
        
        %Prep for shock
        DrawFormattedText(W, 'Prepare for Shock', 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);
        PrepMsgTime = Screen('Flip', W, RateFeedTime + RateFeedDur);

        %Present shock msg & shock
        DrawFormattedText(W, 'Shock', 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);    
        ShockMsgTime = Screen('Flip', W, PrepMsgTime + PrepMsgDur);  
        
        IOOut(DIO, ShockPort, ShockValues(ShockCnt), UseIO) %Administer Shock
        WaitSecs(.010); %Wait 10ms to clear Port A
        IOOut(DIO, ShockPort, 0, UseIO) %Clear Port A
        
        WaitSecs('UntilTime', ShockMsgTime+ShockMsgDur);
                
        %Rate intensity
        DrawFormattedText(W, 'Please rate the intensity (0 - 100)', 'center', 'center', TxtColor, 36)
        Screen('DrawingFinished', W);
        Screen('Flip', W);
        RateString = input('Rate\n', 's'); %RA input Rating as str
        
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
    
    %Report last shock value and rating in 26th row to record max threshold
    ShockRatings(26,2)=ShockValues(ShockCnt);
    ShockRatings(26,3)= CurrentRating;
    
    %Prepare End Procedure Message
    DrawFormattedText(W, 'Procedure Complete\n\nThank you\n\nSwitch Box to Standby', 'center', 'center', TxtColor, 36)        
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    Screen('Flip', W);
    WaitSecs(2);   
    
    %% Save and Copy ShockAssessment dat file
    %Save Data
    fprintf('\n\nSaving files.\nDo not close Matlab yet.\n\n')
    DataSave(ShockRatings, FileName, LocalPath); % Write mat file to local computer with SubID (1), ShockValues(2), ShockRatings (3)
    fprintf('\n\nCopying files to the server.\nDo not close Matlab yet.\n\n')
    
    %Copy Data
    DataCopy (FileName, LocalPath, ['/home/ra/CurtinServer/KAYE2RawData/' SubID]); %Copy mat file to server
    fprintf('\n\nCopying complete. Data successfully copied to the server!\n\n')

    %% End of Shock Assess Program
    Screen('CloseAll'); %Close display windows 
    ShowCursor; %Show cursor again, if it has been disabled    
    Priority(0);
    clear KbWait

catch TheError
    Screen('CloseAll'); %Close display windows
    ShowCursor; %Show cursor again, if it has been disabled    
    Priority(0);
    clear KbWait

    %try to save mat files in case of PTB error
    DataSave(ShockRatings, FileName, LocalPath);
    
    rethrow(TheError);        
end