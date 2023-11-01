function [ VI ] = ParseVarargin( VarIns )
%usage [ VI ] = ParseVarargin( VarIns )
%used to parse variable argument inputs (varargin) into a data structure
%with field names and values.  Assumes variable arguements were passed as:
%    'argname1, argvalue1, argname2, argvalue2, ...
%Returns data structure VI with fields and values for all variable
%arguments

%Revision history
%2011-08-17:  released, JJC, v1

    for i = 1:2:length(VarIns)
        VI.(VarIns{i}) = VarIns{i+1};
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAMPLE FUNCTION WITH VARARGIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [ output_args ] = GetVI( in1, varargin )
% 
%     fprintf('The required argument''s value was %d\n\n', in1)
% 
%     VI = ParseVarargin(varargin)
%     class(VI)
% 
% end