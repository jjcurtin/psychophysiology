%function ScoreSounds(Path)


[Y,FS,NBITS] = wavread(['1_blue2.wav']);

sound(Y,FS,NBITS)

% YAll = [];   
% Onset = zeros(5,1);
% for i=1:5    
%     [Y,FS,NBITS] = wavread(['Sound' int2str(i) '.wav']);
%     YF = abs(Y(:,1));
%     %YF = mean(YF,2);
%     %plot(YF)
%     Onset(i,1) = find(YF > .2,1); 
%     (Onset/44100) * 1000
%     YAll = [YAll YF];
% end
%     figure
%     plot(YAll)

%end
[Y,FS,NBITS] = wavread(['1_blue2.wav']);
Y = abs(Y(:,1));
nSDs = 20;
lBase = 1000;
T = mean(Y(1:lBase)) + std(Y(1:lBase))*nSDs
TimeMS =(1:length(Y))/44.1; 
%figure; plot(TimeMS, [Y (Y>T)*max(Y) repmat(T,length(Y),1)])
figure; plot(TimeMS, [Y repmat(T,length(Y),1)])

 
 