function path = interpolatePath(p1,p2)

    N = round(sqrt((p2(1)-p1(1))^2+(p2(2)-p1(2))^2));

    x = linspace(p1(2), p2(2), N)';
    y = linspace(p1(1), p2(1), N)';

    path = [y,x];



end