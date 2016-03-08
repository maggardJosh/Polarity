package{
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Turret extends MovieClip{
		
		public var polarity:Boolean;				//Polarity of turret
		
		public var _collisionArea:MovieClip;
		
		public var barrel:MovieClip;				//Barrel of gun
		public var bullet:Bullet;					//One bullet the turret
		
		public var radius:Number;					//Radius turret can see player in
		
		public function Turret(){
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_collisionArea = this;
			
			bullet = new Bullet(x,y,polarity);		//Create a new bullet at this location with this polarity
			
			Main.levelManager.addChild(bullet);		//Add bullet to level
			Main.levelManager.setChildIndex(bullet, Main.levelManager.getChildIndex(this)-1);		//Set it directly below this turret
			
			bullet.alpha=0;				//Set bullet to invisible
			
			radius = Main.TURRET_RADIUS;				//Set radius
			Main.levelManager.turretList.push(this);	//Add this to turret list
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			var turretList:Array = Main.levelManager.turretList;	//Get turret list
			turretList.splice(turretList.indexOf(this), 1);			//Remove this
			
			Main.levelManager.removeChild(bullet);				//Also remove bullet from level
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	fire
		 *
		 *	Function - Fires bullet if it has not been fired already, 
		 *	the player is alive, 
		 *	and if a random number equals 1
		 *
		 ********************************/
		private function fire(xPrime:Number, yPrime:Number, angle:Number)
		{
			if(!bullet.isFired && 				//If bullet is not already shot
			   Main.player.alive && 			//and player is alive
			   (int)(Math.random()*20)==1)		//Use random number to create slightly random shot
			{
				if(polarity)						//If positive
					bullet.gotoAndPlay("shootingPositive");		//Play positive shooting anim
				else								//If negative
					bullet.gotoAndPlay("shootingNegative");		//play negative shooting anim
				bullet.isFired=true;				//Set bullet to fired
				bullet.magnet.isOn = true;			//Set magnet of bullet on
				bullet.alpha=1;						//Set alpha of bullet to 1
				
	 			//Find the bullet's vx and vy based off of the turret's angle
				bullet.vx= Math.cos(angle*Main.PIOVER180)*Main.BULLET_SPEED;
				bullet.vy= Math.sin(angle*Main.PIOVER180)*Main.BULLET_SPEED;
			}				 
		}
		
		/*
		 *	update
		 *
		 *	Function updates turret angle
		 *	and tries to fire a bullet each frame
		 *
		 ************************************/
		public function update(){
			
			//Get the player x and y
			var playerX:Number = Main.player.x;
			var playerY:Number = Main.player.y;
			
			//Find the difference
			playerX-=x;
			playerY-=y;
			
			//Get the player X and Y squared
			playerX*=playerX;
			playerY*=playerY;
			
			if(playerX+playerY<=radius*radius*2*2)		//If player is within turret radius
			{			
				//Find the rotation of the barrel
				barrel.rotation = Math.atan2(Main.player.y-y, Main.player.x-x)*Main.NUM_180OVERPI - rotation;
				
				//Try to fire the bullet
				fire(Main.player.x, Main.player.y, barrel.rotation+rotation);
				
			}
			else{						//If player is not with the radius
				barrel.rotation*=.8;				//Slowly go back to original rotation
				if(Math.abs(barrel.rotation) < 1)	//If very close to zero
					barrel.rotation = 0;			//Set it to zero
			}
			bullet.update();				//Update bullet
				
			
		}
	}
}