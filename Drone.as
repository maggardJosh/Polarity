package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Drone extends MovieClip {
		
		public var _collisionArea:MovieClip;
		
		//Used for checkpoints
		public var _initPos:Point;
		public var _initVel:Point;
		public var _initPolarity:Boolean;
		public var _initCounter:uint;
		
		private var _magnet:Magnet;		//Magnet of drone
		private var _counter:uint;		//Counter used to change polarity over time
		public var vx;
		public var vy;
		
		public function Drone() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			//Set initial spawn information
			_initPos = new Point(x,y);
			_initVel = new Point(-7, 0);
			_initCounter = 0;
			_initPolarity = false;
			
			//Add to the level's droneList
			Main.levelManager.droneList.push(this);
			
			//Initialize variables
			_collisionArea = this;
			
			_magnet = new Magnet();					//Initialize magnet
			_magnet.polarity = false;				//Set it to false
			MovieClip(parent).addChild(_magnet);	//Add it to the stage
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			reset();			//Reset drone with new spawn information
		}
		
		//Set's the drone's spawn information to all current info
		public function setSpawn()
		{
			_initPos.x = x;
			_initPos.y = y;
			_initVel.x = vx;
			_initVel.y = vy;
			_initCounter = _counter;
			_initPolarity = _magnet.polarity;
		}
		
		/*
		 *	reset()
		 *
		 *	Resets the drone's:
		 *		position
		 *		velocity
		 *		polarity
		 *		and _counter
		 ****************************/
		public function reset()
		{
			x = _initPos.x;
			y = _initPos.y;
			vx = _initVel.x;
			vy = _initVel.y;
			
			if(_magnet.polarity!=_initPolarity)		//If not correct polarity			
				_magnet.switchPolarity();			//Switch
			
			_counter = _initCounter;
				
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			var droneList:Array = Main.levelManager.droneList;		//Get the drone list
			droneList.splice(droneList.indexOf(this), 1);		//Remove this drone
			MovieClip(parent).removeChild(_magnet);				//Also remove the magnet

			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	checkAnimation
		 *
		 *	plays the animation of the drone
		 *	
		 ***********************/
		private function checkAnimation()
		{
			if(_counter > 80)			//If the counter is greater than 80
			{
				//Then play the polarity transition animation
				if(_magnet.polarity)		//If positive
					if(currentLabel!="positiveTrans")	//And not already on the positiveTrans anim
						gotoAndPlay("positiveTrans");	//Play it!
				if(!_magnet.polarity)		//If negative
					if(currentLabel!="negativeTrans")	//And not already on the negativeTrans anim
						gotoAndPlay("negativeTrans");	//Play it!
			}
			else					//If not close to a transition
			{
				if(_magnet.polarity)			//If positive
				{
					if(currentLabel!="Positive")	//And not already playing positive anim
						gotoAndPlay("Positive");	//Play it!
				}
				else						//If negative
				{
					if(currentLabel!="Negative")	//And not already playing negative anim
						gotoAndPlay("Negative");	//Play it!
				}
			}
		}
		
		/*
		 *	update()
		 *
		 *	Applies velocity to position
		 *	Makes sure magnet is set to this position
		 *	Applies gravity
		 *	Caps Max speed
		 *	Tests for player collisions
		 *	Checks for magnet switching
		 *	Runs checkAnimation()
		 *
		 *********************************/
		public function update():void
		{
			
			//Apply velocity
			x+=vx;
			y+=vy;
			
			//Reset magnet
			_magnet.x = x;
			_magnet.y = y-height*.2;		//Slightly higher so that it rests where the magnet should be
			
			vy+=Main.GRAVITY;
			
			//Cap Y velocity
			if(vy > Main.MAX_SPEED)
				vy = Main.MAX_SPEED;
			if(vy < -Main.MAX_SPEED)
				vy = -Main.MAX_SPEED;
			
			_counter++;			//Increase counter
			MovieClip(parent).dronePlayerCollision(this);			//Check for collisions with player
			if(_counter%100 == 0)		//If counter has reached 100
			{
				_counter = 0;			//Set it back to zero
				_magnet.switchPolarity();	//And switch polarity
				
			}
			checkAnimation();		//Finally check animation
		}
	}
}
