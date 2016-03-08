package  {
	import flash.geom.Point;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class Camera extends MovieClip{
		public var vx:Number;
		public var vy:Number;
		public var position:Point;			//Position of camera
		public var distance:Point;			//Distance between player and level origin
		
		private var horizontalScreenBuffer:Number;		
		private var verticalScreenBuffer:Number;
		private var cameraFriction:Number;
		private var cameraAccel:Number;
		public function Camera() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//Initialize variables
			position = new Point();
			distance = new Point();
			vx = 0;
			vy = 0;
			
			horizontalScreenBuffer = 140;	//Horizontal screen buffer from center of screen
			verticalScreenBuffer = 70;		//Vertical screen buffer from center of screen
			cameraFriction = .85;			//Velocity is multiplied by this number each frame
			cameraAccel = 3;				//Acceleration of camera
			
		}
		
		public function onAddedToStage(event:Event):void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage); 
		}
		
		public function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	onEnterFrame()
		 *	Runs each frame
		 *	Applies velocity and friction
		 *	Caps velocity's Max and Min speed
		 *	Then sets the levels position to the camera's position
		 *
		 ***************************/
		public function onEnterFrame(event:Event):void
		{
			position.x += vx;			//Apply velocity
			position.y += vy;
			
			//Cap max and min speeds
			if(vx > Main.MAX_SPEED)
				vx = Main.MAX_SPEED;
			else
				if(vx < -Main.MAX_SPEED)
					vx = -Main.MAX_SPEED;
				
			if(vy > Main.MAX_SPEED)
				vy = Main.MAX_SPEED;
			else
				if(vy < -Main.MAX_SPEED)
					vy = -Main.MAX_SPEED;
					
			if(Math.abs(vx) < Main.MIN_SPEED)
				vx = 0;
			if(Math.abs(vy) < Main.MIN_SPEED)
				vy = 0;
				
			//If we are on the screen apply friction
			if(distance.x > 0 && distance.x < stage.stageWidth)
				vx*=cameraFriction;
			if(distance.y > 0 && distance.y < stage.stageHeight)
				vy*=cameraFriction;

			//Finally set the level's position to the camera's position
			Main.levelManager.x = position.x;
			Main.levelManager.y = position.y;
		}
		
		/*
		 *	setCamera()
		 *
		 *	Finds the new velocity according to the player's 
		 *	distance from the center of the screen
		 */
		public function setCamera():void
		{
			//Get variables for easy access
			//And easier read-ability
			var level:LevelManager = Main.levelManager;
			var player:Player = Main.player;
			var playerX:Number = -player.x;
			var playerY:Number = -player.y;
			
			distance.x = Math.abs(playerX - level.x);		//Get x Distance
			distance.y = Math.abs(playerY - level.y);		//Get y Distance
			
			if(level.x > playerX+(stage.stageWidth/2) + horizontalScreenBuffer)		//If past the right buffer
			{
				vx -= cameraAccel;													//Apply acceleration to velocity
				if(level.x > playerX+(stage.stageWidth) - horizontalScreenBuffer/2)		//If extremely close to the edge of screen
					position.x = playerX+(stage.stageWidth) - horizontalScreenBuffer/2;	//Set the camera's position to keep him in sight
			}
			else
			if(level.x < playerX+(stage.stageWidth/2) - horizontalScreenBuffer)		//If past the left buffer
			{
				vx += cameraAccel;													//Apply acceleration to velocity
				if(level.x < playerX + horizontalScreenBuffer/2)					//If extremely close to the edge of the screen
					position.x = playerX + horizontalScreenBuffer/2;				//Set the camera's position to keep him in sight
			}
			if(level.y > playerY+(stage.stageHeight*.6))		//If past the bottom buffer
			{
				vy -= cameraAccel;							//Accelerate toward player
				if(level.y > playerY + stage.stageHeight - verticalScreenBuffer/2)		//if extremely close to the edge of the screen
					position.y = playerY + stage.stageHeight - verticalScreenBuffer/2;		//Set the camera's position to keep him in sight
			}
			else
			if(level.y < playerY + (stage.stageHeight*.6) - verticalScreenBuffer)	//If past the top buffer
			{
				vy += cameraAccel;									//Accelerate toward player
				if(level.y < playerY + verticalScreenBuffer/2)				//If extremely close to the edge of the screen
					position.y = playerY + verticalScreenBuffer/2;			//Set the camera's position to keep him in sight
			}
		}
		
		//Getter for cameraAccel
		public function get accel():Number
		{
			return cameraAccel;
		}
	}
}
