%This script is called by startup.m locally for each matlab installation.
%This allows us to edit only this script but affect startup properties of
%all our matlab installations.  The somewhat setup is different from data collection
%machines vs. workstations.   
%We also use '-frozen' for all toolboxes to
%increase performance on all machines.  This is only an issue if you change contents of a
%toolbox folder outside of matlab.  In that instance, restart matlab for it
%to recognize the change(s)
%We also use genpath_exclude (located on server) to increase performance
%by excluding the svn folders from toolboxes under version control.

%Revision history
%2012-02-12:  released, MJS
%2012-02-12:  Last edited to update comments and add '-frozen', JJC
%2012-02-21:  Returned to use of _exclude for PhysBox folder, JJC
%2012-03-20:  EEGlab under version control again.  Added exclude, JJC
%2013-10-20:  Removed paths for specific general and PTB folders and replaced with CurtinLibrary
%2012-10-30:  Updated to reflect new location for toolboxes
%2016-12-02:  updated again for move of toolboxes
%2017-03-03:  Updated to one starup file that works on all workstations (including
              %data collection), JJC
%2017-03-10:  Added -frozen to all toolboxes to increase performance on all
              %machines
%2021-10-05: Corrected paths for new P drive layout. Commented out EEGLAB and LedaLab as they are no 
%            longer located there. (SEW)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Start code

%Get computer name to determine if it is a data collection machine
[status,name] = system('hostname');
name= deblank(name);

%Put C:\Local at front of path for data collection machines (this is where STUDYNAME.m files live)
%and put \Support from CurtinTasks toolbox at front of path for all other
%machines.  Data collection machines will use study specific \Support in \Programs 
%after running STUDYNAME.m to add that folder to the path
if(strcmpi(name, 'Contorter') || strcmpi(name, 'Bedlam') || strcmpi(name, 'Point') || strcmpi(name, 'Grays'))
    addpath('C:\Local', '-begin');
else
    addpath(genpath_exclude('P:\Toolboxes\ARCLibrary', {'\.svn'}), '-frozen', '-begin');    
end

%Put PhysBox toolbox at end of path but ignore svn folders
addpath(genpath_exclude('P:\Toolboxes\PhysBox', {'\.svn'}), '-frozen', '-end');    

%Put EEGlab toolbox at end of path but ignore svn folders 
%addpath(genpath_exclude('P:\Toolboxes\EEGLab', {'\.svn'}), '-frozen', '-end');   

%Puts LedaLab toolbox at end path but ignores svn folders
%addpath(genpath_exclude('P:\Toolboxes\LedaLab_349', {'\.svn'}), '-frozen', '-end');    