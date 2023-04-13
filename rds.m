clear; 
close all; 
load("Radio_signal.mat")

x = raw_radio_94_2MHz;
Fs = 960000;
Fc = 200000;
Fcd = 57000;
t = 0:(1/Fs):10;

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

yds = downsample(yn, 4);
f2 = fir1(101, [0.15 0.18]);
xf = filter(f2, 1, yds);

xdl = 4 * xf.^3 - 3*xf;

t2 = 0:(1/240000):10;


xdl = xdl-mean(xdl);
xdl = xdl./rms(xdl);

f3 = fir1(101, [0.455 0.495]);
xdlf1 = filter(f3, 1, xdl);
xdlf = filter(f3, 1, xdlf1);

xdlf = xdlf-mean(xdlf);
xdlf = xdlf./rms(xdlf);
ysn = circshift(xdlf, 1);

ysf = yds .* ysn;
bitrate = 1187.5;
f4 = fir1(101, 0.04);
yysf = filter(f4, 1, ysf);
ci = cos(2*pi*4750*t2);

[~, b] = findpeaks(ci);
xdk = yysf(b);
xdk = xdk(2:end);

xdk(3:4:end) = -xdk(3:4:end);
xdk(4:4:end) = -xdk(4:4:end);

k = 1;
for i=6:4:length(xdk)
    xds(k) = sum(xdk((i-3):i));
    k = k+1;
end

for i=1:1:length(xds)
    if xds(i) >= 0
        xds(i) = 1;
    else
        xds(i) = 0;
    end
end

dec = comm.DifferentialDecoder();

xbit = dec(xds');

a = 1;
b = 26;
s = 0;

for i = 0 : (length(xbit)-104)
    vec = xbit(a:b);
    message = vec(1:16);
    cw = vec(17:26);
    shi = [0;0;0;0;0;0;0;0;0;0];
    mx = cat(1,message,shi);
    mv = flip(mx');
    gx = [1 0 1 1 0 1 1 1 0 0 1];
    gx = flip(gx);
    [~,r] = gfdeconv(mv ,gx);
    r = flip(r);
    if length(r) < 10
        switch length(r)
            case 9
                r = cat(2, 0, r);
            case 8
                r = cat(2,[0 0], r);
            case 7
                r = cat(2,[0 0 0], r);
            case 6
                r = cat(2,[0 0 0 0], r);
            case 5
                r = cat(2,[0 0 0 0 0], r);
            case 4
                r = cat(2,[0 0 0 0 0 0], r);
            case 3
                r = cat(2,[0 0 0 0 0 0 0], r);
            case 2
                r = cat(2,[0 0 0 0 0 0 0 0], r);
            case 1
                r = cat(2,[0 0 0 0 0 0 0 0 0], r);
            otherwise
                r = [0 0 0 0 0 0 0 0 0 0];
        end
    end
    check = xor(cw', [0 0 1 1 1 1 1 1 0 0]);
    if check == r
        s = s + 1;
        out(s) = a;
    end
    a = a+1;
    b = b+1;
end

for i = 1 : (length(out))
    first_bit = out(i);
    last_bit = out(i)+103;
    disp(i)
    %block a
    
end





