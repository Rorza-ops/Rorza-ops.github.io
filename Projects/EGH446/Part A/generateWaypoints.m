function [waypoints, startingPoint] = generateWaypoints(N, startingPoint)
    %Will generate a list of N+1 waypoints with the first being the starting point, input [] for randomly generated starting point.
    if isempty(startingPoint)
        startingPoint = [randi([-500 500]), randi([-500 500]), rand*2*pi];
    end
    if length(startingPoint) == 2
        startingPoint = [startingPoint(1), startingPoint(2), rand*2*pi];
    end
    
    waypoints = [startingPoint(1), startingPoint(2); randi([-500,500],N,2)];

end