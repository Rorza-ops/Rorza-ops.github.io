%% EGB242 Assignment 1 %%
% This file is a template for your MATLAB solution.
%
% Before starting to write code, record your test audio with the record
% function as described in the assignment task.

%% Load recorded test audio into workspace
clear all; close all;
load DataA1;

% Begin writing your MATLAB solution below this line.




%% Section 1 %%
%% 1.1 %%
%n(t) = 
% 5e^(3(t-1)), 0<=t<1
% -2t+7, 1<=t<2

%% 1.2 %%
% sound(audio, fs);

%% 1.3 %%
t0 = 0; % starting time
T = 2; % Period
f0 = 1/T;% Frequency
samples = fs * T; % Samples
t = linspace(t0, T, samples + 1); t(end) = []; % create 't' vector
repeat = 5;
tt = linspace(0, repeat * T, repeat * samples + 1); tt(end) = []; % create 'tt' vector
figure; hold on; grid on; %plot audio signal
plot(tt, audio);
title('Noise Signal');
xlabel('Time [s]');
ylabel('Amplitude');


%% 1.4 %%
% Done

%% 1.5 %%
N = 5; % Harmonics
ns = -N:N; % Harmonic Range
Cn = zeros(1, 2*N+1); %Create 'Cn' vector
for n = ns % Compute  Numbers for different values of 'N' 
    Cn(ns == n) = (1/T) * (( ((5*exp(-1i*pi*n))-(5*exp(-3)))/(3-(1i*pi*n)) ) + ( ((((3i*pi*n)-2)*(exp(-2i*pi*n)))-(((5i*pi*n)-2)*(exp(-1i*pi*n)))) / ((pi^2) * (n^2)) )); % Calculated value of 'Cn'
end
c0 = (1/T) * ((((5*exp(3))-5)/(3*exp(3)))+4); % Calculated value of 'c0'
Cn(ns == 0) = c0; % Put in 'c0', as the 'for' loop has created an error during the 6th loop

%% 1.6 %%
nApprox = zeros(size(t)); % Created 'nApprox' vector
for n = ns % Summation of Cn Values
    nApprox = nApprox + Cn(ns == n) * exp(2i*pi*n*f0*t);
end
figure; hold on; grid on;
plot(t, nApprox, 'b');
title('Fourier Series Approximation');
xlabel('Time [s]');
ylabel('Amplitude');
s1 = repmat(nApprox, 1, repeat);

%% 1.7 %%
audioClean = audio - real(s1);
figure;
subplot(2,1,1); hold on; grid on;
plot(tt, audio, 'b'); hold on;
plot(tt, s1, 'r');
title('Noisy Audio vs Fourier Series Approximation');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Noisy Output', 'Fourier Series Aprroximation')
subplot(2,1,2); hold on; grid on;
plot(tt, audioClean, 'g');
title('Clean Audio');
xlabel('Time [s]');
ylabel('Amplitude');
% sound(audioClean, fs);

%% 1.8 %%
% Less Harmonics means the approximation is less accurate to the Noise
% Signal, n(t). At One Harmonic there is still noise but the dialogue is
% auditable.
% More Harmonics means the approximation more accurate, nearly perfect to
% the Noise Signal, n(t). When it is 20 or more harmonics is when it starts
% to become more accurate to n(t). (Appendix)

%% Section 2 %%
%% 2.1 %%
samplesf = length(audioClean); % create frequency sample
f = linspace(-fs/2, fs/2, samplesf + 1); f(end) = []; % create 'f' vector
figure; hold on; grid on; % plot against the f
plot(f,abs(audioClean))
title('Magnitude Spectrum of Clean Audio');
xlabel('Frequency [Hz]');
ylabel('Magnitude');

%% 2.2 %%
channelQuiet = channel(10773398, zeros(size(tt))); % Create channelQuiet using channel function
channelQuietShift = fftshift(fft(channelQuiet)) / fs; % Create frequency version of channelQuiet called channelQuietShift 


%% 2.3 %%
figure;
subplot(3,1,1) % Plot channel Quiet in time
plot(tt,channelQuiet); hold on; grid on; 
title('channelQuiet');
xlabel('Time [s]');
ylabel('Amplitude');
subplot(3,1,2); hold on; grid on; 
plot(f, abs(channelQuietShift)) % Plot Magnitude Spectrum of channelQuietShift in frequency
title('Magnitude Spectrum of channelQuietShift');
xlabel('Frequency [Hz]');
ylabel('Magnitude');
subplot(3,1,3); hold on; grid on; 
plot(f, angle(channelQuietShift)) % Plot Phase Spectrum of channelQuietShift in frequency
title('Phase Spectrum of channelQuietShift');
xlabel('Frequency [Hz]');
ylabel('Phase [rad]');

%% 2.4 %%
fc = 60000; % Chosen as it is where there is space with no noise present
TF = samplesf / fs; % Create 'TF' Period
tf = linspace(0, TF, samplesf + 1); tf(end) = []; % Create 'tf' Vector
tone = audioClean .* cos(2*pi*fc*tf); % Modulate


%% 2.5 %%
output = channel(10773398, tone); % Put new 'tone' through channel function
foutput = fftshift(fft(output)) / fs; % Create frequency version of 'output' called 'foutput'

figure;
subplot(2, 1, 1); hold on; grid on;
plot(f, abs(foutput)); % Plot Magnitude Spectrum of 'foutput'
title('Magnitude spectrum of foutput');
xlabel('Frequency [Hz]');
ylabel('Magnitude');
subplot(2, 1, 2); hold on; grid on;
plot(f, angle(foutput)); % Plot Phase spectrum of 'foutput'
title('Phase spectrum of foutput');
xlabel('Frequency [Hz]');
ylabel('Phase [rad]');

%% 2.6 %%
Cutf = 0.3 * (10^3); % This cut-off frequency was chosen to keep the dialogue and rid of the noise
Dmod = output .* cos(2*pi*fc*tf); % Demodulate
audioReceived = lowpass(Dmod,Cutf,fs); % Put through a lowpass filter
AudioReceived = fftshift(fft(audioReceived)) / fs ; % Create frequency version of 'audioReceived' called 'AudioReceived'
figure;
plot(f, abs(AudioReceived)); hold on; grid on; % Plot Magnitude Spectrum of 'AudioReceived'
title('Magnitude spectrum of AudioReceived (Demodulated output)');
xlabel('Frequency [Hz]');
ylabel('Magnitude');
% sound(audioReceived,fs)

%% 2.7 %%
Other = 19168.7; % The first spike near 0.2 * 10^5
demodulateOther1 = channelQuiet .* cos(2*pi*tt.*Other); % modulate
filtered1 = lowpass(demodulateOther1,Cutf,fs); % filter through lowpass
% sound(filtered1, fs)
% Lemonade song - https://www.youtube.com/watch?v=LdLvp630plc
Other2 = 38370; % The second spike near 0.4 * 10^5
demodulateOther2 = channelQuiet .* cos(2*pi*tt.*Other2); % modulate
filtered2 = lowpass(demodulateOther2,Cutf,fs); % filter through lowpass
% sound(filtered2, fs)
% Halo Theme
Other3 = 76702; % The third spike near 0.8 * 10^5
demodulateOther3 = channelQuiet .* cos(2*pi*tt.*Other3); % modulate
filtered3 = lowpass(demodulateOther3,Cutf,fs); % filter through lowpass
% sound(filtered3, fs)
% Through The Fire And Flames By DragonForce

%% Section 3 %%
%% 3.1 %%
fs2 = 44100; % (1.7 * (10^4)) * 2 and round up
AudioNormalised = audioReceived / max(abs(audioReceived)); % Normalise Audio
audioResampled = resample(audioReceived, fs2, fs); % Resample audioReceived 
AudioResampled = fftshift(fft(audioResampled)) / fs2; % Create frequency version of audioResampled called 'AudioResampled'
qsamples = length(AudioNormalised); % quantise samples
q = linspace(0, qsamples / fs, samples + 1); t(end) = []; % Create qunatise vector

figure; hold on; grid on; % Plot Received against Normalised
plot(tt,AudioNormalised);
plot(tt,audioReceived)
title('AudioNormalised vs audioReceived');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Normalised', 'Received')


%% 3.2 %%
% sound(audioResampled, fs2)

%% 3.3 %%
xmax = 1; xmin = -1; % Create xmin and xmax
L = 500; delta = (xmax - xmin) / L; % 'L' is Levels
input = linspace(xmin, xmax, 1000); % create input vector
audioQuantisedMT = delta * floor((AudioNormalised/delta) + (1/2)); % Create Mid-Tread
audioQuantisedMT(audioQuantisedMT >= xmax) = xmin + delta*(L-1);
audioQuantisedMR = delta * (floor(AudioNormalised/delta) + (1/2)); % Create Mid-Riser
audioQuantisedMR(audioQuantisedMR >= xmax) = xmin + delta*(L-(1/2));

figure;
subplot(2,1,1); hold on; grid on;
plot(q(15000:30000), AudioNormalised(15000:30000));
plot(q(15000:30000), audioQuantisedMT(15000:30000));
title('Normalised vs Quantised Mid-Tread');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Normalised', 'Mid-Tread Quantised')
subplot(2,1,2); hold on; grid on;
plot(q(15000:30000), AudioNormalised(15000:30000));
plot(q(15000:30000), audioQuantisedMR(15000:30000));
title('Normalised vs Quantised Mid-Riser');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Normalised', 'Mid-Riser Quantised')
% sound(audioQuantisedMT, fs)
% sound(audioQuantisedMR, fs)
%% 3.4 %%
% L = 2
L2 = 2; delta2 = (xmax - xmin) / L2;
audioMT2 = delta2 * floor((AudioNormalised/delta2) + (1/2));
audioMT2(audioMT2 >= xmax) = xmin + delta2*(L2-1);
audioMR2 = delta2 * (floor(AudioNormalised/delta2) + (1/2));
audioMR2(audioMR2 >= xmax) = xmin + delta2*(L2-(1/2));
% L = 4
L4 = 4; delta4 = (xmax - xmin) / L4;
audioMT4 = delta4 * floor((AudioNormalised/delta4) + (1/2));
audioMT4(audioMT4 >= xmax) = xmin + delta4*(L4-1);
audioMR4 = delta4 * (floor(AudioNormalised/delta4) + (1/2));
audioMR4(audioMR4 >= xmax) = xmin + delta4*(L4-(1/2));
% L = 8
L8 = 8; delta8 = (xmax - xmin) / L8;
audioMT8 = delta8 * floor((AudioNormalised/delta8) + (1/2));
audioMT8(audioMT8 >= xmax) = xmin + delta8*(L8-1);
audioMR8 = delta8 * (floor(AudioNormalised/delta8) + (1/2));
audioMR8(audioMR8 >= xmax) = xmin + delta8*(L8-(1/2));
% L = 32
L32 = 32; delta32 = (xmax - xmin) / L32;
audioMT32 = delta32 * floor((AudioNormalised/delta32) + (1/2));
audioMT32(audioMT32 >= xmax) = xmin + delta32*(L32-1);
audioMR32 = delta32 * (floor(AudioNormalised/delta32) + (1/2));
audioMR32(audioMR32 >= xmax) = xmin + delta32*(L32-(1/2));

figure;hold on;grid on; % Plot Mid-Riser Tests
plot(q(15000:40000), AudioNormalised(15000:40000), 'r');
plot(q(15000:40000), audioMR2(15000:40000), 'm');
plot(q(15000:40000), audioMR4(15000:40000), 'y');
plot(q(15000:40000), audioMR8(15000:40000), 'g');
plot(q(15000:40000), audioQuantisedMR(15000:40000), 'c');
plot(q(15000:40000), audioMR32(15000:40000), 'b');
title('Normalised vs Quantised Mid-Riser [L = 2,4,8,16,32]');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Normalised', 'Mid-Riser Quantised [L=2]', 'Mid-Riser Quantised [L=4]', 'Mid-Riser Quantised [L=8]', 'Mid-Riser Quantised [L=16]', 'Mid-Riser Quantised [L=32]')
figure;hold on;grid on; % Plot Mid-Tread Tests
plot(q(15000:40000), AudioNormalised(15000:40000), 'r');
plot(q(15000:40000), audioMT2(15000:40000), 'm');
plot(q(15000:40000), audioMT4(15000:40000), 'y');
plot(q(15000:40000), audioMT8(15000:40000), 'g');
plot(q(15000:40000), audioQuantisedMT(15000:40000), 'c');
plot(q(15000:40000), audioMT32(15000:40000), 'b');
title('Normalised vs Quantised Mid-Tread [L = 2,4,8,16,32]');
xlabel('Time [s]');
ylabel('Amplitude');
legend('Normalised', 'Mid-Tread Quantised [L=2]', 'Mid-Tread Quantised [L=4]', 'Mid-Tread Quantised [L=8]', 'Mid-Tread Quantised [L=16]', 'Mid-Tread Quantised [L=32]')