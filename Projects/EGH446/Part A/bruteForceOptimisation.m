function [Waypoints, bestDistance] = bruteForceOptimisation(waypoints)
    
    bestDistance = inf;
    P = perms(2:length(waypoints));
    Permutations = [ones(size(P, 1), 1), P];
    %disp(length(Permutations))

    for i = 1:size(Permutations, 1)
        distance = 0;
        for j = 2:size(waypoints,1)
            distance = distance + sqrt((waypoints(Permutations(i,j),1) - waypoints(Permutations(i,j-1),1))^2 + (waypoints(Permutations(i,j),2) - waypoints(Permutations(i,j-1),2))^2);
        end

        if distance < bestDistance
            bestPath = Permutations(i,:);
            bestDistance = distance;
        end
    
    end

    Waypoints = waypoints(bestPath,:);

end