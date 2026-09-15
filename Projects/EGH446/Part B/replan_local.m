function [combinedGrid, newPath] = replan_local(inflated_logical, path, pose, obstacles, inflateAmount, smoothing)
    %InflateAmount should match inflate amount in workspace
    %Can adjust either for fine tuning though

    inflatedMap = binaryOccupancyMap(inflated_logical, 10);

    %Generating blank map to place obstacles
    obstacleMap = binaryOccupancyMap(52,41,10);

    %Placing newely detected obstacles
    setOccupancy(obstacleMap, obstacles, 1);
    if inflateAmount < 0.7
        inflate(obstacleMap, inflateAmount);
    else
        %Inflating obstacles by obstacle radius + desired inflating amount
        inflate(obstacleMap, 0.1+inflateAmount);
    end

    %Constructing new inflated occupancy map
    combinedGrid = getOccupancy(inflatedMap) | getOccupancy(obstacleMap);  
    combinedMap = binaryOccupancyMap(combinedGrid, 10);

    %Finding points in the current path that are obstructed
    obstructedPoints = getOccupancy(obstacleMap, path);

    %Create planner object using new occupancy map
    planner = plannerAStarGrid(combinedMap);

    if any(obstructedPoints)

        if ~checkOccupancy(combinedMap, path(1,:))
            newPath = plan(planner, path(1,:), path(end,:), 'world');
        else
            newPath = plan(planner, pose(1:2)', path(end,:), 'world');
        end


        
        if smoothing
            newPath = cell2mat(pathSmoothing(combinedMap, {newPath}));
        end

    else
        newPath = path;
    end

end