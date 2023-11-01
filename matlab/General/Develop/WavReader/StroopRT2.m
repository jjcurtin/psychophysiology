%-- 12/2/10  1:51 PM --%
help fopen
doc fopen
help wav
help wavread
Y=WAVREAD('dmdx004(1)111101')
Y=wavread('dmdx004(1)111101')
doc wavread
siz = wavread(filename,'size')
siz = wavread('dmdx004(1)111101','size')
v = sin(2*pi*466.16*[0:0.000125:1.0]);
size(v)
plot(v);
wavwrite(v, 'asharp.wav');
t = wavread('asharp.wav')
size(t)
t = wavread('sampleword.WAV')
t = wavread('newsampleword.WAV')
help wavread
t = wavread('sampleword.WAV')
t = wavread('sampleword.WAV',1)
t = wavfinfo('sampleword.WAV',)
t = wavfinfo('sampleword.WAV')
t
help load
help open
t = open('sampleword.WAV')
t = fopen('sampleword.WAV')
doc fread
data = fread(t)
size(data)
wavwrite(t, 'test.wav');
doc wavwrite
wavwrite(t, 22000, 'test.wav');
wavwrite(t, 22000, 'test1.wav');
t(1:1000)
t(1:1000,1)
size(t)
data = fread(t)
wavwrite(data, 22000, 'test.wav');
wavwrite(data, 22000, 'test2.wav');
size(data)
data = fread(3)
t = fopen('sampleword.WAV')
data = fread(t)
size(data)
wavwrite(data, 22000, 'test3.wav');
data
data(1:100)
plot(data)
plot(data(2:2:lenght(data)))
data(2:2:length(data))
plot(data(2:2:length(data)))
help fread
data = fread(t, 'int16')
data = fread(t)
t
data = fread(t)
t = fopen('sampleword.WAV')
data = fread(t)
t = fopen('sampleword.WAV')
data = fread(t, 'int16')
wavwrite(data, 22000, 'test4.wav');
data(1:100)
plot(data)