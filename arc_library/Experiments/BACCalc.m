function BACCalc()
%Usage: BACCalc()
%written by Rebecca Gloria & John Curtin
%Calculates alcohol dose in mls to achieve a specified target BAL based on
%subject parameters (age, height, weight, gender) and dosing parameters
%(target BAL, drining duration, proof and mixer/alcohol ratio)
%version 1
%
%Revision history
%2008-08-18: released, v1
%2010-06-01: updated to allow drink duration of 30 mins, JJC
%2010-06-18: changed default drink duration to 30 mins, JJC

    promptstr    = {'Age (years):', 'Gender (M/F): ', 'Height(inches): ', 'Weight (lbs):', 'Target BAL (e.g., .08):', 'Drinking Duration (mins):', 'Proof:', 'Ratio (Mixer/Alcohol):' };
    inistr       = {'', '', '', '', '.08', '30', '100', '3'};
    result       = inputdlg( promptstr, 'Enter BAL Calculator Parameters', 1,  inistr);       
    if isempty( result ); return; end;

    Age = str2double(result{1});
    if Age < 21 || Age > 50
        error ('Age (%d) outside of acceptable range', Age);
    end

    Gender = upper(result{2});
    if ~(strcmp(Gender, 'M') || strcmp(Gender, 'F'))
        error('Gender(%s) invalid (M or F)', Gender);
    end

    Height = str2double(result{3});
    if Height < 58 || Height > 84
        error ('Height (%d) outside of acceptable range (58-84 inches)', Height);
    end
    Heightcm = Height / 0.3937;

    Weight = str2double(result{4});
    if Weight < 90 || Weight > 275
        error ('Weight (%d) outside of acceptable range (90-275lbs)', Weight);
    end
    Weightkg = Weight / 2.2046;

    BAL = str2double(result{5});
    if BAL < .04 || BAL > .15
        error ('BAL (%d) outside of acceptable range (.04 - .15%).', BAL);
    end

    DD = str2double(result{6});
    if DD < 30 || DD > 120
        error ('Drinking Duration (%d) outside of acceptable range (30-120 mins).', DD);
    end
    DDhr = DD / 60;

    Proof = str2double(result{7});
    if Proof < 100 || Proof > 200
        error ('Proof (%d) outside of acceptable range (100-200 proof).', Proof);
    end

    Ratio = str2double(result{8});
    if Ratio < 3 || Ratio > 6
        error ('Ratio (%d) outside of acceptable range (3-6).', Ratio);
    end

    if (strcmp(Gender, 'M'))
      %TBW formula for men
      TBW = 2.447 - 0.09516 * Age + 0.1074 * Heightcm + 0.3362 * Weightkg;
    else
      %TBW formula for women
      TBW = -2.097 + 0.1069 * Heightcm + 0.2466 * Weightkg;
    end

    %Calc Alc dose in grams
    AlcG = ((10 * BAL * TBW) / 0.8) + (10 * 0.015 * (DDhr + 0.5)) * (TBW / 0.8);

    %convert to mls
    AlcDose = AlcG / 0.7861;

    %adjust for proof
    AlcDose = AlcDose / (Proof / 200);
    AlcDose = round(AlcDose);%round to nearest integer
    MixDose = AlcDose * Ratio;
    MixDose = round(MixDose);%round to nearest integer
    TotDose = AlcDose + MixDose;

    fprintf('Volume of Alcohol (mls) = %d:\n',AlcDose);
    fprintf('Volume of Mixer (mls) = %d:\n',MixDose);
    fprintf('Total Drink Volume (mls) = %d:\n\n',TotDose);
    fprintf('This is equivalent to approximately %2.1f shots of %d proof alcohol\n',(AlcDose/45), Proof);
end

