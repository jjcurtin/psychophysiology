%STARTUP.m   Startup file
%This is the startup file for Curtin Lab Installations of Matlab.
%It assumes you have direct file access to our server via mapped P drive. 
%It calls a file saved on P that will alter the matlab path to accomodate
%our custome functions, toolboxes, and plugins.  This allows us to edit
%only 'ARLStartup.m' and affect the function of all our matlab
%installations.
%2012-02-12, Deleted calls to addpath; added command to run a custom startup script from the lab's server, MJS
%2012-02-12: Updated comments, JJC
%2013-10-20: Updated to reflect new location of ARLStartup.m and to include all of Settings in path
%2017-03-10: Removed use of run and path in front of ARLStartup   Not needed
%2021-10-05: Updated paths (SEW)
path(pathdef);
addpath('P:\demos_docs\other_software\matlab\Settings');
ARCStartup;  %runs a script on the ARC server in settings that adds all of the paths needed for PTB, EEGLAB and PhysBox