package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class LevelEnd extends MovieClip {
		
		public var _collisionArea:MovieClip;	
		public function LevelEnd() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_collisionArea = this;		//Set collision area
			stop();						//Stop animation on first frame ("idleStart")
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	checkAnimation()
		 *
		 *	checks animation of Napolean
		 *
		 ***************************************/
		private function checkAnimation()
		{
			if(currentLabel=="endWin")			//If just got done playing win animation
			{
				if(Main.levelManager.currentLabel=="credits")	//If we have just beat the credits
				{
					Main.levelManager.nextFrame();				//Clear level
					Main.levelManager.gotoAndStop(1);			//Goto the start screen
					Main.nextLevel();						//Goto level One
					return;									//return (Do nothing else)
				}
				Main.nextLevel();						//If we haven't beat the credits go to next level
				return;									//Return (Do nothing else)
			}
			if(currentLabel == "idleStart")				//If we are stopped on the "idleStart" frame
			{
				if((int)(Math.random()*40)==1)			//If random number 1-40 equals 1
					gotoAndPlay("idle");				//Play idle animation
			}
			if(currentLabel == "idleEnd")				//If we have reached the end of the idle animation
				gotoAndStop("idleStart");				//Goto the idleStart frame
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(MovieClip(parent) != null)					//If we have a parent
				MovieClip(parent).checkLevelEnd(this);		//Check for player collisions.
			
			checkAnimation();								//Check animation
			
		}
	}
}