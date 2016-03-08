package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Demagnetizer extends MovieClip {
		
		public var _collisionArea:MovieClip;
		public function Demagnetizer() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_collisionArea = this;						//Set collision area
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
			//On each frame check for player collisions.
			MovieClip(parent).checkDemagnetizer(this);		//Check for collisions with player
		}
	}
}
