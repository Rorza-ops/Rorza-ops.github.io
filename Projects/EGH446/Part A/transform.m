function vect = transform(Pose, Target)
%Takes theta in radians
SE2 = [cos(Pose(3)), -sin(Pose(3)), Pose(1); sin(Pose(3)), cos(Pose(3)), Pose(2); 0, 0, 1];

vect = inv(SE2)*[Target(1); Target(2); 1];

vect = vect([1,2],:);

end