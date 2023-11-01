function DataCopy(Filename, SourcePath, DestPath)
%usages: function DataCopy(Filename, SourcePath, DestPath)
%DataCopy copies Filename from SourcePath to DestPath and performs
%all approrpriate checks.  Will make DestPath if needed

if nargin < 3
    help DataCopy;
    return
end

Success = 1;
if ~exist (DestPath, 'dir');  %verify that destination path folder exists.  If not, make it.
    [Success,Message,MessageID] = mkdir(DestPath);
end

if ~Success
    warning(sprintf('DataCopy Error: Folder not available: %s', DestPath))
    
elseif Success
    if exist(fullfile(SourcePath, Filename), 'file')
        if ~exist (fullfile(DestPath, Filename), 'file')
            copyfile (fullfile(SourcePath, Filename),fullfile(DestPath, Filename))
        else
            warning(sprintf('DataCopy Error: File already exists: %s', fullfile(DestPath, Filename)))
        end
        
    else
        warning(sprintf('DataCopy Error: File not found: %s', fullfile(SourcePath, Filename)))
    end
end

end