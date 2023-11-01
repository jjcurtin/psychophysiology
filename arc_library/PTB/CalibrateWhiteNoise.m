%USAGE: CalibrateWhiteNoise
%Used to present long white noise probe for external calibration
%Uses ASIO low latency driver.  Uses WNProbeLong.wav file, which
%must be in the path

function CalibrateWhiteNoise

    %load white noise
    [y, freq] = wavread('wnprobelong');  %assumes file is in path
    noise = y';
    InitializePsychSound(1);  %1=set for low-latency
    PsychPortAudio('Verbosity', 10);
    
    reqlatencyclass = 2;  %for low latency
    SoundCard = PsychPortAudio('Open', [], [], reqlatencyclass, [], [], []);
    PsychPortAudio('FillBuffer', SoundCard, noise);
    
    while KbCheck; end;
    fprintf('\n\nCalibrateWhiteNoise will play long white noise probe for external calibration.\n');
    fprintf('Press ANY Key to START White Noise\n\n');
    KbWait;
    fprintf('White Noise will begin in 5s....\n');
    
    PsychPortAudio('Start', SoundCard, 1, inf, 0);
    WaitSecs(0.2);
    Now = GetSecs;
    PsychPortAudio('RescheduleStart', SoundCard, Now+3, 0);
    WaitSecs('UntilTime', Now+3);
    PsychPortAudio('Stop', SoundCard, 1);
    PsychPortAudio('Close');
end
