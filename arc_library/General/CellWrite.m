function CellWrite(filename, cellarray, mode)
%Writes contents of cell array to a text file
%mode can be (w)rite or (a)ppend (default is append).
%function based on:
%http://www.mathworks.com/matlabcentral/fileexchange/authors/17838

%2010-05-11:  Fixed bug in writing tabs, JJC
%2011-06-23: updated to accept mode and delimiter, JJC

if nargin < 3
    mode = 'a';
end

[rows, cols] = size(cellarray);
fid = fopen(filename, mode);
for i_row = 1:rows
    %file_line = '';
    for i_col = 1:cols
        contents = cellarray{i_row, i_col};
        if isnumeric(contents)
            contents = num2str(contents);
        elseif isempty(contents)
            contents = '';
        end
        if i_col<cols
            fprintf(fid,'%s\t',contents);
        else
            fprintf(fid,'%s\n',contents);
        end
    end

end
fclose(fid);