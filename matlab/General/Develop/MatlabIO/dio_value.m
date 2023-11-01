function rtrn = dio_value(in_value)
%**********************************************************
%File: dio_value.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine simply verifies the range of the shocker values.
%**********************************************************

global gShockerValue ;
if ((0 <= in_value) & (in_value <= 255))
    gShockerValue = in_value ;
    rtrn = true ;
else
    rtrn = false ;
end


