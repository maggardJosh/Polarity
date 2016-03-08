/*
*	Polarity
*	@authors: Josh Maggard, Johsua Cancienne, Denver Poteet
*	@date: 12/7/10
*	@version: Final 3.0
*	@actualVersion: 89.15.31.2
*	Lines of code: 2698
*/
package  {
	import flash.display.StageDisplayState;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.Stage;
	import flash.system.System;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.events.KeyboardEvent;
	
	public class Main extends MovieClip{

		public static var JUMP_FORCE:int;
		public static var GRAVITY:Number;
		public static var MAX_SPEED:int;
		public static var MIN_SPEED:Number;
		public static var ACCELERATION:Number; 
		public static var BOUNCE:Number;
		public static var FRICTION:Number;
		public static var _friction:Number;

		public static var jumpAccel:Number;
		public static var maxJumpFrames:int;
		
		public static var camera:Camera;
		
		public static var TURRET_RADIUS:Number;
		public static var BULLET_MAGNET_RADIUS:int;
		public static var BULLET_SPEED:int;
		public static var MAX_BULLET_DISTANCE:int;
		public static var MIN_BULLET_SPEED:int;
		
		public static var magnetRadius:int;
		public static var magnetStrength:int;
		public static var magnetControlAccel:Number;
		
		public static var levelManager:LevelManager;
		public static var player:Player;
		
		public static var PIOVER180:Number;
		public static var NUM_180OVERPI:Number;
		
		public static var backgroundMusicOne:Sound;
		public static var backgroundMusicTwo:Sound;
		public static var backgroundMusicThree:Sound;
		public static var soundChannel:SoundChannel;
		public static var musicIndex:int;
		
		private var prologue:Prologue;
		private var story:Story;
		
		public static var fullscreen:Boolean;
		
		public static var spawnPoint:Point;
		public static var initPolarity:Boolean;
		
		public static var polarityIndicator:PolarityIndicator;
		
		public function Main() {
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			backgroundMusicOne = new BackgroundMusicOne();
			backgroundMusicTwo = new BackgroundMusicTwo();
			backgroundMusicThree = new BackgroundMusicThree();
			soundChannel = new SoundChannel();
			
		}
		private function onAddedToStage(event:Event):void
		{
			
			stage.stageFocusRect = false;		//Set focus rectangle to false so no annoying yellow border
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			prologue = new Prologue();
			addChild(prologue);
			prologue.alpha = 0;
			
			prologue.x = stage.stageWidth/2;
			prologue.y = stage.stageHeight/2;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function startScreen()
		{
			musicIndex = 1;			
			soundChannel = backgroundMusicOne.play(0, int.MAX_VALUE);
			
			levelManager = new LevelManager();
			stage.addChild(levelManager);
			levelManager.stop();
			levelManager.x = stage.stageWidth/2;
			levelManager.y = stage.stageHeight/2;
			initVars();
			levelManager.logo.addEventListener(MouseEvent.CLICK, startStory);
			
		}
		
		/***********************
		 *
		 *	startGame()
		 *
		 *	Function that is run when the start button is clicked
		 *
		 *	Sets all variables required to start playing game
		 *	Also initializes symbols
		 *
		 **************************/
		public function startGame()
		{
			player = new Player();				//Create the player
			levelManager.addChild(player);		//Add player to the level
			stage.focus = levelManager;			//Make sure the level is on focus
			nextLevel();						//Go to the first level
			polarityIndicator = new PolarityIndicator();		//Create a polarity indicator
			stage.addChild(polarityIndicator);					//Add the polarity indicator to the stage
			polarityIndicator.x = stage.stageWidth;				//Set the position of the indicator
			polarityIndicator.y = stage.stageHeight*.9;			//Bottom right of stage
			camera = new Camera();						//Create the camera
			stage.addChild(camera);				//Add camera to stage so that it can access stageWidth and stageHeight
			
		}
		
		/*********************
		 *
		 *	startStory animation
		 *
		 *	Function starts story animation and makes the start screen invisible temporarily
		 *
		 ***************************/
		public function startStory(event:Event):void
		{
			soundChannel.stop();
			levelManager.visible = false;				//Set Start Screen to invisible so it doesn't cover it up
			story = new Story();					
			addChild(story);
			story.alpha = 0;
			story.x = stage.stageWidth/2;
			story.y = stage.stageHeight/2;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, skipScene);
		}
		
		/**********************
		 *
		 *	skipScene
		 *
		 *	Function runs when player presses a key during story scene
		 *	skips to end of story scene
		 *
		 **********************/
		private function skipScene(event:KeyboardEvent):void
		{
			story.gotoAndStop("endAnim");
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, skipScene);
		}
		
		/*****************
		 *
		 *	nextLevel()
		 *
		 *	Function used to go to the next level in the level manager
		 *
		 *****************/
		static public function nextLevel()
		{
			levelManager.nextFrame();			//First go to the blank frame to clear everything
			levelManager.nextFrame();			//Then load the next level

			newSong();							//Find a new song (Random but never the same one twice)
			spawnPoint.x = 0;				//Reset player spawnPoint
			spawnPoint.y = 0;
			initPolarity = false;			//Reset initial polarity

			levelManager.initWidth = levelManager.width;			//Set the initial width
			levelManager.initHeight = levelManager.height;			//And height
			
			restartLevel();					//Finally reset the level

		}
		
		/********************
		 *
		 *	newSong()
		 *
		 *	Stop the current song and select a new one
		 *	Randomly picks a song but never plays the same one twice
		 *
		 *******************/
		static public function newSong()
		{
			soundChannel.stop();				//Stop background music
			if(levelManager.currentLabel=="credits")
			{
				soundChannel = backgroundMusicThree.play(0, int.MAX_VALUE);
				return;
			}
			//Create a random number to pick bg music
			//Number = (0 to 1) + 1 == 1 to 2
			var x:int = (int)(Math.random()*2) + 1;
			while(x==musicIndex)					//While the new index is still the current one
				x = (int)(Math.random()*2) + 1;		//Try again
				
			musicIndex = x;				//Set the old index to the new one
			switch(x)
			{
				case 1:		
					soundChannel = backgroundMusicOne.play(0, int.MAX_VALUE);		//play background music one (0 is the position it starts from, int.MAX_VALUE is the number of times to loop (infinite))
					break;
				case 2: 
					soundChannel = backgroundMusicTwo.play(0, int.MAX_VALUE);		//play background music two
					break;
			}
		}
		
		/**********************
		 *
		 *	restartLevel()
		 *
		 *	Restart level from last checkPoint
		 *	Resets player and drones
		 *
		 *********************/
		static public function restartLevel()
		{
			player.reset();
			for(var x:int = 0; x<levelManager.droneList.length; x++)
			{
				levelManager.droneList[x].reset();
				
			}
			for(x = 0; x<levelManager.turretList.length; x++)
			{
				levelManager.turretList[x].bullet.resetBullet();
			}
		}
		
		/*********************
		 *
		 *	reloadLevel()
		 *
		 *	reloads level from the beginning
		 *	resets checkpoints
		 *
		 ***********************/
		static public function reloadLevel()
		{
			levelManager.nextFrame();			//Go to blank frame to clear everything
			levelManager.gotoAndStop(levelManager.currentFrame-3);	//Go to level before current one
			nextLevel();						//Go back to this level
		}
		
		/***********************
		 *
		 *	checkPointSet(cp)
		 *
		 *	Function is run each time the player
		 *	Collides with a new checkpoint
		 *
		 *	Sets 	the player's spawn point
		 *			the player's polarity
		 *			the drones' spawn points
		 *
		 ***********************/
		static public function checkPointSet(checkPoint:CheckPoint)
		{
			spawnPoint.x = checkPoint.x;			//Set the player's spawn point
			spawnPoint.y = checkPoint.y;			//to the checkpoints location
			initPolarity = player.polarity;			//set initial polarity to the current polarity
			
			//Set all drones' spawn points
			for(var x:int = 0; x<levelManager.droneList.length; x++)
			{
				levelManager.droneList[x].setSpawn();		//NOTE: this function also sets velocity
			}
			
		}
		
		private function initVars():void
		{
			GRAVITY = 1.3;				//Gravity applied to player each frame
			MAX_SPEED = 20;				//Max speed in either plane
			MIN_SPEED = .1;				//Min speed in either plane (When less than this it is set to 0)
			ACCELERATION = 1.1;			//Acceleration of player
			BOUNCE = -.2;				//Used to bounce off walls
			FRICTION = .68;				//Friction applied to player when he hits floor
			_friction = FRICTION;		//Variable used to apply friction ONLY when not pressing a key
			
			maxJumpFrames = 5;			//Max number of frames variable jumping can be applied
			jumpAccel = 10;				//Acceleration applied to a jump
			
			magnetStrength=25;			//Strength of magnet
			magnetRadius = 140;			//Magnet radius
			magnetControlAccel = 2.7;	//How much control the player has in a magnetField
			
			PIOVER180 = 3.14/180;		//Used to convert degrees to radians
			NUM_180OVERPI = 180/3.14;	//Used to convert radians to degrees
			spawnPoint = new Point();	//Initialize spawnPoint for the player
			
			fullscreen = false;			//Fullscreen boolean
			
			TURRET_RADIUS=400;				//Radius where turret can see player
			BULLET_MAGNET_RADIUS=170;		//radius of bullet magnetic field
			BULLET_SPEED=15;				//Initial bullet speed
			MAX_BULLET_DISTANCE = 1000;		//Max distance from turret bullet can go
			MIN_BULLET_SPEED = 10;			//Below this speed a bullet will speed up
		}
		public function onEnterFrame(event:Event):void
		{
			if(levelManager!=null)
			{
				stage.focus = levelManager;			//Make sure the level is in focus
				if(fullscreen)						//If fullscreen mode
				{
					if (stage.displayState == StageDisplayState.NORMAL) 		//If not already
						stage.displayState=StageDisplayState.FULL_SCREEN;		//Display in fullscreen
				}
				else								//If not fullscreen mode
				{
					if (stage.displayState == StageDisplayState.FULL_SCREEN)	//If not already
						stage.displayState = StageDisplayState.NORMAL;			//Display windowed mode
				}
				
				if(player!=null)				//If player exists
					camera.setCamera();			//Set the camera
			}
			if(prologue!=null)					//If we are watching the prologue anim
			{
				if(prologue.currentLabel == "endAnim")			//If it has reached the end
				{
					startScreen();								//load start screen
					removeChild(prologue);						//remove the prologue symbol
					prologue = null;							//set it to null to prevent this block of code from running
					return;
				}
				if(prologue.currentLabel == "fadeOut")
				{
					if(prologue.alpha > 0)
						prologue.alpha -=.1;
				}
				else
				if(prologue.currentLabel == "fadeIn")
				{
					if(prologue.alpha < 1)
					prologue.alpha +=.1;
				}
				else
				prologue.alpha = 1;
			}
			if(story!=null)						//If we are watching the story anim
			{				
				if(story.currentLabel == "endAnim")			//If we have reached the end of the animation
				{
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, skipScene);	//Make sure we remove the eventListener for skipping the scene
					removeChild(story);						//Remove story from the stage
					story = null;							//Set to null to prevent code from continuously running
					levelManager.visible = true;			//Set levelManager back to visible
					startGame();							//Start the game
					return;
				}
				if(story.currentLabel == "fadeOut")
				{
					if(story.alpha > 0)
						story.alpha -=.1
				} else
				if(story.currentLabel == "fadeIn")
				{
					if(story.alpha < 1)
						story.alpha +=.1;
				} else
					story.alpha = 1;
			}
		}
	}
}
