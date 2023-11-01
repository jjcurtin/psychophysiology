function IOOut(IOCard,Port,Output,UseIO)

    if nargin < 4
        UseIO = 1;
    end

    if UseIO
        if ispc
            io32(IOCard,Port,Output);
        elseif isunix
            DaqDOut(IOCard, Port, Output);
        end
    end

end

