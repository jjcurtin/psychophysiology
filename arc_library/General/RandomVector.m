function Y = RandomVector(n)
%Returns a vector with  random ordering of 1:n numbers
%Input
%n:  number of entries in vector (1:n)
%Output
%Y: vector with 1:n randomly ordered
%
%History
%2010-0315: relased v1, JJC
%2010-10-19: added change to random seed to avoid reproducing same random
%series across sessions

%set random stream based on clock time
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
iTaken=zeros(1,n);

i=1;
while i<=n
    x=ceil(n*rand);
    if iTaken(x)==0 
        Y(i)=x;
        iTaken(x)=1; 
        i=i+1;
    end
end