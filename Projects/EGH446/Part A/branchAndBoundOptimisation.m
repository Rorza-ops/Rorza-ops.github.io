function [Waypoints, Distance] = branchAndBoundOptimisation(waypoints)
    
    %Total number of waypoints including start point
    N = length(waypoints);

    %Create a distance matrix holding the distances between every possible
    %set of points
    distanceMatrix = zeros(N, N);
    for i = 1:N
        for j = 1:N
            distanceMatrix(i, j) = sqrt((waypoints(i, 1) - waypoints(j, 1))^2 + (waypoints(i, 2) - waypoints(j, 2))^2);
        end
    end
    
    %Initiate the recursive brand and bound process
    [bestPath, Distance] = branchAndBound(1, 2:N, distanceMatrix, 0, inf, []);

    %Reorder waypoints according to the optimal path
    Waypoints = waypoints(bestPath,:);
end

function [bestPath, bestDistance] = branchAndBound(currentPath, unvisited, distanceMatrix, currentDistance, bestDistance, bestPath)

    %Will only pass if end of tree is reached
    if isempty(unvisited)
        %If current path is better than the best path
        if currentDistance < bestDistance
            %Update best path and distance
            bestDistance = currentDistance;
            bestPath = currentPath;
        end

        %Backtrack
        return;
    end

    %Iterating through nodes of the current subtree
    for i = 1:length(unvisited)

        %Update to consider next potential node
        newPath = [currentPath, unvisited(i)];
        newDistance = currentDistance + distanceMatrix(currentPath(end), unvisited(i));
        %Create updated unvisited list
        remaining = unvisited;
        remaining(i) = [];

        %Calculate the lowest bound according to custom lowest bound function
        lb = calculateLowestBound(newPath, remaining, distanceMatrix);
        
        %If the calculated lowest bound is less than the known best
        %distance, expand this node
        if lb < bestDistance
            [bestPath, bestDistance] = branchAndBound(newPath, remaining, distanceMatrix, newDistance, bestDistance, bestPath);
        end
        %Else the node is pruned and the next is examined
    end
end

function lb = calculateLowestBound(visited, unvisited, distanceMatrix)
    
    lb = 0;
    
    %For each visited node, sum the distances traveled
    for i = 2:length(visited)
        lb = lb + distanceMatrix(visited(i),visited(i-1));
    end
    
   if length(unvisited) > 1
        %Accounting for the edge between the last visited node and any next
        %unvisited node
        edge = distanceMatrix(visited(end),unvisited);   
        lb = lb + min(edge(edge>0));

        %Accounting for the edges between unvisited nodes
        edges = distanceMatrix(unvisited, unvisited);
        edges = edges(edges>0);
        lb = lb + sum(mink(edges, ((length(unvisited)-1)*2)))/2;
   end
end

