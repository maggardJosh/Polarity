package{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Bullet extends MovieClip{
		
		public var vx:Number;
		public var vy:Number;
		
		public var initPos:Point;				//Initial position of bullet (Used for max distance)
		public var _collisionArea:MovieClip;	//Collision area of bullet
		public var isFired:Boolean;				//isFired = true when the bullet is not available to be fired yet
		public var polarity:Boolean;			//Polarity of bullet
		public var magnet:Magnet;				//Bullet's own personal magnet!
		
		public function Bullet(xinit:Number, yinit:Number, pol:Boolean){
			initPos=new Point(xinit,yinit);		//set the initial position to the passed variable
			x=xinit;							//set x
			y=yinit;							//Set y
			polarity = pol;						//Set polarity
			magnet = new Magnet();				//Initialize magnet
			magnet.polarity = pol;				//Set magnet's polarity
			
			_collisionArea = this;				//Set collision area
			
			//Initialize variables
			isFired = false;					
			alpha=0;							
			vx = 0;
			vy = 0;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			
			MovieClip(parent).addChild(magnet);		//Add it's magnet to the same place
			magnet.visible = false;					//Set it to false though			
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			MovieClip(parent).removeChild(magnet);		//If we are removed remove the magnet too
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/******************
		 *
		 *	bulletHit
		 *
		 *	Function ran whenever a bullet hits something and
		 *	needs to be destroyed
		 *
		 *******************/
		public function bulletHit(){
			if(polarity)									//If positive
				if(currentLabel!="explodingPositive")		//And not running positive exploding anim
					gotoAndPlay("explodingPositive");		//Run it!
			if(!polarity)									//If negative
				if(currentLabel!="explodingNegative")		//And not running negative exploding anim
					gotoAndPlay("explodingNegative");		//Run it!
					
			magnet.isOn = false;					//Turn magnet off
			magnet._magnetField.gotoAndStop(1);		//Make the magnet's field invisible
			magnet._magnetStream.alpha = 0;			//And it's magnet stream
			
		}
		
		/*****************************
		 *
		 *	resetBullet()
		 *
		 *	Function resets all bullet variables and
		 *	preps the bullet to be shot again
		 *
		 *****************************/
		public function resetBullet()
		{
			//NOTE: If we do not stop animation the bullet will loop through entire animation until it is shot again
			stop();							//STOP ANIMATION(VERY IMPORTANT)
			
			isFired = false;				//Set is fired to false
			magnet.isOn = false;			//Make sure magnet is off
			x=initPos.x;					//Reset position
			y=initPos.y;					
			magnet.x = x;						//Reset magnet position
			magnet.y = y;
			magnet._magnetField.gotoAndStop(1);		//Make sure magnetField is invisible
			magnet._magnetStream.alpha = 0;			//Ditto with magnetStream
			vx = vy = 0;						//Set velocities to zero
		}
		
		/******************************
		 *
		 *	checkAnim()
		 *
		 *	Function tests bullet and makes sure it is running
		 *	the correct animation
		 *
		 *	Note: Runs every frame
		 *
		 *****************************/
		
		private function checkAnim()
		{
			if(polarity)			//If it is positive
			{
				if(currentLabel=="explodingPositive")	//If currently in the exploding animation
					return;								//Do nothing
				else									//Else
				if(currentLabel=="endExplodingPositive")//If just got done exploding
				{
					resetBullet();						//Reset the bullet
					return;								//And return
				}
				
				if(isFired)									//If bullet is fired
					if(currentLabel!="shootingPositive")	//And not playing shooting animation
						gotoAndPlay("shootingPositive");	//Play it!
					
			}
			else					//If it is negative
			{
				if(currentLabel=="explodingNegative")	//If currently in the exploding animation
					return;								//Do nothing
				else									//Else
				if(currentLabel=="endExplodingNegative")//If just got done exploding
				{
					resetBullet();						//ResetBullet
					return;								//And return
				}
				
				if(isFired)									//If bullet has been fired
					if(currentLabel!="shootingNegative")	//And not playing shooting animation
						gotoAndPlay("shootingNegative");	//Play it!
					
			}
		}
		
		/**************************
		 *
		 *	update()
		 *
		 *	Function updates bullet
		 *	Runs checkAnim
		 *	Applies velocity and check for collisions
		 *
		 **************************/
		public function update(){
			
			checkAnim();			//Check animation
			if(isFired)				//If it has been fired
			{			
				this.x+=vx;			//Apply x velocity
				this.y+=vy;			//Apply y velocity
			
				Main.levelManager.checkBulletCollision_PLAYER(this);		//check for bullet collisions with player
				Main.levelManager.bulletMagneticEffect(this);				//check for magnetic effect on player
																	//NOTE: Magnet AUTOMATICALLY applies effect on player
				
				var xDist:Number = this.x-initPos.x;			//Get xDistance
				var yDist:Number = this.y-initPos.y;			//Get yDistance
				var DistSquared:Number = xDist*xDist + yDist*yDist;	//Use these and get distance squared
				
				if(vx*vx + vy*vy < Main.MIN_BULLET_SPEED * Main.MIN_BULLET_SPEED)	//If the velocity magnitude is too small
				{
					vx*=1.1;		//Slightly increase it
					vy*=1.1;		//So that bullet's don't slow down to a 'float'
				}
				
				if(DistSquared > Main.MAX_BULLET_DISTANCE* Main.MAX_BULLET_DISTANCE)		//If too far from turret
					bulletHit();					//Destroy bullet
			}
			//Set magnet position
			magnet.x = x;
			magnet.y = y;
			
			//Reset magnet's magnetField radius
			magnet._magnetField.width = Main.BULLET_MAGNET_RADIUS*2;
			magnet._magnetField.height = Main.BULLET_MAGNET_RADIUS*2;
				
		}
	}
}