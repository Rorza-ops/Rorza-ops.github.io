%%Code to test and compare path optimisation techniques


clear
clc
close all

waypointsNumber = 10;

%Randomly generate starting point
startingPoint = [randi([-500 500], 1, 2), rand*2*pi];

%Will generate a set of waypoints with the starting position as the first
Waypoints = [startingPoint(1:2); randi([-500,500], waypointsNumber,2)];

unoptimisedDistance = 0;
for i = 1:waypointsNumber
    unoptimisedDistance = unoptimisedDistance + norm(Waypoints(i,:) - Waypoints(i+1,:));
end

tic
[BFPath, BFDistance] = bruteForceOptimisation(Waypoints);
BFTime = toc;

tic
[BnBPath, BnBDistance] = branchAndBoundOptimisation(Waypoints);
BnBTime = toc;

tic
[NNPath, NNDistance] = nearestNeighbour(Waypoints);
NNTime = toc;


subplot(2,2,1)
    hold on
    plot(Waypoints(:, 1), Waypoints(:, 2),'b--');

    plot(Waypoints(1, 1), Waypoints(1, 2),'g*');
    text(Waypoints(1, 1), Waypoints(1, 2),'Start')

    plot(Waypoints(2:end, 1), Waypoints(2:end, 2),'r*');
    for i=2:length(Waypoints)
        text(Waypoints(i, 1), Waypoints(i, 2),num2str(i-1))
    end

    axis([-500 500 -500 500])
title('Unoptimised')


subplot(2,2,3)
    hold on
    plot(BFPath(:, 1), BFPath(:, 2),'b--');

    plot(BFPath(1, 1), BFPath(1, 2),'g*');
    text(BFPath(1, 1), BFPath(1, 2),'Start')

    plot(BFPath(2:end, 1), BFPath(2:end, 2),'r*');
    for i=2:length(BFPath)
        text(BFPath(i, 1), BFPath(i, 2),num2str(i-1))
    end

    axis([-500 500 -500 500])
title('Brute Force')


subplot(2,2,2)

    hold on
    plot(NNPath(:, 1), NNPath(:, 2),'b--');

    plot(NNPath(1, 1), NNPath(1, 2),'g*');
    text(NNPath(1, 1), NNPath(1, 2),'Start')

    plot(NNPath(2:end, 1), NNPath(2:end, 2),'r*');
    for i=2:length(NNPath)
        text(NNPath(i, 1), NNPath(i, 2),num2str(i-1))
    end

    axis([-500 500 -500 500])
title('Nearest Neighbour')

subplot(2,2,4)

    hold on
    plot(BnBPath(:, 1), BnBPath(:, 2),'b--');

    plot(BnBPath(1, 1), BnBPath(1, 2),'g*');
    text(BnBPath(1, 1), BnBPath(1, 2),'Start')

    plot(BnBPath(2:end, 1), BnBPath(2:end, 2),'r*');
    for i=2:length(BnBPath)
        text(BnBPath(i, 1), BnBPath(i, 2),num2str(i-1))
    end

    axis([-500 500 -500 500])
title('Branch and Bound')

% Display time results
fprintf('Unoptimised Distance: %.4fm\n\n', unoptimisedDistance);

disp('Brute Force')
fprintf('   Time taken: %.4f seconds\n', BFTime);
fprintf('   Distance Achieved: %.4fm\n', BFDistance);

disp('Branch and Bound')
fprintf('   Time taken: %.4f seconds\n', BnBTime);
fprintf('   Distance Achieved: %.4fm\n', BnBDistance);

disp('Nearest Neighbour')
fprintf('   Time taken: %.4f seconds\n', NNTime);
fprintf('   Distance Achieved: %.4fm\n', NNDistance);

