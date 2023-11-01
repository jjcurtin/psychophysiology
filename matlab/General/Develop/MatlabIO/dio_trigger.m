%**********************************************************
%File: dio_trigger.m
%Date: 10-03-08
%PCI-DIO24 with MATLAB
%This routine triggers the shocker.
%%**********************************************************

global gShockerValue ;


% going for maximum safety, the shocker value is kept at zero.
% The first step is to put the shocker value on the bus.
% And take the safety off.
putvalue(shocker_trigger, 0) ;  % Positive logic.  The trigger is off.
putvalue(shocker_safety, 0) ;   % Negative logic.  The safety is off.
putvalue(shocker_value, gShockerValue) ;  % The value is now set.

% Run a timer to make sure the value propogates to the hardware.
% For now, approximately 20ms.
pre_shock_timer = timer('Period', 0.020);
wait(pre_shock_timer) ;

%This routine sends the signal for the shocker to shock.
%%**********************************************************

% Assume the system has been set up to shock.
% Trigger off, safety off and shock value placed on the bus.
putvalue(shocker_trigger, 1) ;  % Positive logic.  Trigger the shock.

% Run a timer to make sure the value propogates to the hardware.
% For now, approximately 50ms.
trigger_timer = timer('Period', 0.050);
wait(trigger_timer) ;

% The setting of the shocker into a safe state is passed to dio_max_safety.
% Assume the has just sent a shock.
% Trigger on, safety off and shock value placed on the bus.
putvalue(shocker_trigger, 0) ;  % Positive logic.  Trigger is off.
putvalue(shocker_safety, 1) ;   % Negative logic.  Safety is on.
putvalue(shocker_value, 0) ;    % Put zero on the bus.

delete(pre_shock_timer) ;
clear pre_shock_timer ;

delete(trigger_timer) ;
clear trigger_timer ;