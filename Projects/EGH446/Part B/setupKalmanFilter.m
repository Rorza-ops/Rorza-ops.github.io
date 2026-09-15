function [A,C,Q,R] = setupKalmanFilter(dt, sigmaQ, sigmaR)
    %Creates matrices for a kalman filter using input parameters.    
    %SigmaQ should be a 1x3 with the sigma^2 vales for each respective state
    %SigmaR can be either a singular value which will apply to all states
    %or a 1x3 to specify different R values for each state
    
    A = [1 0 0 dt 0 0;
         0 1 0 0 dt 0;
         0 0 1 0 0 dt;
         0 0 0 1 0 0;
         0 0 0 0 1 0;
         0 0 0 0 0 1];

    C = [1 0 0 0 0 0;
         0 1 0 0 0 0;
         0 0 1 0 0 0];

    Q = diag([sigmaQ, sigmaQ]);

    if length(sigmaR) > 1
        R = diag(sigmaR);
    else
        R = diag([sigmaR, sigmaR, sigmaR]);
    end
end