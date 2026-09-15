%{
function Path = customGrid2world(map, path)
    resolution = map.Resolution;
    origin = map.GridLocationInWorld;
    
    x = (path(:,2) - 1) / resolution + origin(1);
    y = (path(:,1) - 1) / resolution + origin(2);
    Path = [x,y];
end
%}
%{
function Path = customGrid2world(map, path)

    resolution = map.Resolution;
    gridSize = size(getOccupancy(map));  % Assuming the map is represented as a MATLAB array

    invertedRows = gridSize(1) - path(:,1) + 1;

    x = (path(:,2) - 1) / resolution + 0.1;  % Convert column to x
    y = (invertedRows - 1) / resolution + 0.1;  % Convert inverted row to y

    Path = [x, y];
end
%}

function Path = customGrid2world(map, path)

    resolution = map.Resolution;
    origin = map.GridLocationInWorld;
    gridSize = size(getOccupancy(map));

    invertedRows = gridSize(1) - path(:,1) + 1;


    x = path(:,2) / resolution + origin(1);
    y = invertedRows / resolution + origin(2);

    Path = [x, y];
end



%{
Path = customGrid2world(map,interpolatedpath);
figure
hold on
show(map)
plot(Path(:, 1), Path(:, 2),'b--');
%}