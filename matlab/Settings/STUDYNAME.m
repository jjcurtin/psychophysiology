%This file modifies the matlab path of a data collection machine for a
%specific study (STUDYNAME).   During development you will want the first path 
%(but not the second) uncommented.  Development path is not frozen in case
%changes are made that need to be recognized immediately
%During study execution you will want the second path uncommented (but not the first)
%The second path is added frozen because no further changes should be
%happening.


%UNCOMMENT DURING DEVELOPMENT
%addpath(genpath_exclude('P:\Toolboxes\CurtinTasks\', {'\.svn'}), '-begin');


%UNCOMMENT DURING STUDY EXECUTION (UPDATE STUDYNAME TO YOUR STUDYNAME)
%addpath(genpath('P:\StudyData\STUDYNAME\Programs\'), '-begin', '-frozen');