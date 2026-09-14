%% EGB242 Assignment 2, Section 2 %%
% This file is a template for your MATLAB solution to Section 2.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;

% Begin writing your MATLAB solution below this line.

%% 2.1
Km = 1; alpha = 0.5;
num = [Km]; den = [1 0.5 0];
H = tf(num, den); % <-- DONE
% ltiview(H);
% stepinfo(H);
T = 20; samples = 10e4;
fs = samples / T; ts = 1/fs;
t = linspace(0,T, samples+1); t(end)=[];
STEPINPUT = ones(size(t));
STEPRESPONSE = (2*t)-4+(4*exp(-0.5*t)); % <-- Keep this
figure; hold on; grid on;
plot(t, STEPRESPONSE);
plot(t, STEPINPUT);
title('Step Response vs Step Input');
xlabel('Time [s]');
ylabel('Amplitude')
legend('Step Response [rad/s]', 'Step Input [V]');

%% 2.2
STEPRESPONSEV2 = H/(1+H);
% ltiview(STEPRESPONSEV2);
% stepinfo(STEPRESPONSEV2)
num2 = [1]; % 1 constant
den2 = [1 0.5 1]; % 1 s^2, 0.5 s, 1 constant
H2 = tf(num2, den2); % Create transfer Function from this equation
% ltiview(H2);
% stepinfo(H2)
stepResponse = lsim(H2, STEPINPUT, t); % Simulate 
figure; hold on; grid on;
plot(t, stepResponse)
title('1st Revision Step Response');
xlabel('Time [s]');
ylabel('Angle [rads/s]')

%% 2.3
wn = 1;
zeta = 0.25;
Ts = 4/zeta*wn;
Tp = pi / (wn*sqrt(1-zeta^2));
OSpercent = exp(-(zeta*pi / sqrt(1-(zeta^2)))) * 100;

%% 2.4 Varying Backwards
% Create and Simulate Each Case %
% Forward = 1, Back = 0.1
numb01 = [1]; denb01 = [1 0.5 0.1]; 
Hb01 = tf(numb01, denb01);
% ltiview(Hb01); stepinfo(Hb01);
stepResponseb01 = lsim(Hb01, STEPINPUT, t);

% Forward = 1, Back = 0.2
numb02 = [1]; denb02 = [1 0.5 0.2]; 
Hb02 = tf(numb02, denb02);
% ltiview(Hb02); stepinfo(Hb02);
stepResponseb02 = lsim(Hb02, STEPINPUT, t);

% Forward = 1, Back = 0.2
numb05 = [1]; denb05 = [1 0.5 0.5]; 
Hb05 = tf(numb05, denb05);
% ltiview(Hb05); stepinfo(Hb05);
stepResponseb05 = lsim(Hb05, STEPINPUT, t);

% Forward = 1, Back = 1
numb1 = [1]; denb1 = [1 0.5 1]; 
Hb1 = tf(numb1, denb1);
% ltiview(Hb1); stepinfo(Hb1);
stepResponseb1 = lsim(Hb1, STEPINPUT, t);

% Forward = 1, Back = 2
numb2 = [1]; denb2 = [1 0.5 2]; 
Hb2 = tf(numb2, denb2);
% ltiview(Hb2); stepinfo(Hb2);
stepResponseb2 = lsim(Hb2, STEPINPUT, t);

% Plot %
figure; hold on; grid on;
plot(t, stepResponseb01);
plot(t, stepResponseb02);
plot(t, stepResponseb05);
plot(t, stepResponseb1);
plot(t, stepResponseb2);
title('Step Response of Varying Backward (Kfwd = 1, Kfb=[0.1, 0.2, 0.5, 1, 2])');
xlabel('Time [s]'); ylabel('Angle [rad/s]');
legend('Kfb = 0.1', 'Kfb = 0.2', 'Kfb = 0.5','Kfb = 1','Kfb = 2');

%% 2.4 Varying Forward
% Create and Simulate Each Case %
% Forward = 0.1, Back = 1
numf01 = [0.1]; denf01 = [1 0.5 0.1]; 
Hf01 = tf(numf01, denf01);
% ltiview(Hf01); stepinfo(Hf01);
stepResponsef01 = lsim(Hf01, STEPINPUT, t);

% Forward = 0.2, Back = 1
numf02 = [0.2]; denf02 = [1 0.5 0.2]; 
Hf02 = tf(numf02, denf02);
% ltiview(Hf02); stepinfo(Hf02);
stepResponsef02 = lsim(Hf02, STEPINPUT, t);

% Forward = 0.5, Back = 1
numf05 = [0.5]; denf05 = [1 0.5 0.5]; 
Hf05 = tf(numf05, denf05);
% ltiview(Hf05); stepinfo(Hf05);
stepResponsef05 = lsim(Hf05, STEPINPUT, t);

% Forward = 1, Back = 1
numf1 = [1]; denf1 = [1 0.5 1]; 
Hf1 = tf(numf1, denf1);
% ltiview(Hf1); stepinfo(Hf1);
stepResponsef1 = lsim(Hf1, STEPINPUT, t);

% Forward = 2, Back = 1
numf2 = [2]; denf2 = [1 0.5 2]; 
Hf2 = tf(numf2, denf2);
% ltiview(Hf2); stepinfo(Hf2);
stepResponsef2 = lsim(Hf2, STEPINPUT, t);

% Plot %
figure; hold on; grid on;
plot(t, stepResponsef01);
plot(t, stepResponsef02);
plot(t, stepResponsef05);
plot(t, stepResponsef1);
plot(t, stepResponsef2);
title('Step Response of Varying Forward (Kfwd = [0.1, 0.2, 0.5, 1, 2], Kfb=1)');
xlabel('Time [s]'); ylabel('Angle [rad/s]');
legend('Kfwd = 0.1', 'Kfwd = 0.2', 'Kfwd = 0.5','Kfwd = 1','Kfwd = 2');


%% 2.5
Kfb = 1/(2*pi);
Kfwd = (((pi/13)^2)+(1/16))*(2*pi); 
finalnum = [Kfwd]; finalden = [1 0.5 (Kfwd*Kfb)]; cameraTF = tf(finalnum, finalden);
% ltiview(cameraTF); stepinfo(cameraTF)
finalstepResponse = lsim(cameraTF, STEPINPUT, t);
figure; hold on; grid on;
plot(t, finalstepResponse);
title('Step Response of the final Revision of the Control System');
xlabel('Time [s]'); ylabel('Angle [rad/s]');
figure; hold on; grid on;
plot(t, finalstepResponse);
plot(t, stepResponse);
plot(t, STEPRESPONSE);
title('Step Response of Control System from the initial version to the final version');
xlabel('Time [s]'); ylabel('Angle [rad/s]');
legend('Final Revision', '1st Revision', 'intial DC Motor');

%% 2.6
StartAngle = 30;
EndAngle = 210;
startVoltage = (StartAngle*(pi/180))/(2*pi);
endVoltage = (EndAngle*(pi/180))/(2*pi);
[startIm, finalIm] = cameraPan(startVoltage, endVoltage, cameraTF);

%% Near perfect / Near Critically Damped but still underdamped as there is an over shoot
% finalnum = [0.3085*(2*pi)]; finalden = [1 1 0.3085]; cameraTF = tf(finalnum, finalden);
% criticalstepResponse = lsim(cameraTF, STEPINPUT, t);
% figure; hold on; grid on;
% plot(t, criticalstepResponse);
% title('Step Response of near critical damped Control System');
% xlabel('Time [s]'); ylabel('Angle [rad/s]');
% figure; hold on; grid on;
% plot(t, criticalstepResponse);
% plot(t, finalstepResponse);
% title('Near Critical Damped VS Final Version');
% xlabel('Time [s]'); ylabel('Angle [rad/s]');
% legend('Critically Damped', 'Final Revision');
% startVoltage = (30*(pi/180))/(2*pi);
% endVoltage = (210*(pi/180))/(2*pi);
% [startIm, finalIm] = cameraPan(startVoltage, endVoltage, cameraTF);
