function [StringData] = FormatDisplay (Data,Format,NumChars, Display)
%version 1
%USAGE [StringData] = FormatDisplay (Data,Format,NumChars, Display)
%Converts numeric array to string array with specific format.
%Useful for display of numeric data with varying format across columns
%Data:  Numeric array
%Format: Cell array with string format code (e.g. %0.3f' see sprintf for %details)
%NumChars:  Number of characters per column (will pad with leading space)
%Display:  (T)rue or (F)alse.  Default is T.  F will suppress output

%Revision History
%2009-03-30:  Released, v1, JJC


if nargin < 4
    Display = 'T';
end

[Rd Cd] = size (Data);
Cf = length(Format);

if Cd ~= Cf
    error('Data does not match Format');
end

for r = 1:Rd
    StringLine = '';
    for c = 1:Cd
        StringValue = num2str(Data(r,c),Format{c});
        while length(StringValue) < NumChars
            StringValue = [' ' StringValue];
        end
        StringLine = [StringLine StringValue];
    end
    StringData(r,:) = StringLine;
end

if upper(Display) == 'T'
    disp(StringData)
end

end