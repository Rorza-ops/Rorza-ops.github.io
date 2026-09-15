function visualMap = generateVisualMap(map, obstacles, inflateAmount, radiusInclusive)

    mapCopy = copy(map);

    obstacleMap = binaryOccupancyMap(52,41,10);
    setOccupancy(obstacleMap, obstacles(:,1:2), 1);
    if ~radiusInclusive
        inflate(obstacleMap, 0.1)
    end

    combinedGrid = getOccupancy(mapCopy) | getOccupancy(obstacleMap);

    combinedMap = binaryOccupancyMap(combinedGrid, 10);

    inflatedZone = copy(combinedMap);
    inflate(inflatedZone, inflateAmount);

    combinedLogical = occupancyMatrix(combinedMap);
    inflatedLogical = occupancyMatrix(inflatedZone);

    borders = ((inflatedLogical-combinedLogical) == 1)*0.5;

    visualMap = occupancyMap(combinedLogical+borders,10);
end