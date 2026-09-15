%% close previously open model
close_system('sl_quadrotorDynamics',0);
 
homedir = pwd; 

%% add toolboxes to path
addpath(genpath(strcat(homedir,[filesep,'toolboxes'])));
cd('toolboxes/MRTB');
startMobileRoboticsSimulationToolbox;

cd(homedir);

%% open current model
open_system('sl_quadrotorDynamics'); % quadrotor model


cd(homedir);




