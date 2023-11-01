%**********************************************************
%File: dio_config.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%configure the PCI-DIO24 board for use with the 
%Psychology Department Shocker
%Pinouts
%   Shocker         PIC_DIO24       Description
%   30 - 37         30 - 37 (A0-A7) Data lines which control shocker intensity
%   9               10 (B0)         Shocker trigger (positive logic)
%   10              9 (B1)          Shocker safety (negative logic)
%   28              29              Power on indicator from Shocker 
%Note: this configuration is for Wen Li's system and may not translate
%to other systems directly.  Board numbers and pin-outs could be different.
%**********************************************************

global gShockerValue ;
gShockerValue = 0 ;

% Grab the PCI_DIO24 board.  In this case it's the 0 board while
% the USB device is the 1 board.
dio = digitalio('mcc',0) ;
shocker_value = addline(dio,0:7,0,'Out') ;
shocker_power_on = addline(dio,0,2,'In') ;
shocker_trigger = addline(dio, 0, 1, 'Out') ;
shocker_safety = addline(dio, 1, 1, 'Out') ;
physiologic_acquisition = addline(dio, 2, 1, 'Out') ;

% Set system to safety position 
putvalue(shocker_value, 0) ;
putvalue(shocker_safety, 1) ;  % Negative logic, 1 = no trigger
putvalue(shocker_trigger, 0) ;