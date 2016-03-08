package
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class Collision
	{
		public function Collision()
		{
			
		}
		
		//Variables used for all but one function
		//Made global so we can use less code and use getVars function
		static public var objectA_Halfwidth:Number;
		static public var objectA_Halfheight:Number;
		static public var objectB_Halfwidth:Number;
		static public var objectB_Halfheight:Number;
		
		static public var dx:Number;		//Difference in x plane
		static public var ox:Number;		//Offset in x plane
		
		static public var dy:Number;		//Difference in y plane
		static public var oy:Number;		//Offset in y plane
		
		
		//Gets all variables declared above for each function
		static public function getVars(objectA:Object, objectB:Object)
		{
			//Get half of the width for the collision area for objectA
			objectA_Halfwidth = objectA._collisionArea.width /2;
			objectA_Halfheight = objectA._collisionArea.height /2;
			
			//Get half of the width for objectB
			objectB_Halfwidth = objectB._collisionArea.width /2;
			objectB_Halfheight = objectB._collisionArea.height /2;
			
			dx = objectB.x - objectA.x;				//Figure out the x difference
			ox = objectB_Halfwidth + objectA_Halfwidth - Math.abs(dx);	//And the x offset first
			
			dy= objectB.y - objectA.y;			//Get the y difference
			oy = objectB_Halfheight + objectA_Halfheight - Math.abs(dy);	//And the y offset
		}
		
		/*
		 *	Tests for and applies a magnetic effect to the player
		 *
		 ************************************************************/
		static public function PlayerMagneticEffect(objectA:Player, objectB:Magnet):void{
			
			var xDistance:Number;					//xDistance between two objects
			var yDistance:Number;					//yDistance between two objects
			var distanceSquared:Number;			//variable to store distance squared
			var radiusSquared:int;				//variable to store radius squared
			
			if(!objectB.isOn)				//If the magnet is off
				return;						//Do NOTHING
			
			radiusSquared = objectB._magnetField.width/2*objectB._magnetField.width/2;	//Set radius squared
			
			xDistance = objectA.x-objectB.x;			//Get xDistance
			yDistance = objectA.y-objectB.y;			//Get yDistance
			distanceSquared = xDistance*xDistance + yDistance*yDistance;	//Set distance squared
			
			if(distanceSquared<=radiusSquared*5)			//If within a certain distance to magnet
			{
				if(objectB._magnetField.currentFrame==1)	//If magnetField is not playing
				{
					objectB._magnetField.gotoAndPlay(1);	//start magnetField animation
				}
			}
			else											//If not within certain distance to magnet
			{
				if(objectB._magnetField.currentFrame<50&&	//And if playing animation
				   objectB._magnetField.currentFrame!=1)
				objectB._magnetField.gotoAndPlay(50);		//End animation
			}
			
			if(distanceSquared<=radiusSquared){				//If player is within magnetic field
				
				objectA.beingAttracted=true;				//Set objectA.beingAttracted to true
				objectB._magnetStream.alpha = 100;			//Set alpha of _magnetStream to 100
				
				objectB._magnetStream.rotation = 0;							//Set rotation to 0 so height works correctly
				objectB._magnetStream.height = Math.sqrt(distanceSquared);	//Set height to distance between two objects
				objectB._magnetStream.rotation=((Math.atan2(yDistance, xDistance)*(180/3.14)+90));;			//Set rotation to players rotation
				
				objectB._magnetStream.x = objectB.x;						//Position the magnetStream
				objectB._magnetStream.y = objectB.y;

				if((objectA.polarity&&!objectB.polarity)||
				   (!objectA.polarity&&objectB.polarity)){		//If polarities are opposing
																//Then attract player to magnet
					objectA.vx-=xDistance/Main.magnetStrength;
					objectA.vy-=yDistance/Main.magnetStrength;
					
					objectA.magnetEffectPerFrame.x += xDistance/Main.magnetStrength;	//magnetEffectPerFrame used to orient player
					objectA.magnetEffectPerFrame.y += yDistance/Main.magnetStrength;

				}
				else{											//Otherwise, polarities match
																//Push player away from magnet
					objectA.vx+=xDistance/Main.magnetStrength;
					objectA.vy+=yDistance/Main.magnetStrength;
					
					objectA.magnetEffectPerFrame.x -= xDistance/Main.magnetStrength;		//Set magnetEffectPerFrame
					objectA.magnetEffectPerFrame.y -= yDistance/Main.magnetStrength;		//(It is used for rotational purposes)
				}
			}
			else
			{
				objectB._magnetStream.alpha /= 2;		//If not affecting player fade away
				if(objectB._magnetStream.alpha < .01)	//If visibility very low
					objectB._magnetStream.alpha = 0;	//set alpha to zero
			}
		}
		
		//	Function used to detect and apply Magnetic effect on bullet
		//	NOTE: This function does not affect player (Above method does and is run automatically by all magnets)
		static public function checkBulletMagneticEffect(objectA:Bullet, objectB:Player):void{
			
			var xDistance:Number;					//xDistance between two objects
			var yDistance:Number;					//yDistance between two objects
			var distanceSquared:Number;			//variable to store distance squared
			var radiusSquared:int;				//variable to store radius squared
			
			radiusSquared = Main.BULLET_MAGNET_RADIUS*Main.BULLET_MAGNET_RADIUS;	//Set radius squared
			
			xDistance = objectA.x-objectB.x;			//Get xDistance
			yDistance = objectA.y-objectB.y;			//Get yDistance
			distanceSquared = xDistance*xDistance + yDistance*yDistance;	//Set distance squared

			if(distanceSquared<=radiusSquared){				//If player is within magnetic field

				if((objectA.polarity&&!objectB.polarity)||
				   (!objectA.polarity&&objectB.polarity)){		//If polarities are opposing
																//Then attract bullet to player
					objectA.vx-=xDistance/Main.magnetStrength;
					objectA.vy-=yDistance/Main.magnetStrength;

				}
				else{											//Otherwise, polarities match
																//Push bullet away from player
					objectA.vx+=xDistance/Main.magnetStrength;
					objectA.vy+=yDistance/Main.magnetStrength;
					
				}
			}
		}
		
		//Function that makes sure player does not go through walls
		static public function PlayerWallBlock(objectA:Player, objectB:Wall):void
		{
			getVars(objectA, objectB);		//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{				
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(ox <oy)			//If the collision is closer to either the left or right side (as opposed to the top and bottom...
					{
						if(dx <0)
						{
							//Collision on Right of wall
							if(objectA.vx<0 && !objectA.beingAttracted)				//If player is actually traveling toward wall
								objectA.vx*=Main.BOUNCE;	//Then bounce off of it

							oy = 0;							//Set y offset to 0
						}
						else
						{
							//Collision on Left of wall
							ox *= -1;						//Correct the x offset
							if(objectA.vx>0 && !objectA.beingAttracted)				//If player is actually traveling toward wall
								objectA.vx*=Main.BOUNCE;	//Then bounce off of it
							
							oy = 0;							//Set y offset to 0
						}
					}
					else
					{
						if (dy >= 0)
						{
							//Collision on Top of wall
							ox = 0;				//Set x offset to 0
							oy *= -1;			//Correct y offset
				
							if(objectA.vy>0)			//Make sure player is not trying to jump off of ground
							{
								objectA.vy=0;			//If not set Y-Velocity to 0							
								objectA.grounded = true;		//Set grounded to true if it is not already
								if(!objectA.beingAttracted)
									objectA.vx *= Main._friction;	//Apply ground friction
							}
						}
						else
						{
							//Collision on Bottom of wall
							ox = 0;							//Set x offset to 0
							if(objectA.vy<0&&!objectA.beingAttracted)				//If player is actually traveling toward wall
								objectA.vy*=Main.BOUNCE;	//Bounce off it
							
						}
					}
					
					//Use the calculated x and y overlaps to
					//Move objectA out of the collision
					
					objectA.x += ox;
					objectA.y += oy;
				}
			}
		}
		
		//Function used to detect and correct drone on drone collisions
		static public function droneDroneBlock(objectA:Drone, objectB:Drone)
		{
			getVars(objectA, objectB);		//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(ox <oy)			//If the collision is closer to either the left or right side (as opposed to the top and bottom...
					{
						if(dx <0)
						{
							//Collision on Right of droneB
							if(objectA.vx<0 )				//If droneA is actually traveling toward droneB
								objectA.vx*=-1;		//Then bounce off 
								
							if(objectB.vx > 0)		//If droneB is actually traveling toward droneA
									objectB.vx*=-1;		//Then bounce off
							
							oy = 0;							//Set y offset to 0
						}
						else
						{
							//Collision on Left of droneB
							ox *= -1;						//Correct the x offset
							if(objectA.vx>0)				//If droneA is actually traveling toward droneB
								objectA.vx*=-1;			//Then bounce off 
							if(objectB.vx < 0)				//If droneB is actually traveling toward droneA
								objectB.vx*=-1;			//Then bounce off
							
							oy = 0;							//Set y offset to 0
						}
					}
					else
					{
						if (dy > 0)
						{
							//Collision on Top of droneB
							ox = 0;				//Set x offset to 0
							oy *= -1;			//Correct y offset
							
							if(objectA.vy > 0)			//If objectA was traveling toward B
								objectA.vy = 0;		//Set vy to zero
							if(objectB.vy < 0)			//If objectB was traveling toward A
								objectB.vy = 0;		//Set vy to zero
						}
						else
						{
							//Collision on Bottom of droneB
							ox = 0;							//Set x offset to 0
							oy = 0;
							return;
							if(objectA.vy < 0)			//If objectA was traveling toward B
								objectA.vy = 0;		//Set vy to zero
							if(objectB.vy > 0)			//If objectB was traveling toward A
								objectB.vy = 0;		//Set vy to zero
							
						}
					}
					
					//Use the calculated x and y overlaps to
					//Move objectA out of the collision
					
					//objectA.x += ox;
					objectA.y += oy;
				}
			}
		}
		
		//	Function tests for drone/Player collisions
		//	will affect player's velocity but do nothing to drone
		static public function dronePlayerBlock(objectA:Player, objectB:Drone):void
		{
			getVars(objectA, objectB);			//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(ox <oy)			//If the collision is closer to either the left or right side (as opposed to the top and bottom...
					{
						if(dx <0)
						{
							//Collision on Right of wall
							if(objectA.vx<0 && !objectA.beingAttracted)				//If player is actually traveling toward drone
								objectA.vx*=Main.BOUNCE;	//Then bounce off of it
							
							oy = 0;							//Set y offset to 0
						}
						else
						{
							//Collision on Left of wall
							ox *= -1;						//Correct the x offset
							if(objectA.vx>0 && !objectA.beingAttracted)				//If player is actually traveling toward drone
								objectA.vx*=Main.BOUNCE;	//Then bounce off of it
							
							oy = 0;							//Set y offset to 0
						}
					}
					else
					{
						if (dy >= 0)
						{
							//Collision on Top of wall
							ox = 0;				//Set x offset to 0
							oy *= -1;			//Correct y offset
				
							if(objectA.vy>0)			//Make sure player is actually moving toward drone
							{
								objectA.vy*=Main.BOUNCE;			//Bounce off of it						
							}
						}
						else
						{
							//Collision on Bottom of wall
							ox = 0;							//Set x offset to 0
							if(objectA.vy<0)				//If player is actually traveling toward drone
								objectA.vy*=Main.BOUNCE;	//Bounce off it
							
						}
					}
					
					//Use the calculated x and y overlaps to
					//Move objectA out of the collision
					
					objectA.x += ox;
					objectA.y += oy;
				}
			}
		}
		
		//Function that makes sure Drones do not go through walls
		static public function DroneWallBlock(objectA:Drone, objectB:Wall):void
		{
			getVars(objectA, objectB);		//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(ox <oy)			//If the collision is closer to either the left or right side (as opposed to the top and bottom...)
					{
						if(dx <0)
						{
							//Collision on Right of wall
							if(objectA.vx<0 )				//If drone is actually traveling toward wall
								objectA.vx*=-1;				//Then bounce off of it
							
							oy = 0;							//Set y offset to 0
						}
						else
						{
							//Collision on Left of wall
							ox *= -1;						//Correct the x offset
							if(objectA.vx>0)				//If drone is actually traveling toward wall
								objectA.vx*=-1;				//Then bounce off of it
							
							oy = 0;							//Set y offset to 0
						}
					}
					else
					{
						if (dy >= 0)
						{
							//Collision on Top of wall
							ox = 0;				//Set x offset to 0
							oy *= -1;			//Correct y offset
							
								objectA.vy*=Main.BOUNCE;		//Give a little bounce effect

						}
						else
						{
							//Collision on Bottom of wall
							ox = 0;							//Set x offset to 0
							if(objectA.vy<0)				//If drone is actually traveling toward wall
								objectA.vy*=Main.BOUNCE;	//Bounce off it
							
						}
					}
					
					//Use the calculated x and y overlaps to
					//Move objectA out of the collision
					
					objectA.x += ox;
					objectA.y += oy;
				}
			}
		}
		
		//Function that tests for player collision with demagnetizers
		static public function PlayerDemagnetizer(objectA:Player, objectB:Demagnetizer):void
		{

			getVars(objectA, objectB);			//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					
					if(objectA.alive)		//If not already dead
					{	
						objectA.gotoAndPlay("shocked");		//Start shocked animation
						objectA.scaleX = 1;					//Make sure he is facing right
					}
					objectA.alive = false;			//Set alive to false so this doesn't run again
				}
			}
		}
		
		//Function checks for player collision with the levelEnd symbol
		static public function levelEndCheck(objectA:Player, objectB:LevelEnd):void
		{
			getVars(objectA, objectB);			//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(!objectA.won)			//If we have not already won
						objectB.gotoAndPlay("win");		//Start winning animation
						
					objectA.won = true;			//And set won to true;
					
				}
			}
		}
		
		//Function used to detect collisions between player and check points
		static public function checkPointCheck(objectA:Player, objectB:CheckPoint):void
		{
			getVars(objectA, objectB);		//Get all variables
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(objectB.currentLabel!="set" && objectB.currentLabel!="setting")			//If we have not already reached this point
					{
						objectB.gotoAndPlay("setting");		//Start check point 'set' anim		
						Main.checkPointSet(objectB);		//Save all positions and variables
					}
				}
			}
		}
		
		//	Function check for Bullet/Player collisions
		//	if collision occurs will kill player and destroy bullet
		static public function checkBulletCollision_Player(objectA:Bullet, objectB:Player){
			
			getVars(objectA,objectB);
			if(ox >0)	//If the two objects collide in the x plane...
			{
				if(oy > 0)				//If they collide in the y plane also...
				{
					if(objectB.alive && 								//if not already dead and
					   objectA.currentLabel!="explodingPositive" && 	//Bullet is not already exploding
					   objectA.currentLabel!="explodingNegative")		//Bullet is not already exploding
					{	
						objectA.bulletHit();				//Destroy bullet
						objectB.gotoAndPlay("shocked");		//Start shocked animation
						objectB.scaleX = 1;					//Make sure he is facing right
						objectB.alive = false;			//Set alive to false so this doesn't run again
					}
				}
			}
		}
		
		//	Function used to detect Bullet/Wall collisions
		//	Upon collision bullet is destroyed
		static public function checkBulletCollision_Wall(objectA:Bullet, objectB:Wall)
		{
			if(objectA.hitTestObject(objectB) && 	//If bullet hits wall
			   objectA.isFired)						//And it HAS been fired
				objectA.bulletHit();				//Destroy it!
		
		}
		
		
	}
}