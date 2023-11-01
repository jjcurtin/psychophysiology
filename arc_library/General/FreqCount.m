function EventCount = FreqCount(DataArray)
%Lists frequency counts of entries in DataArray

EventCount = unique(DataArray(:));
EventCount(:,2) = 0;

for i = 1:size(EventCount,1)
    EventCount(i,2) = length(find(DataArray == EventCount(i,1)));
end