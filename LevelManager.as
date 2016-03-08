package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class LevelManager extends MovieClip 
	{
		var initWidth:Number;
		var initHeight:Number;
		
		public var droneList:Array;				//Array to hold drones
		public var wallList:Array;				//Array to hold walls
		public var checkPointList:Array;		//Array to hold checkPoints
		public var turretList:Array;			//Array to hold turrets
		
		private var pauseScreen:PauseScreen;	//Pause screen clip
		public var paused:Boolean;				//Boolean pause variable
		
		public function LevelManager() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//Initialize arrays
			droneList = new Array();
			wallList = new Array();
			checkPointList = new Array();
			turretList = new Array();
			
			pauseScreen = new PauseScreen();		//Initialize pause screen
			paused = false;							//Set paused to false initially
			
			initWidth = this.width;					//Initialize initWidth
			initHeight = this.height;				//And initHeight
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.P)			//If P is pressed
			{
				paused=!paused;						//Reverse paused
				if(paused)							//If now paused
				{
					addChild(pauseScreen);			//Add pause screen to levelManager
					pauseScreen.x = Main.player.x;	//Center pause screen
					pauseScreen.y = Main.player.y;
					
					pauseGame();					//Pause animations
				}
				else								//If not paused anymore
				{
					removeChild(pauseScreen);		//Remove pause screen
					unPauseGame();					//Unpause animations
				}
			}
		}
		
		/****************
		 *
		 *	pauseGame()
		 *
		 *	Used to stop all animations when player pauses
		 *
		 *******************/
		private function pauseGame()
		{
			Main.player.stop();								//Stop player's animation
			for(var x:int =0; x<droneList.length; x++)		//Go through drones
				droneList[x].stop();						//And stop animations
			for(x = 0; x<turretList.length; x++)			//Go through turrets
				turretList[x].bullet.stop();				//Stop bullets animations
			
		}
		
		/****************
		 *
		 *	unPauseGame()
		 *
		 *	Used to stop all animations when player pauses
		 *
		 *******************/
		private function unPauseGame()
		{
			for(var x:int =0; x<droneList.length; x++)		//Go through drones
				droneList[x].play();						//play animations
			for(x = 0; x<turretList.length; x++)			//Go through turrets
				turretList[x].bullet.play();				//play animations
			
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(paused)				//If we are paused
				return;				//Do nothing!
			if(Main.player != null)		//If the player exists
			{
				
				//****** Block of code updates player, drones, and walls in that order. (Order is very important)
				if(currentLabel=="credits")				//If we are in the credits...
					Main.player.polarity=false;			//Force polarity to be false!
				Main.player.update();
				
				for(var x:int = 0; x< droneList.length; x++)		//Go through drone list
				{
					droneList[x].update();								//Update drone
					for(var y:int = 0; y<droneList.length; y++)			//Go through drone list again
						if(x!=y)														//If the current drones do not equal each other
							Collision.droneDroneBlock(droneList[x], droneList[y]);		//Check drone on drone collisions
				}
				
				for(x = 0; x < turretList.length; x++)				//Go through turrets
					turretList[x].update();							//Update each one
				
				for(x = 0; x< wallList.length; x++)					//Go through walls
					wallList[x].update();							//Update each one
				
				Main.player.updatePNMovieClips();				//Update Positive and Negative Pablo MovieClips
				setChildIndex(Main.player, numChildren-1);		//Set Pablo to be on top of all other objects
			}
		}
		
		/****************** COLLISION FUNCTIONS **********************/
		/*	These are called by other classes to test for collisions */
		/*************************************************************/
		
		public function dronePlayerCollision(drone:Drone)
		{
			Collision.dronePlayerBlock(Main.player, drone);
		}
		
		public function checkCollisionWithPlayer(wall:Wall)
		{
				Collision.PlayerWallBlock(Main.player, wall);
		}
		
		public function checkDemagnetizer(demagnetizer:Demagnetizer)
		{
				Collision.PlayerDemagnetizer(Main.player, demagnetizer);
		}
		
		public function checkMagneticFieldWithPlayer(magnet:Magnet)
		{
				Collision.PlayerMagneticEffect(Main.player, magnet);
		}
		public function checkCollisionWithDrone(drone:Drone, wall:Wall)
		{
			Collision.DroneWallBlock(drone, wall);
		}
		public function checkLevelEnd(levelEnd:LevelEnd)
		{
			Collision.levelEndCheck(Main.player, levelEnd);
		}
		
		public function checkCheckPoints(checkPoint:CheckPoint)
		{
			Collision.checkPointCheck(Main.player, checkPoint);
		}
		
		public function checkBulletCollision_PLAYER(bullet:Bullet)
		{
			Collision.checkBulletCollision_Player(bullet,Main.player);
		}
		public function checkBulletCollision_WALL(bullet:Bullet, wall:Wall)
		{
			Collision.checkBulletCollision_Wall(bullet,wall);			
		}
		
		public function bulletMagneticEffect(bullet:Bullet)
		{
			Collision.checkBulletMagneticEffect(bullet, Main.player);
		}
	}
}
