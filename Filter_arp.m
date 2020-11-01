function filtered_data=Filter_arp(ytofilt,HIGH_PASS,LOW_PASS,Fs,BPORDER)
y = ytofilt;%Data to filter as a vector
% HIGH_PASS =10; %filter frequencies in Hz
% LOW_PASS = 0.05;
%no of data points > 3* BPORDER
if nargin<5; BPORDER = round(length(ytofilt)/3) -2; end
if nargin < 4; Fs = 1000;end%sample frequency
Nf = Fs/2;
BPFREQ = [LOW_PASS HIGH_PASS]; 
low = BPFREQ(1)/Nf;
high = BPFREQ(2)/Nf;
stop1 = low - .1*low;
stop2 = high + .1*high;
 
b = fir1(BPORDER,[low high]);
%freqz(b,1,512)
f = [0 stop1 low high stop2 1]; a = [0 0 1 1 0 0];
filtered_data = filtfilt(b, 1, y);  