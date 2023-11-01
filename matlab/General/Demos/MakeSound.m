[y, freq] = wavread('coin');
figure
plot(y)
ynew = zeros(length(y)*2 -1,1);
size(ynew)

for i = 1:(length(y)-1)
    ynew((2*i-1),1) = y(i,1);
    ynew((2*i),1) = (y(i,1)+y(i+1,1)) / 2;    
end

figure
plot(ynew)
sound(y,22050)
sound(ynew,44100)

wavwrite(ynew, 44100, 'coin44100.wav')
