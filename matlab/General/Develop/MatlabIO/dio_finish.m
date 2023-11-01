%**********************************************************
%File: dio_finish.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%finish using the dio board.
%**********************************************************

clear gShockerValue ;
delete(shocker_safety) ;
clear shocker_safety ;

delete(shocker_trigger) ;
clear shocker_trigger ;

delete(shocker_power_on) ;
clear shocker_power_on ;

delete(shocker_value) ;
clear shocker_value ;

delete(dio) ;
clear dio ;

