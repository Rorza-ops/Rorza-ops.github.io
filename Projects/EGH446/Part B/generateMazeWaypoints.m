function [waypoints, startingPoint] = generateMazeWaypoints(N, startingPoint, map, obstacles, inflateAmount)
    %Will generate a list of N+1 waypoints with the first being the starting point, input [] for randomly generated starting point.
    
    obstacleMap = binaryOccupancyMap(52,41,10);
    setOccupancy(obstacleMap, obstacles(:,1:2), 1);

    inflate(obstacleMap, 0.1+inflateAmount)

    mapCopy = copy(map);
    inflate(mapCopy, inflateAmount)

    combinedGrid = getOccupancy(mapCopy) | getOccupancy(obstacleMap);

    combinedMap = binaryOccupancyMap(combinedGrid, 10);
    

    waypoints = [];

    if isempty(startingPoint)
        while isempty(startingPoint)
            point = [randi([0,52]) randi([0,41])];
            if ~checkOccupancy(combinedMap,point)
                startingPoint = point;
            end
        end
    end

    while size(waypoints,1) < N
        xy = [randi([0,52]) randi([0,41])];
        if ~checkOccupancy(combinedMap,xy)
            waypoints = [waypoints; xy];
        end
    end
    %{
    test = binaryOccupancyMap(combinedGrid, 10);
    inflate(test, 0.15)
    setOccupancy(test, waypoints, 1);
    inflate(test, 0.1)
    figure
    show(test)
    %}
end