function [Error, Distance] = directNavigation(x, y, theta, wayX, wayY)
%Takes theta in radians

Target = transform(x, y, theta, wayX, wayY);

Error = atan2(Target(2), Target(1));

Distance = sqrt(Target(1)^2+Target(2)^2);

end