package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class SmokeTrail extends MovieClip {
		
		var initPos:Point;
		var counter:Number;
		public function SmokeTrail() 
		{
			alpha = .3;		//Start off with a barely visible alpha
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			initPos = new Point(x,y);			//Set initial position on added to stage
			counter = 0;						//Reset counter
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onEnterFrame(event:Event):void
		{
			MovieClip(parent).setChildIndex(this, MovieClip(parent).numChildren-1);		//Set on top of everything
			counter+=.1;			//Increase counter
			
			if(alpha <= 0)								//If completely invisible
				MovieClip(parent).removeChild(this);	//Remove this
			else						//Else
				{
					alpha -= .003;		//Slowly fade
					y -= 1.0;			//Increase height
					
					//Calculate x using cos
					x = initPos.x + (((Math.cos(Main.player.smokeTrailCounter + (y-initPos.y)/10)))*(y-initPos.y)*.2);
				}
		}
	}
}
