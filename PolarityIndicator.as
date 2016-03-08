package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class PolarityIndicator extends MovieClip {
		
		private var velocity:Number;				//Velocity for rotation
		private var maxVelocity:Number;				//Max value for velocity
		private var drag:Number;					//Friction value for velocity
		private var accel:Number;					//Acceleration for velocity
		
		public function PolarityIndicator() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
			
			//Set variables
			velocity = 0;
			maxVelocity = 24;
			drag = .8;
			accel = .2;
		}
		
		private function onAddedToStage(event:Event):void
		{			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	Automatically runs each frame
		 *	Sets velocity
		 * 	Applies velocity to rotation
		 *
		 ***************************/
		public function onEnterFrame(event:Event):void
		{
			if(Main.player.polarity)			//If player is positive
			{				
				if(Math.abs(rotation-180) > .01 || Math.abs(velocity) > .01)		//If this is not rotated correctly and not slow enough
				{
					//Fix it					
					if(rotation < 0)		//If rotation is less than zero
						velocity+=(Math.abs(rotation)-180)*accel;	//Add to velocity
					else 											//Else
						velocity+=-(Math.abs(rotation)-180)*accel;	//Subtract from velocity
						
				}
				else			//If close to being set
				{
					rotation = 180;			//Set rotation
					velocity=0;				//And velocity
				}
			}
			else				//If player is negative
			{
				if(Math.abs(rotation) > .01 || Math.abs(velocity) > .01)		//If not rotated correctly or not slow enough
				{
					if(rotation < 0)			//If rotation is less than zero
						velocity+=(Math.abs(rotation))*accel;	//Add velocity
					else										//else
						velocity-=(Math.abs(rotation))*accel;	//Subtract velocity
				}
				else		//If close to correct rotation and slow enough speed
				{
					rotation = 0;		//Set rotation
					velocity = 0;		//Set velocity
				}
			}
			
			velocity*=drag;				//Simulate friction
			
			//Cap velocity at maxVelocity
			if(velocity>maxVelocity)
				velocity = maxVelocity;
			if(velocity<-maxVelocity)
				velocity = -maxVelocity;
				
			rotation+= velocity;		//Apply velocity to rotation
		}
	}
}
