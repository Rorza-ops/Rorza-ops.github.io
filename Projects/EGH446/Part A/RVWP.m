function [Target, RW2, Offset, RW1] = RVWP(RobotPose, Waypoints, WaypointIdx, Lookahead)

lastWaypoint = transform(RobotPose, Waypoints(WaypointIdx-1,:));

targetWaypoint = transform(RobotPose, Waypoints(WaypointIdx,:));

RW1 = sqrt((lastWaypoint(1))^2+(lastWaypoint(2))^2);
RW2 = sqrt((targetWaypoint(1))^2+(targetWaypoint(2))^2);
W1W2 = sqrt((targetWaypoint(1)-lastWaypoint(1))^2+(targetWaypoint(2)-lastWaypoint(2))^2);

%Error confirmed to be in here
%it is a rounding error affecting my implementation of the cos rule, alter
%to different rule
%Alpha = acos((W1W2^2+RW2^2-RW1^2)/(2*W1W2*RW2));

%this acts as a solution for now
cosAlpha = (W1W2^2 + RW1^2 - RW2^2) / (2 * W1W2 * RW1);
cosAlpha = max(min(cosAlpha, 1), -1);
Alpha = acos(cosAlpha);
%}
Distance = cos(Alpha)*RW1;
Offset = sin(Alpha)*RW1;

Beta = atan2(targetWaypoint(1) - lastWaypoint(1), targetWaypoint(2) - lastWaypoint(2));

Target = [lastWaypoint(1) + (Distance + Lookahead)*sin(Beta), lastWaypoint(2) + (Distance + Lookahead)*cos(Beta)];

end