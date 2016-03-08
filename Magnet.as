package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Magnet extends MovieClip
	{
		
		public var radius:int;					//Magnetic effect radius
		public var magnetStrength:int;			//Magnetic strength
		public var polarity:Boolean;			//False:Negative, True:Positive
		public var _magnetField:MovieClip;		//MovieClip that is a visual indication of the magnetic field
		public var _magnetStream:MovieClip;		//MovieClip that is used as a visual indication of either repelling or attracting a player
		
		public var isOn:Boolean;				//Magnet will not affect player if it is not on
		
		public function Magnet() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		}
		private function onAddedToStage(event:Event):void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			//Create the correct type of Polarity Indication Radius
			if(polarity)							//If positive
			{
				_magnetField = new PositiveRadius;	//Create a positive field MovieClip
				_magnetStream = new PositivePulse;	//Create a positive pulse MovieClip
			}
			else									//If negative
			{
				_magnetField = new NegativeRadius;	//Create a negative field MovieClip
				_magnetStream = new NegativePulse;	//Create a negative pulse MovieClip
			}
			
			isOn = true;								//Initially magnet is on
			MovieClip(parent).addChild(_magnetField);	//Add the magnetField MovieClip to LevelManager
			MovieClip(parent).addChild(_magnetStream);	//Add the magnetStream MovieClip to LevelManager
			_magnetStream.alpha = 0;					//Set magnetStream alpha to Zero
			_magnetField.x = x;						//Set x to the x position of the Magnet
			_magnetField.y = y;						//Set y to the y position of the Magnet
			_magnetField.stop();						//Stop the magnetField animation
			
		}
		
		/*
		 *	switchPolarity()
		 *
		 *	Function used by drones to switch their polarity
		 *	Simply changes the polarity variable and 
		 *	changes the _magnetStream and _magnetField symbols
		 *	
		 *******************/
		public function switchPolarity():void
		{
			polarity = !polarity;
			
			MovieClip(parent).removeChild(_magnetField);
			MovieClip(parent).removeChild(_magnetStream);
			//Create the correct type of Polarity Indication Radius
			if(polarity)							//If positive
			{
				_magnetField = new PositiveRadius;	//Create a positive field MovieClip
				_magnetStream = new PositivePulse;	//Create a positive pulse MovieClip
			}
			else									//If negative
			{
				_magnetField = new NegativeRadius;	//Create a negative field MovieClip
				_magnetStream = new NegativePulse;	//Create a negative pulse MovieClip
			}
			
			
			MovieClip(parent).addChild(_magnetField);	//Add the magnetField MovieClip to LevelManager
			MovieClip(parent).addChild(_magnetStream);	//Add the magnetStream MovieClip to LevelManager
			
			_magnetStream.alpha = 0;				//Set alpha to 0 so there is no sudden change
			_magnetField.x = x;						//Set x to the x position of the Magnet
			_magnetField.y = y;						//Set y to the y position of the Magnet
			_magnetField.stop();						//Stop the magnetField animation
			
			
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			MovieClip(parent).removeChild(_magnetField);
			MovieClip(parent).removeChild(_magnetStream);
		}
				
		/*
		 *	onEnterFrame()
		 *
		 *	Runs on the entry of every frame
		 *	Updates the _magnetField and _magnetStream position
		 *	Also checks for affect on player
		 *
		 *********************/
		private function onEnterFrame(event:Event):void
		{
			if(_magnetField.width!=Main.BULLET_MAGNET_RADIUS*2)
			{
				_magnetField.width = Main.magnetRadius*2;			//Set magnetField WIDTH to the actual diameter of the magnet force
				_magnetField.height = Main.magnetRadius*2;			//Set magnetField HEIGHT to the actual diameter of the magnet force
			}
			
			//Set magnetField and Stream position to this magnet's position
			_magnetField.x = x;
			_magnetField.y = y;
			
			_magnetStream.x =x;
			_magnetStream.y =y;
			
			MovieClip(parent).checkMagneticFieldWithPlayer(this);	//On each frame check for player collisions and Magnetic effect.
			
		}
	}
}