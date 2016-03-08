package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class CheckPoint extends MovieClip {
		
		public var _collisionArea:MovieClip;		//Collision area for checkPoint
		public function CheckPoint() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_collisionArea = this;								//Set collision area
			MovieClip(parent).checkPointList.push(this);			//Add this to the checkPointList
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			MovieClip(parent).checkPointList.splice(this, 1);		//If we are removed from level Actually remove us from the list
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	checkAnimation()
		 *
		 *	checksAnimation and makes sure they loop properly
		 *
		 ******************************/
		private function checkAnimation()
		{
			if(currentLabel == "setEnd")	//If at the end of the set animation
				gotoAndPlay("set");			//Loop it
				
			if(currentLabel == "idleEnd")	//If at the end of the idle animation
				gotoAndPlay("idle");		//Loop it
		}
		
		private function onEnterFrame(event:Event):void
		{
			checkAnimation();				//Check the animation
			
			if(MovieClip(parent) != null)					//If we have a parent
				MovieClip(parent).checkCheckPoints(this);		//On each frame check for player collisions.
		}
	}
}