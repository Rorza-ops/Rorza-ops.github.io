%% Setup
[audio, fs] = audioread('audio3.wav');
Audio = 0; % <-- TODO

% Listen to the original audio
% sound(audio, fs);

% View original audio in the frequency domain
samples = length(audio);
f = 0; % <-- TODO

figure;
plot(f, 0); % <-- TODO
title('Magnitude spectrum of original audio');
xlabel('Frequency [Hz]');
ylabel('Magnitude');

%% Question 1 - resampling
fsResampled = 0; % <-- TODO

audioResampled = 0; % <-- TODO
AudioResampled = 0; % <-- TODO

% View resampled audio in the frequency domain
samples = length(audioResampled);
f = 0; % <-- TODO

figure;
plot(f, abs(AudioResampled));
title(''); % <-- TODO
xlabel('Frequency [Hz]');
ylabel('Magnitude');

% Listen to the resampled audio
% sound(audioResampled, fsResampled);

%% Question 2 - normalisation
audioNormalised = 0; % <-- TODO

% View normalised audio in the time domain
samples = length(audioNormalised);
t = linspace(0, samples / fs, samples + 1);
t(end) = [];

figure; hold on;
plot(t, audioNormalised);
plot(t, audio);
legend('Normalised audio', 'Audio');
title('Audio vs normalised audio');
xlabel('Time [s]');
ylabel('Amplitude');

%% Question 2 - quantiser investigation
% Define quantiser parameters
xmax = 0; xmin = 0; % <-- TODO
L = 0; % <-- TODO
delta = 0; % <-- TODO

% Create input-output relationships
input = 0; % <-- TODO
outputMT = 0; % <-- TODO
outputMR = 0; % <-- TODO

% Fix up extreme values
outputMT = 0; % <-- TODO
outputMR = 0; % <-- TODO

% Plot input-output and error curves
figure;
subplot(2, 1, 1); hold on; grid on;
plot(input, input);
plot(input, outputMT);
plot(input, input - outputMT);
xlabel('Input voltage [V]');
ylabel('Output voltage [V]');
title('Mid-tread quantiser');
legend('Input', 'Output', 'Error', 'Location', 'best');
subplot(2, 1, 2); hold on; grid on;
plot(input, input);
plot(input, outputMR);
plot(input, input - outputMR);
xlabel('Input voltage [V]');
ylabel('Output voltage [V]');
title('Mid-riser quantiser');
legend('Input', 'Output', 'Error', 'Location', 'best');

%% Question 2 - audio quantisation
% Create quantised outputs
audioMT = 0; % <-- TODO
audioMR = 0; % <-- TODO

% Fix up extreme values
audioMT = 0; % <-- TODO
audioMR = 0; % <-- TODO

% Plot 1000 samples of quantised audio
figure;
subplot(2, 1, 1); hold on; grid on;
plot(t(1000:2000), audioNormalised(1000:2000));
plot(t(1000:2000), audioMT(1000:2000));
xlabel('Time [s]');
ylabel('Amplitude');
title('Audio quantised with mid-tread quantiser');
subplot(2, 1, 2); hold on; grid on;
plot(t(1000:2000), audioNormalised(1000:2000));
plot(t(1000:2000), audioMR(1000:2000));
xlabel('Time [s]');
ylabel('Amplitude');
title('Audio quantised with mid-riser quantiser');

% Listen to mid-tread quantised audio
% sound(audioMT, fs);
% Listen to mid-riser quantised audio
% sound(audioMR, fs);

%% Demonstration - pulse/rect sampling
T = 5; samples = T*fs;
t = linspace(0, T, samples + 1); t(end) = [];
f = linspace(-fs/2, fs/2, samples + 1); f(end) = [];

% Generate a signal which is band-limited and flat-topped in the frequency
% domain.
signal = ifft(fft(sqrt(1e4/T) * randn(1,samples)) .* fftshift(abs(f)<1e3));
Signal = fftshift(fft(signal)) / fs;

% Resample the signal at the desired sampling rate `fsResampled` using a
% pulse with width `w`.
% TASK: Adjust fsResampled and w and observe the effects on the resampled
% signal and its magnitude spectrum.
fsResampled = 3000; w = 2;
pulseTrain = zeros(1, samples);
pulseTrain(mod(0:samples-1, fs/fsResampled) < w) = 1;

signalResampled = signal .* pulseTrain;
SignalResampled = fftshift(fft(signalResampled)) / fs;

% Plot first 50 samples of the pulse train and signal/resampled signal,
% along with the magnitude spectra of both signals
figure;
subplot(2, 2, 1);
stem(t(1:50), pulseTrain(1:50));
ylim([-1, 2]);
xlabel('Time [s]');
ylabel('Amplitude');
title('Sampling pulse/rect train');

subplot(2, 2, 3); hold on;
plot(t(1:50), signal(1:50));
stem(t(1:50), signalResampled(1:50));
m = max(abs(get(gca, 'YLim')));
ylim([-m, m]);
xlabel('Time [s]');
ylabel('Amplitude');
title('Signal before/after resampling');
legend('Signal', 'Signal, resampled', 'Location', 'best');

subplot(2, 2, 2);
plot(f, abs(Signal));
xlabel('Frequency [Hz]');
ylabel('Magnitude');
title('Signal magnitude spectrum, before resampling');

subplot(2, 2, 4);
plot(f, abs(SignalResampled));
xlabel('Frequency [Hz]');
ylabel('Magnitude');
title('Signal magnitude spectrum, after resampling');