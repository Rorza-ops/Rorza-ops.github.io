function plotMazeRoute(Map, Waypoints, Path, Title)

    figure
    show(Map)
    hold on

    plot(Path(:, 1), Path(:, 2),'b--');

    plot(Waypoints(1, 1), Waypoints(1, 2),'y*');
    plot(Waypoints(end, 1), Waypoints(end, 2),'r*');
    plot(Waypoints(2:end-1, 1), Waypoints(2:end-1, 2),'r*');

    text(Waypoints(1, 1), Waypoints(1, 2),'Start')

    for i=2:length(Waypoints)
        text(Waypoints(i, 1), Waypoints(i, 2),num2str(i-1))
    end

    title(Title)

end