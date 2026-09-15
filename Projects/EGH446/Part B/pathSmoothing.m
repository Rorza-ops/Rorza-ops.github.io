function [interpolatedPaths, Path, Distance] = pathSmoothing(map, paths)
    
    %Converting map object to logical
    logical = getOccupancy(map);

    interpolatedPaths = {};

    Path = [];

    Distance = 0;

    %For each local path
    for i = 1:length(paths)
        
        %Convert local path to grid coordinates
        localPath = world2grid(map,paths{i});

        %Initialise variable to store the smoothed local path
        newPath = localPath(1,:);

        interpolatedLocal = [];

        for j = 2:length(localPath)

            %If line of sight to point is obstructed
            if ~bresenham(newPath(end,:), localPath(j,:), logical)
                
                %Link path to last viable point
                interpolatedLocal = [interpolatedLocal; interpolatePath(newPath(end,:), localPath(j-1,:))];
                Distance = Distance + sqrt((newPath(end,1)-localPath(j-1,1))^2+(newPath(end,2)-localPath(j-1,2))^2);
        
                newPath = [newPath; localPath(j-1,:)];
            end

        end
        
        %Link path to waypoint
        interpolatedLocal = [interpolatedLocal; interpolatePath(newPath(end,:), localPath(j,:))];
        Distance = Distance + sqrt((newPath(end,1)-localPath(j,1))^2+(newPath(end,2)-localPath(j,2))^2);

        interpolatedPaths{i} = customGrid2world(map,interpolatedLocal);

        newPath = [newPath; localPath(j,:)];

        Path = [Path; newPath];

    end
    Path = customGrid2world(map, Path);
    Distance = Distance/10;
    

end