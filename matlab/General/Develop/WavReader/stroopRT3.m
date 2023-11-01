RootPath = 'P:\UW\Users\Kaye\stroop matlab\';
RootFile = 'dmdx004(1)';
Trial = ['111104'];
NTrials = 1; % modify to be number of trials or number of wav files
OutFileName = 'StroopRTdata';
i = 1;
for i = 1:NTrials;
FileName = [RootPath RootFile Trial, '.wav'];
t = fopen(FileName);
data = fread(t);
RT = 5;
RTdata(i,1) = Trial(i);
RTdata(i,2) = RT;
i = i+1;
end

dlmwrite([RootPath OutFileName] ,RTdata,'-append', 'delimiter',' ', 'newline','pc', 'precision',5) % pc implies carriage return/line feed
