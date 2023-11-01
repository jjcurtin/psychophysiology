function ShockAssess()
%USAGE: ShockAssess()
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

try          
    %% Generate Startle Probe Presentation Time
    SubID = input('Enter SubID (4 or 5 digits)\n', 's'); %RA input SubID as str
    StudyName = input('Enter Study Name (case sensitive)\n', 's'); %RA input StudyName as str

    %% Set path and filename to save data (info provided via function args or dialog box
    %Create Path to Local Directory on Computer
    LocalPath = ['C:\Local\Local' StudyName '\ShockAssessments\' SubID '\' ];
    FileName = ['ShockRatings_'  StudyName '_' SubID '.dat']; %assumes that a ShockAssessments folder has already been made prestudy! 
    
    %% Set up PTB and IO Hardware if not already setup (i.e., if not called within PTB script with 5 arguments
    %Setup PTB and IO hardware   
    AssertOpenGL; %Check if PTB is properly installed on your system. 
    HideCursor;
    WaitSecs(.001); GetSecs; %Move into memory for later high precision use

    %Open Window and configure text options
    W = Screen('OpenWindow', 0, 0, [], 32, 2);
    Screen('TextFont',W, 'Calibri');
    Screen('TextSize',W, 36);      
    TxtColor = [255 255 255]; %Set to White
    BackColor = [0 0 0]; %Set to Black

    %IO card
    [DIO PortA PortB PortC UseIO] = ConfigIO; %Set up DIO card (PortB=Neuroscan; PortC = Shocker)
    io32(DIO,PortC,0); %code to set Shock Intensity to 0            
    
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
        io32(DIO,PortC,ShockValues(ShockCnt)); %admin shock
        WaitSecs(.010); io32(DIO,PortC,0); %clear port C after 10ms wait
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
    
    %Report last shock value and rating in 26th row to record max threshold
    ShockRatings(26,2)=ShockValues(ShockCnt);
    ShockRatings(26,3)= CurrentRating;
    
    %Prepare End Procedure Message
    DrawFormattedText(W, 'Procedure Complete\n\nThank you\n\nSwitch Box to Standby', 'center', 'center', TxtColor, 36)        
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    Screen('Flip', W);
    WaitSecs(5);   

    %% Save and Copy ShockAssessment mat file 
    DataSave(ShockRatings, FileName, LocalPath); % Write mat file to local computer with SubID (1), ShockValues(2), ShockRatings (3)
    DataCopy (FileName, LocalPath, ['P:\StudyData\' StudyName '\RawData\' SubID]); %Copy mat file to server

    %% End of Shock Assess Program
    Screen('CloseAll'); %Close display windows 
    Priority(0); %Shutdown realtime mode
    ListenChar(1);
    ShowCursor; %Show cursor again, if it has been disabled    
    clear mex

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