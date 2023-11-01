%Usage: [Paused, EndTime] = DelayPause(WPtr, DelayTime)
%Delays in loop for DelayTime  seconds.
%Restart with second key press.  Will put restart message on for specified s.  
%and then return display to previous display.
%To redo remainder of period, update time variable with EndTime.
%Paused is boolean to indicate if pause was implemented
%Do not assume accurate timing.  Leave fudge room!

%Revision History
%2010-03-16: Released version 1, JJC
%2010-04-11:  fixed bug with WPtr specification below,JJC
%2010-12-8: fixed bug where error was left into if statement from testing purposes, DB
%2010-12-9: removed redudant code and simplified DB
%2010-12-10:  changed waitsecs to include yieldsecs parameter.   JJC
%2012-12-28: Moved position of WaitSecs for more logical code. DB, KPM


function [Paused, EndTime] = DelayPause(WPtr, DelayTime)
     Paused = false;
     StartTime = GetSecs;
     while  (GetSecs < (StartTime + DelayTime));
         if KbCheck %check for key down        
             Paused = true;     
             PauseMsg(WPtr, 'Experiment Paused.  Press any key to RESTART');         
             WaitMsg(WPtr, 'Experiment will re-start in 5 seconds', 5, [255 255 255], [0 0 0]);           
             break  %terminate while loop regardless of time
         end
         %WaitSecs(.001);
         WaitSecs('YieldSecs', .005)  %necessary for kbcheck to work!
     end   
     EndTime = GetSecs;
end
