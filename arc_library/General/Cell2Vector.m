function IntArray = Cell2Vector(CellArray)
%Converts a string or numeric cell array to a vector integer array.
%Only works with 1 or 2 dimensional cell arrays

    [r c] = size(CellArray);
    NumCells = r * c;
    IntArray = zeros(NumCells, 1);
    IsString = ischar(CellArray{1}); 
    for i = 1:NumCells
        if IsString
            IntArray(i) = str2double(CellArray{i});
        else
            IntArray(i) = CellArray{i};
        end
    end
end
