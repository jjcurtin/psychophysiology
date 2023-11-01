function RandVector = RandomSortVector(Vector)
%Randomly sorts (vector) stored as either an array or cell array
%Input
%Vector:  one-dimensional arrry or cell array
%Output
%RandVector: Random sort of Vector
%
%History
%2010-0315: relased v1, JJC

RandomIndices = RandomVector(length(Vector));

if iscell(Vector)
    RandVector = cell(1,length(Vector));
    for i=1:length(Vector)
        RandVector{i} = Vector{RandomIndices(i)};
    end
else
    RandVector = Vector(RandomIndices);
end
