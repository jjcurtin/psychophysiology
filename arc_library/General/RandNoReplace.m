function [Number, NewPrevious] = RandNoReplace(LowAnchor,HighAnchor,Integer,Previous)
%USAGE: [Number, NewPrevious] = RandNoReplace(LowAnchor,HighAnchor,Previous)
%Generates a random number between LowAnchor and HighAnchor.  Previous =[]
%this number will be unconstrained.  If Previous contains numbers, NUMBER
%will not match any entris in Previous (allows for random sampling without
%replacement.
%INPUTS
%Number range = [LowAnchor HighAnchor]
%Integer: (T)rue = integer only values, (F)alse = real values
%Previous:  [] = unconstrained random.  Otherwise, Previous can be used to
%avoid reproducing the same random value (best used with integer to
%simulate random sampling without replacement).  Previous contains
%previously used numbers.  Number will not match any value in Previous
%OUTPUTS
%Number = random number generaged
%NewPrevious = update to Previous that includes Number
%coded by John Curtin, jjcurtin@wisc.edu

%Revision history
%2009-0410:  Released, JJC, v1

rng('shuffle'); %seed the random number generator (otherwise you will get the same random numbers everytime, Matlab won't produce truely randomly numbers with seeding it)
Number = [];
while isempty(Number) || any(Previous == Number)
    
    if upper(Integer) == 'T'
        Number = (LowAnchor - .5) + ((HighAnchor-LowAnchor) +1).*rand(1,1);
        Number = round(Number);
    else
        Number = LowAnchor + (HighAnchor-LowAnchor).*rand(1,1);
    end
end

if isempty(Previous)
    NewPrevious = Number;
else
    NewPrevious = zeros(1,(length(Previous)+1));
    NewPrevious(1,1:end-1) = Previous;
    NewPrevious(1,end) = Number;
end
    

