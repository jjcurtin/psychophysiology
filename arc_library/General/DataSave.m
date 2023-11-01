function DataSave(Object, Filename, Path)
%Usage: function DataSave(Object, Filename, Path)
%DataSave saves either an array as a .dat file using dlmwrite or a wav file using
%wavwrite.  Does all appropriate checks and will save file in C:\Local (PC) or /home/ra/ (Linux) if can't find/create
%Path or filename already exists in path.
%Note: wavwrite works in Matlab 2012 (used in 185R/L lab 2016_06) but will be depricated when Matlab is upgraded (>2015a)

if nargin < 3
    help DataSave;
    return
end

[~, ~, ext] = fileparts(Filename);
Success = 1;
if ~exist (Path, 'dir');  %verify that destination path folder exists.  If not, make it.
    [Success,~,~] = mkdir(Path);
end

if ~Success
    warning(sprintf('DataSave Error: Folder not available: %s', Path))
else
    if ~exist(fullfile(Path, Filename), 'file')
        switch ext
            case{'.wav'}
                if ispc
                wavwrite(Object, 44100, 16, fullfile(Path, Filename)); %Note wavwrite works in Matlab 2012 (used in 185R/L lab 2016_06) but will be depricated when Matlab is upgraded (>2015a)
                elseif isunix
                audiowrite(fullfile(Path, Filename), Object, 44100); %audiowrite replaces wavwrite in Matlab 2015b on. New Argument order
                end
            case{'.dat'}
                dlmwrite(fullfile(Path, Filename),Object,'delimiter','\t');
        end
    else
        warning(sprintf('DataSave Error: File already exists: %s', fullfile(Path, Filename)))
        Success = 0; % If file already exists on server, save in generic local folder
    end
end

if ~Success  %try to save file to generic Local folder (C  drive for PC, home/ra drive for Linux)
    if ispc
        switch ext
            case{'.wav'}
                %FUTURE CONSIDER UPDATING wavwrite to psychwavwrite, due to
                %backward compatibility issues post Matlab2015b. Same for
                %audiowrite below
                wavwrite(Object, 44100, 16, fullfile('C:\Local', Filename)); %Note wavwrite works in Matlab 2012 (used in 185R/L lab 2016_06) but will be depricated when Matlab is upgraded (>2015a)
            case{'.dat'}
                dlmwrite(fullfile('C:\Local', Filename),Object,'delimiter','\t');
        end
        warning(sprintf('DataSave Error: File saved as %s', fullfile('C:\Local', Filename)))
        
    elseif  isunix
        switch ext
            case{'.wav'}
                audiowrite(Object, 44100, 16, fullfile('/home/ra/', Filename));
            case{'.dat'}
                dlmwrite(fullfile('/home/ra/', Filename),Object,'delimiter','\t');
        end
        warning(sprintf('DataSave Error: File saved as %s', fullfile('/home/ra/', Filename)))
    end
end