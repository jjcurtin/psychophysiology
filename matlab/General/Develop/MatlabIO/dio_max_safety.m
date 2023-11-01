%**********************************************************
%File: dio_max_safety.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine puts the shocker into maximum safety state.
%%**********************************************************

% Assume the has just sent a shock.
% Trigger on, safety off and shock value placed on the bus.
putvalue(shocker_trigger, 0) ;  % Positive logic.  Trigger is off.
putvalue(shocker_safety, 1) ;   % Negative logic.  Safety is on.
putvalue(shocker_value, 0) ;    % Put zero on the bus.