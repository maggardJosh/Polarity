package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Wall extends MovieClip {
		
		public var _collisionArea:MovieClip;
		public function Wall() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_collisionArea = this;
			Main.levelManager.wallList.push(this);			//Add to wall List
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			var wallList:Array = Main.levelManager.wallList;			//Get wall list
			wallList.splice(wallList.indexOf(this), 1);					//Remove from wall list
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		//Update
		//	Checks collisions with players, drones, and bullets
		public function update():void
		{
			//Player collision
			MovieClip(parent).checkCollisionWithPlayer(this);
			
			//Drone collision
			for(var x:int = 0; x< Main.levelManager.droneList.length; x++)
				Main.levelManager.checkCollisionWithDrone(Main.levelManager.droneList[x], this);
			
			//Bullet collision
			for(x = 0; x <Main.levelManager.turretList.length; x++)
				Main.levelManager.checkBulletCollision_WALL(Main.levelManager.turretList[x].bullet, this);
		}
	}
}
