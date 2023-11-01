function [VoiceTest] = TestAudioRecordPlay
%% TestAudioRecordPlay: Record Audio Response and PlayBack to make sure sound card functionality
%Usage: [VoiceTest] = TestAudioRecordPlay
%
%OUTPUT
%VoiceTest = sound recording object that can be saved as wav file
%
%Revision History
%2016-08-08:  Released, JTK Version 1

%% Initialize sound card
InitializePsychSound(1);  %initilze for low latency
KbCheck; %load for later use

%% Set parameters for visual display and sound card recording and playing audio
modePlay = 1; % audio play back only
modeRecord = 2; % audio capture only
freq = 44100; % a frequency of 44100 Hz
reqlatencyclassRecord = 0; % low latency control not important for recording
reqlatencyclassPlay = 2; %for low latency (agressive but consider 3)
nchannels = 2; % 2 sound channels for stereo capture
SoundCardID = []; %use default sound card, can modify if desired

WaitSecs(1); % Wait 1 secs

%SoundCardRecord: Open, Fill and Allocate Buffers
SoundCardRecord = PsychPortAudio('Open', SoundCardID, modeRecord, reqlatencyclassRecord, freq, nchannels); % This returns a handle to the audio device. Open sound card in recording mode.
PsychPortAudio('GetAudioData', SoundCardRecord, 10); % Preallocate an internal audio recording  buffer with a capacity of 10 seconds:

%SoundCardPlay: Open
SoundCardPlay = PsychPortAudio('Open', SoundCardID, modePlay, reqlatencyclassPlay, freq, nchannels);  % This returns a handle to the audio device. Open sound card in play back mode.
WaitSecs(1); % Wait 1 secs

% Wait for any key press on keyboard (for button box uncomment GetResponse)
fprintf('\n\nPress spacebar to Start Recording\n\n')
KbWait([], 3);  %waits until all keys released, key pressed and then key released
%GetResponse(now, 600, 1, 7, PortC, DIO,1);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS

% Record Verbal response
PsychPortAudio('Start', SoundCardRecord, 0, 0, 1); % Start recording

% Wait for any key press on keyboard
fprintf('\n\nSpeak into microphone now. Press spacebar to stop recording and start playback\n\n')
KbWait([], 3);  %waits until all keys released, key pressed and then key released
%GetResponse(now, 600, 1, 7, Port, DIO,1);  %timeout = 600s, correct response = , mask for lines 0,1,2; CHECK THIS

% Stop Recording
PsychPortAudio('Stop', SoundCardRecord);
VoiceTest = PsychPortAudio('GetAudioData', SoundCardRecord);

fprintf('\n\nPlayback now\n\n')
WaitSecs(1); % Wait for a moment for playback

% Play back Audio Test
PsychPortAudio('FillBuffer', SoundCardPlay, VoiceTest);

% Start playback immediately, wait for start, play once:
PsychPortAudio('Start', SoundCardPlay, 1, 0, 1);

% Wait for end of playback, then stop engine:
PsychPortAudio('Stop', SoundCardPlay, 1);

% Close the audio devices:
PsychPortAudio('Close', SoundCardRecord);
PsychPortAudio('Close', SoundCardPlay);

fprintf('\n\nTest complete\n\n')

end
