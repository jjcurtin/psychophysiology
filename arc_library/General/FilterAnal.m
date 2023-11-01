function [dB Hz, Octaves] = FilterAnal(B, A, SRate, Type)
%USAGE: [dB A Hz Octaves] = FilterAnal(B, A, SRate). A=1 for FIR filter
%Provides visual and quantitative analysis of digital filter
%Inputs
%B, A: Arrays of filter coefficients for digital filter
%SRate: Sample rate in Hz
%
%OUTPUTS
%dB and amplitude (A) attenuation by frequency (Hz) and Octaves
%

%Revision History
%2009-08-30: Released, JJC


    H = fvtool(B,A);  %Call fvtool.
    set(H, 'Fs', SRate);  %set sampling rate to 1000Hz to label x-axis appropriately
    if SRate <= 2000
        zoom(H, [0 100 -100 0])  %zooms to xmin xmax (0-100Hz, ymin, ymax (0 - -30dB)
    else
        zoom(H, [0 .1, -100 0])  %x scale changed to kHz
    end

    %To extract data series and report frequency for half power cutoff of filter (-3dB)
    lh=findall(gca,'type','line');
    Hz=get(lh,'xdata');
    dB=get(lh,'ydata');

    if SRate > 2000  %convert from kHz to Hz
        Hz = Hz .* 1000;
    end

    switch Type
        case 1  %lowpass
            HalfPower = Hz(find(dB < -3,1,'first'));
            fprintf('Filter half-power cutoff = %0.1fHz\n',HalfPower);
        case 2  %high pass
            HalfPower = Hz(find(dB > -3,1,'first'));
            fprintf('Filter half-power cutoff = %0.1fHz\n',HalfPower);     
        otherwise
            error ('Filter type (%d) must be low (1) or high (2)', Type);      
    end

A = 10.^(dB ./ 20);  %convert dB to amplitude gain
figure
plot(Hz, A);

Octaves = Log10(Hz) ./ Log10(2);  %covert Hz to logBase2(Hz)
figure
plot(Octaves,dB);


% dBp = [NaN dB(1:length(dB)-1)];
% Octavesp = [NaN Octaves(1:length(Octaves)-1)];
% PtSlope = (dB - dBp) ./ (Octaves - Octavesp);
% figure
% plot(Octaves, PtSlope)



