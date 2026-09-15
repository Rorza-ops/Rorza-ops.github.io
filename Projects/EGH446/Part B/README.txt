Hello :)

The code should be run from main and is fine to simply run all
On the first run ensure startupGround is uncommented
Can comment out after, encase further runs with different waypoints are wanted
With startupGround commented out main should operate to to simply generate and optimise paths

Prior to any run at the bottom of main, 'analysis' can be uncommented and run to show data from the trip.
In these plots the grey areas are the minimum distances allowed to obstructions. 0.15 + 0.25 = 0.4m

Note: As it was also specified in the FAQ, i have given obstacles a radius of 0.15m, 
	this is applied prior to the 0.4m inflation, giving the zone around the object point a diameter of 1.1m.
	(0.15 + 0.25 + 0.15)*2 = 1.1m
	With this as the case i have inflated the max amount such that no matter where an obstacle is it will never fully block a path
	This makes the little gap at the first obstacle unrealistic as a crosstrack error of 0.1m woudl cause collision.

	If this is not the case,
	(0.15 + 0.25)*2 = 8m
	set radiusInclusive to 1. This will adjust all the inflation values and the obstacle parameters, 
	but make the robot go a little closer to things, will still work.


	
