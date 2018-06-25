%% 8-Channel Signal Reconstruction Using Noise-Band Technique
% 
%  Samantha Mikaiel
%
%-------------------------------------------------------------------------
% Contents:
%
%   Reading of the Signal and Pre-Emphasis
%   Bandpass Channel Info
%   Bandpass Creation for each Channel
%   Application of each channel envelope to White Noise signal
%   Final Output and checks
%-------------------------------------------------------------------------
% 
%
% This code employs a series of steps to seperate a sound sample into 8
% frequency channels, which are then used to reconstruct the original
% signal using Noise-bands filtered at each channel frequency, in order to
% accurately mimic the inputs to cochlear implant.

% First the signal read and pre-emphasized to reduce noise components. 
% Next 8 bandpass filters are applied to the signal in turn, so that the
% signal is separated into 8 frequency bands. Each signal is rectified and
% Lowpass filtered at 400Hz cutoff frequency to extract each channels
% envelope.

% For the reconstruction of the signal, a similar step is taken using a
% white noise signal; it is bandpassed into the same 8 frequency bands, and
% each white noise frequency band is multiplied with the corresponding
% envelopes extracted in the last step. Signal reconstruction is complete
% when every envelope-weighted channel is summed. This sum is also given a
% gain factor to correct the attenuation that resulted from the process.


clear; clc;


%% Reading of the Signal and Pre-Emphasis

[s, fs]=wavread('cochlear_implant_simulation_SoundFile.wav');
s(:,2)=[];
chan_num=input('How many channels does your CI have? ');
l=length(s);
t=[0:1:length(s)-1]/fs;
y=filtfilt([1 -0.95],1,s);
power=abs(y(1:floor(l/2)));
freq=(1:l/2)/(l/2)*10000;
plot(freq,power)

% CHECK 1 --- Test plot of original signal and pre-amped 
figure()
subplot(2,1,1)
plot(t,s);
title('Original Signal');
subplot(2,1,2)
plot(t,y);
title('Preamped Signal');
sound(s, fs)


%% Bandpass channel info

%Center frequencies:
ch1c = [792 460 393 394];
ch2c = [3392 953 639 692];
ch3c = [1971 1037 1064];
ch4c = [4078 1685 1528];
ch5c = [2736 2109];
ch6c = [4444 2834];
ch7c = 3740;
ch8c = 4871;

%3-dB bandwidths:
ch1_bw = [984 321 187 265];
ch2_bw = [4215 664 304 331];
ch3_bw = [1373 493 431];
ch4_bw = [2842 801 516];
ch5_bw = [1301 645];
ch6_bw = [2113 805];
ch7_bw = 1006;
ch8_bw = 1257;

%Picking the right center frequencies and bandwidths
if chan_num == 2
    ch1c=ch1c(1); ch2c=ch2c(1); ch1_bw=ch1_bw(1);  ch2_bw=ch2_bw(1);
end
if chan_num == 4
    ch1c=ch1c(2); ch2c=ch2c(2); ch3c=ch3c(1); ch4c=ch4c(1); ch1_bw=ch1_bw(2);  ch2_bw=ch2_bw(2); ch3_bw=ch3_bw(1);  ch4_bw=ch4_bw(1);
end
if chan_num ==6
    ch1c=ch1c(3); ch2c=ch2c(3); ch3c=ch3c(2); ch4c=ch4c(2); ch5c=ch5c(1); ch6c=ch6c(1); ch1_bw=ch1_bw(3);  ch2_bw=ch2_bw(3); ch3_bw=ch3_bw(2);  ch4_bw=ch4_bw(2); ch5_bw=ch5_bw(1);  ch6_bw=ch6_bw(1);
end
if chan_num==8
    ch1c=ch1c(4); ch2c=ch2c(4); ch3c=ch3c(3); ch4c=ch4c(3); ch5c=ch5c(2); ch6c=ch6c(2); ch1_bw=ch1_bw(4);  ch2_bw=ch2_bw(4); ch3_bw=ch3_bw(3);  ch4_bw=ch4_bw(3); ch5_bw=ch5_bw(2);  ch6_bw=ch6_bw(2);
end

%% Bandpass creation for each channel

nyfs=fs/2;

% Lowpass filtering parameters; the the outputs [b,a] will be used for the
% LPF stage of each channel
lp_order=2;
lp_cut=400;
[b,a]=butter(lp_order,lp_cut/nyfs, 'low');
figure()
freqz(b,a)
title('Frequency Response of LPF')

% Channel 1 -------------------------------------------------------------

Wn1=[(ch1c-(ch1_bw/2)) (ch1c+(ch1_bw/2))]/nyfs;
[b1,a1]=butter(3,Wn1,'bandpass');
y1=filtfilt(b1,a1,y);
figure()
freqz(b1,a1)
title('Frequency Response CH1')
Y1=abs(fft(y1));
fv=[0:1:length(Y1)-1]*fs/length(Y1);


y1rect=sqrt((y1.^2));%rectification

env1=filter(b,a,y1rect);% envelope for channel 1
figure()
plot(t,env1)
title('Envelope CH1')

% CHECK 2 --- Filter output check at every stage of signal conditioning 
figure(2)
subplot(3,1,1)
plot(t,y1);
title('Channel bandpassed signal');
subplot(3,1,2)
plot(t,y1rect);
title('Rectified');
subplot(3,1,3)
plot(t,env1);
title('Lowpassed');



% Channel 2 -------------------------------------------------------------
Wn2=[(ch2c-(ch2_bw/2)) (ch2c+(ch2_bw/2))]/nyfs;
[b2,a2]=butter(3,Wn2,'bandpass');
y2=filtfilt(b2,a2,y);
figure()
freqz(b1,a1)
title('Frequency Response CH2')
y2rect=sqrt((y2.^2));%rectification

env2=filter(b,a,y2rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env2)
title('Envelope CH2')

% Channel 3 -------------------------------------------------------------
if chan_num >2
Wn3=[(ch3c-(ch3_bw/2)) (ch3c+(ch3_bw/2))]/nyfs;
[b3,a3]=butter(3,Wn3,'bandpass');
y3=filtfilt(b3,a3,y);
figure()
freqz(b3,a3)
title('Frequency Response CH3')
y3rect=sqrt((y3.^2));%rectification
env3=filter(b,a,y3rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env3)
title('Envelope CH3')
end


% Channel 4 -------------------------------------------------------------
if chan_num >2
Wn4=[(ch4c-(ch4_bw/2)) (ch4c+(ch4_bw/2))]/nyfs;
[b4,a4]=butter(3,Wn4,'bandpass');
y4=filtfilt(b4,a4,y);
figure()
freqz(b4,a4)
title('Frequency Response CH4')
y4rect=sqrt((y4.^2));%rectification
env4=filter(b,a,y4rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env4)
title('Envelope CH4')
end

% Channel 5 -------------------------------------------------------------
if chan_num > 4
Wn5=[(ch5c-(ch5_bw/2)) (ch5c+(ch5_bw/2))]/nyfs;
[b5,a5]=butter(3,Wn5,'bandpass');
y5=filtfilt(b5,a5,y);
figure()
freqz(b5,a5)
title('Frequency Response CH5')
y5rect=sqrt((y5.^2));%rectification
env5=filter(b,a,y5rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env5)
title('Envelope CH5')
end

% Channel 6 -------------------------------------------------------------
if chan_num > 4
Wn6=[(ch6c-(ch6_bw/2)) (ch6c+(ch6_bw/2))]/nyfs;
[b6,a6]=butter(3,Wn6,'bandpass');
y6=filtfilt(b6,a6,y);
figure()
freqz(b6,a6)
title('Frequency Response CH6')
y6rect=sqrt((y6.^2));%rectification
env6=filter(b,a,y6rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env6)
title('Envelope CH6')
end

% Channel 7 -------------------------------------------------------------
if chan_num >6
Wn7=[(ch7c-(ch7_bw/2)) (ch7c+(ch7_bw/2))]/nyfs;
[b7,a7]=butter(3,Wn7,'bandpass');
y7=filtfilt(b7,a7,y);
figure()
freqz(b7,a7)
title('Frequency Response CH7')
y7rect=sqrt((y7.^2));%rectification
env7=filter(b,a,y7rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env7)
title('Envelope CH7')
end

% Channel 8 -------------------------------------------------------------
if chan_num>6
Wn8=[(ch8c-(ch8_bw/2)) (ch8c+(ch8_bw/2))]/nyfs;
[b8,a8]=butter(3,Wn8,'bandpass');
y8=filtfilt(b8,a8,y);
figure()
freqz(b8,a8)
title('Frequency Response CH8')
y8rect=sqrt((y8.^2));%rectification
env8=filter(b,a,y8rect);% envelope resulting from lowpass (computed above)
figure()
plot(t,env8)
title('Envelope CH8')
end
%% Application of each channel envelope to White Noise signal

% White noise is generated.
% The white noise signal is bandpassed for 8 seperate instances with each
% of the bandpass filters that were used for the original signal

white=2*(-.5+rand(1,length(s)));%makes a -1 to 1 amplitude white noise signal

%CH1:
white_f1=filtfilt(b1,a1,white);
% WHITE= fft(white); % some frequency checks...
% WHITE_F=fft(white_f1);
% 
% fv=[0:1:length(WHITE)-1]*fs/length(WHITE);
CH1=env1'.*white_f1;
figure()
plot(t,CH1)
title('Channel 1 Waveform')

%CH2:
white_f2=filtfilt(b2,a2,white);
CH2=env2'.*white_f2;% the envelope is transposed so that the matrix dimensions agree...
figure()
plot(t,CH2)
title('Channel 2 Waveform')

%CH3:
if chan_num >2
white_f3=filtfilt(b3,a3,white);
CH3=env3'.*white_f3;
figure()
plot(t,CH3)
title('Channel 3 Waveform')
end

%CH4:
if chan_num >2
white_f4=filtfilt(b4,a4,white);
CH4=env4'.*white_f4;
figure()
plot(t,CH4)
title('Channel 4 Waveform')
end

%CH5:
if chan_num >4
white_f5=filtfilt(b5,a5,white);
CH5=env5'.*white_f5;
figure()
plot(t,CH5)
title('Channel 5 Waveform')
end

%CH6:
if chan_num >4
white_f6=filtfilt(b6,a6,white);
CH6=env6'.*white_f6;
figure()
plot(t,CH6)
title('Channel 6 Waveform')
end

%CH7:
if chan_num >6
white_f7=filtfilt(b7,a7,white);
CH7=env7'.*white_f7;
figure()
plot(t,CH7)
title('Channel 7 Waveform')
end

%CH8:
if chan_num >6
white_f8=filtfilt(b8,a8,white);
CH8=env8'.*white_f8;
figure()
plot(t,CH8)
title('Channel 8 Waveform')
end

%% Final Output and checks:

if chan_num==2
SUM = (CH1+CH2);
end
if chan_num==4
SUM = (CH1+CH2+CH3+CH4);
end
if chan_num==6
SUM = (CH1+CH2+CH3+CH4+CH5+CH6);
end
if chan_num==8
SUM = (CH1+CH2+CH3+CH4+CH5+CH6+CH7+CH8);
end

%Since the reconstructed signal has been very much attenutated, it is
%necessary to find a proper gain factor to bring it back to the same
%relative amplitudes as the original signal. Otherwise the reconstructed
%signal will be too low to hear...
gain=(max(s)/max(SUM));
SUM=SUM*gain;

sound(SUM,fs)
