function [VoiceTest] = TestVerbalInput(W, Port, DIO, SoundCardID)
%% TestVerbalInput: Record Audio Response and PlayBack to make sure can hear participant well enough
%Usage: [VoiceTest] = TestVerbalInput(W, Port, DIO, SoundCardID)
%
%INPUTS
%W = Window pointer
%Port = Typically PortA in CurtinLab PC or PortC in CurtinLab Linux, Input
%DIO = digital IO device
%
%OUTPUT
%VoiceTest = sound recording object that can be saved as wav file
%
%Revision History
%2013-11-11:  Released, JTK Version 1
%2016-08-16:  Made Linux compatible and allow different sound card
%selection besides default

%Input requirements
if nargin < 3
    error('Must provide at least 3 arguments')
end

if nargin < 4 
	SoundCardID = [];
end

%% Set parameters for visual display and sound card recording and playing audio
TxtColor = [255 255 255]; %Set to White
BackColor = [0 0 0]; %Set to Black
modePlay = 1; % audio play back only
modeRecord = 2; % audio capture only
freq = 44100; % a frequency of 44100 Hz
reqlatencyclassRecord = 0; % low latency control not important for recording
reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
nchannels = 2; % 2 sound channels for stereo capture

%% Start function
%SoundCardRecord: Open, Fill and Allocate Buffers
SoundCardRecord = PsychPortAudio('Open', SoundCardID, modeRecord, reqlatencyclassRecord, freq, nchannels); % This returns a handle to the audio device. Open sound card in recording mode.
PsychPortAudio('GetAudioData', SoundCardRecord, 10); % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:

%SoundCardPlay: Open
SoundCardPlay = PsychPortAudio('Open', SoundCardID, modePlay, reqlatencyclassPlay, freq, nchannels);  % This returns a handle to the audio device. Open sound card in play back mode.

repeatVoiceTest = 1;
while repeatVoiceTest  == 1 || repeatVoiceTest == 4 %Accept 1 for Button Box and 4 for Right SHIFT key keyboard
    
    WaitSecs(1); % Wait 0.5 secs because button box is sensitive
    Screen('FillRect', W, BackColor);
    DrawFormattedText(W, 'Now we are going to test the microphone.\nWhen the next slide appears please say \n "YES".\n\nPlease remove headphones\nPress any key to begin voice test', 'center', 'center', TxtColor, 36,[],[],1.5);
    Screen('DrawingFinished', W);
    now = Screen('Flip', W);
    
    % Wait for any key press on button box
%    if ispc
    GetResponse(now, 600, 1, 7, Port, DIO,1);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
%    elseif isunix % UNCOMMENT IF USING KEYBOARD
%        GetResponse(now, 600, 1, 7, Port, DIO,1,0);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
%    end
    %don't use PauseMsg because use box instead
    %PauseMsg(W,'Voice Input Test\nRemove headphones from ears\nPress any key to begin initiate test', TxtColor, BackColor)
    
    WaitSecs(1); % Wait 1sec because button box is sensitive
    Screen('FillRect', W, BackColor);
    DrawFormattedText(W, 'Please say "YES"\nPress any key to stop recording', 'center', 'center', TxtColor, 36,[],[],1.5);
    Screen('DrawingFinished', W);
    now = Screen('Flip', W);
    
    % Record Verbal response
    PsychPortAudio('Start', SoundCardRecord, 0, 0, 1); % Start recording
    
    % Wait for any key press on button box
%    if ispc
        GetResponse(now, 600, 1, 7, Port, DIO,1);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
%     elseif isunix % UNCOMMENT IF USING KEYBOARD
%         GetResponse(now, 600, 1, 7, Port, DIO,1,0);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
%     end

    
    PsychPortAudio('Stop', SoundCardRecord);
    VoiceTest = PsychPortAudio('GetAudioData', SoundCardRecord);
    
    Screen('FillRect', W, BackColor);
    DrawFormattedText(W, 'Playing Recorded Input', 'center', 'center', TxtColor, 36,[],[],1.5);
    Screen('DrawingFinished', W);
    Screen('Flip', W);
    
    WaitSecs(1); % Wait for a moment for playback
    
    % Play back Audio Test
    PsychPortAudio('FillBuffer', SoundCardPlay, VoiceTest);
    
    % Start playback immediately, wait for start, play once:
    PsychPortAudio('Start', SoundCardPlay, 1, 0, 1);
    
    % Wait for end of playback, then stop engine:
    PsychPortAudio('Stop', SoundCardPlay, 1);
    
    % Wait for any key press on button box; Right = repeat, Left = continue
    Screen('FillRect', W, BackColor);

%    if ispc
    DrawFormattedText(W, 'Repeat Voice Test?\n\nPress right button to repeat\nPress left button to continue', 'center', 'center', TxtColor, 36,[],[],1.5);
    now = Screen('Flip', W);
    [~, repeatVoiceTest] = GetResponse(now, 600, 1, 7, Port, DIO,1);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
        
%     elseif isunix
%         DrawFormattedText(W, 'Repeat Voice Test?\n\nPress right SHIFT to repeat\nPress left SHIFT to continue', 'center', 'center', TxtColor, 50,[],[],1.5);
%         now = Screen('Flip', W);
%         [~, repeatVoiceTest] = GetResponse(now, 600, 1, 7, Port, DIO,1,0);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS
%     end

end

% Close the audio devices:
PsychPortAudio('Close', SoundCardRecord);
PsychPortAudio('Close', SoundCardPlay);

Screen('FillRect', W, BackColor);
Screen('DrawingFinished', W);
Screen('Flip', W);

end