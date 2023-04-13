clear; 
close all; 
load("Radio_signal.mat")

x = raw_radio_94_2MHz;
Fs = 960000;
Fc = 200000;
Fcd = 57000;
t = 0:(1/Fs):10;
plot(20*log10(abs(fft(x, Fs))))
x = x(1:length(t));
cs = cos(2*pi*Fc*t);
xc = x'.*cs;
f1 = fir1(101, 0.1);
xl = filter(f1, 1, xc);
si = -sin(2*pi*Fc*t);
xs = x'.*si;
xls = filter(f1, 1, xs);
xlsj = xls * 1j;
xn = xlsj + xl;
xz = circshift(xn, -1);
xzs = conj(xz);
y = xn.*xzs;
yn = angle(y);
plot(20*log10(abs(fft(yn, Fs))))
ys = downsample(yn, 5);
%sound(ys, 192000)
plot(yn)
