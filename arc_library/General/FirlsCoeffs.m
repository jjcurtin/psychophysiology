function [Coeffs] = FirlsCoeffs(CutOff, Type, SRate, NumPasses)
%USAGE:  [Coeffs] = FirlsCoeffs(CutOff, Type, SRate, NumPasses)
%Calculated filter coefficients for a FIRLS FIR filter based on specific
%filter type (low=1 or high=2), the fitler CutOff(in Hz), the SRate (in Hz)
%and the number of passes (forward=1 or two-way=2)

    Order = fix(SRate/CutOff);  %This is the default we use for Firls.  Single cycle leads to simplier IRF

    Nyq = fix(SRate / 2);

    switch Type
        case 1  %lowpass
            F = [0		CutOff/Nyq	(CutOff * 1.15)/Nyq	1];     %15% of filter transition band
            A = [1  1   0   0];
        case 2  %high pass
            F = [0		(CutOff * 0.85)/Nyq 	CutOff/Nyq 	1];     %15% of filter transition band
            A = [0  0 1 1];        
        otherwise
            error ('Filter type (%d) must be low (1) or high (2)', Type);      
    end

    InitCoeffs = firls(Order,F,A);

    switch NumPasses
        case 1  
            Coeffs = InitCoeffs;
        case 2  %apply filtfilt on impulse to get IRF.  Reverse IRF to get Coeffs
            Impulse = zeros (1,20000);
            Impulse(1,10000) = 1;
            IRF = filtfilt(InitCoeffs,1,Impulse);
            LI = find(IRF ~=0, 1,'first');
            HI = find(IRF ~=0, 1,'last');
            Coeffs = IRF(HI:-1:LI);
        otherwise
            error ('Number of Passes (%d) must be 1 0r 2', NumPasses);      
    end

end

