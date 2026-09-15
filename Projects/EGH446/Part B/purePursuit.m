function [Error, Distance] = purePursuit(Pose, target)

    Target = transform(Pose, target);

    Error = atan2(Target(2), Target(1));

    Distance = sqrt(Target(1)^2+Target(2)^2);
end