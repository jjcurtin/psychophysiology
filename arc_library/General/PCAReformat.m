% PCAReformat - J. Curtin, v1.0 11/8/2006
% Used to reformat our typical raw ERP data format (Rows - subjects and
% time, Columns = sites and conditions) to the input format for temporal PCA analysis
% (Rows = subjects, and conditions, and sites; Columns = Time).  This M-file
% will also downsample the time dimension to increase the stability of the
% solution (i.e., increase the rations of cases to "variables").
% Important variables/data structures include:
% 1.  infile - original data file.  Has fields for data (which include subid
% and time in the first two columns) and colheaders (which includes the
% site by condition labels).
% 2.  pcafile - reformatted (and resampled) data file.  Has fields for data
% (which has subid and numeric index for condition by site information in
% the first two columns) and colheaders (which includes the resampled time
% labels for each column of the data matrix)
% Other variables that might be helpful include numcondbysite, numsamples
% (per subject), numsubs, resample (number of samples averaged in the
% resample process)

%Open data file
message = {'M-file assumes that ERP data begin in column 3'};
uiwait(warndlg(message,'','modal'))
[fname,dirpath] = uigetfile('*.dat');
%fullname = [dirpath fname];
infile = open([dirpath fname]);

numcondbysite = size(infile.data,2) - 2; % two less columns b/c of subid and time

%block to count number samples
numsamples = 1; 
subid = infile.data(1,1);
while subid == infile.data(numsamples+1,1)
    numsamples = numsamples+1;
end

%block tocount number subjects
numsubs = 1; 
subid = infile.data(1,1);
for i = 2:size(infile.data,1)
    if subid ~= infile.data(i,1) 
        numsubs = numsubs +1;
        subid = infile.data(i,1);
    end
end

%block to transpose infile.data into pcafile.data
pcafile.data = zeros(0,numsamples+2);
startindex = 1;
endindex = startindex + numsamples-1;
while endindex <= size(infile.data,1)
    caseinfo = ones(numcondbysite,2);  %caseinfo holds subid and condition info
    caseinfo(:,1) = caseinfo(:,1) * infile.data(startindex,1); % set first column to subid
    caseinfo(:,2) = (1:size(caseinfo,1))'; %set second col to increasing series to track condXsite
    transposeddata = [caseinfo (infile.data(startindex:endindex,3:end))']; % combine caseinfo and transposed ERP data
    pcafile.data = [pcafile.data; transposeddata];      % add tranposed data under existing data from previous iterations
    startindex = endindex +1;
    endindex = startindex + numsamples-1;
end
pcafile.colheaders = infile.data(1:numsamples,2); %get timepoints and list as column headers for transposed file
pcafile.condlabels = infile.colheaders(3:end);   %save old col labels to label cond col later

%block to resample file to reduce timepoints.
resample = input('Enter # points to average: ');
if mod (numsamples, resample) > 0 
    message = {'Number samples not evenly divisable by resample.\nNo resampling is conducted'};
    uiwait(warndlg(message,'','modal'))
elseif resample > 1
        resampledata = zeros(size(pcafile.data,1),numsamples/resample+2);
        for r = 1:size(pcafile.data,1)
            resampledata(r,1:2) = pcafile.data(r,1:2);
            i = 3;  
            for c = 3:resample:size(pcafile.data,2)-resample+1
                resampledata(r,i) = mean(pcafile.data(r,c:c+resample-1));
                i = i+1;
            end
        end
        
        i=1;
        resamplecolheaders = zeros(numsamples/resample,1);
        for c = 1:resample:size(pcafile.colheaders,1)-resample+1
            resamplecolheaders(i,1) = mean(pcafile.colheaders(c:c+resample-1));
            i = i+1;
        end
        
        pcafile.data = resampledata;
        pcafile.colheaders = resamplecolheaders;
end

%Conduct the PCA on the pcafile data.  See erpPCA m-file for details
%[LU,LR,FSr,VT] = erpPCA(pcafile.data(:,3:end));

