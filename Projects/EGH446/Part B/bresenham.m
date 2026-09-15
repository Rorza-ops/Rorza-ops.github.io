function los = bresenham(p1,p2,map)

    %returns 0 if obstructed

    %figure
    %imshow(map)
    %hold on
    %grid ON

    x0 = p1(2);
    y0 = p1(1);
    x1 = p2(2);
    y1 = p2(1);
    
    dx = abs(x1-x0);
    dy = -abs(y1-y0);

    sx = sign(x1-x0);
    sy = sign(y1-y0);

    e = dx + dy;

    los = 1;

    while 1

        %plot(x0,y0,'o')
        %axis equal
        %}
        %
        %x0
        %y0
        %map(y0,x0)
        if map(y0,x0)
            los = 0;
            return
        end
        %}

        %y0 
        %y1
        %y0 == y1

        if x0 == x1 && y0 == y1
            break

        end
        e2 = 2*e;
        if e2 >=dy
            
            if x0==x1% || (((x0+sx)-x1)*sx>0)
                break
            end
            e = e+dy;
            x0 = x0+sx;
        end

        if e2 <= dx
            if y0 == y1% || (((y0+sy)-y1)*sy>0)
                break;
            end
            e = e+dx;
            y0 = y0+sy;            


        end

    end

end