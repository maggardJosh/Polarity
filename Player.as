package  {
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class Player extends MovieClip {

		public var vx:Number;
		public var vy:Number;
		
		private var jumping:Boolean;			//Used to create a variable jump
		private var jumpFrames:int;				//Max number of frames a jump can be applied
		
		private var playerPolarity:Boolean;			//Polarity of character: True = Positive, False = Negative
		
		public var grounded:Boolean;			//Grounded is true if he is touching the ground (Used to jump)
		public var beingAttracted:Boolean		//If player is being affected by any magnets this is true (Used to test for controls)
		
		public var _collisionArea:MovieClip;	//Collision area of player (Used in collision code)
		
		//Booleans for controls
		private var upKey:Boolean;
		private var leftKey:Boolean;
		private var rightKey:Boolean;
		private var downKey:Boolean;
	
		public var alive:Boolean;					//True if the player is not dead
		public var won:Boolean;						//True if the player won the level
		
		private var positivePablo:PositivePablo;		//Movieclip used for pablo when he is positive
		private var negativePablo:NegativePablo;		//Movieclip used for pable when he is negative
		
		//Counter used to animate smoke trail
		public var smokeTrailCounter:Number;
		
		//Vector used to orient player according to the magnets affecting it per frame
		//(Is updated every frame)
		public var magnetEffectPerFrame:Point;		
		
		public function Player() {
			
			//Initialize variables
			alive = true;
			smokeTrailCounter = 0;
			beingAttracted = false;
			magnetEffectPerFrame = new Point();
			
			positivePablo = new PositivePablo();			//Create a positive pablo
			negativePablo = new NegativePablo();			//Create a negative pablo

			_collisionArea = positivePablo.playerCollisionArea;		//Collision areas are the same so just go ahead and use positivePablo's
			_collisionArea.visible = false;						//Make sure it isn't shown
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/*
		 *	reset()
		 *
		 *	resets:
		 *	position
		 *	polarity
		 *	won and alive variables
		 *	animation
		 ***********************/
		public function reset()
		{
			resetPos();
			polarity = Main.initPolarity;
			won = false;
			alive = true;
			gotoAndStop("idleStart");
		}
		
		/*
		 *
		 *	resetPos()
		 *
		 *	Actually resets players position and velocity
		 * 	to the last spawn point.
		 *************************/
		private function resetPos() {
				x= Main.spawnPoint.x;
				y= Main.spawnPoint.y;
				vx = 0;
				vy = 0;
		}
		
		private function onAddedToStage(event:Event):void
		{
			Main.player = this;			//Set the main.player to this
			polarity = false;			//Set polarity to negative initially
			
			//Initialize variables
			vx = 0;
			vy = 0;	
			
			upKey = false;
			rightKey = false;
			leftKey = false;
			downKey = false;		
			
			grounded = false;
						
			//Add both the pablo's the the levelmanager
			MovieClip(parent).addChild(positivePablo);
			MovieClip(parent).addChild(negativePablo);
			
			MovieClip(parent).addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			MovieClip(parent).addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		/*
		 *	onKeyDown
		 *
		 *	eventListener for key presses
		 *	sets boolean values for arrow keys
		 *	changes polarity on Z being pressed
		 *	restarts at last checkpoint on R being pressed
		 *	reloads level on T being pressed
		 *	switches fullscreen on P being pressed
		 *
		 **************************************/
		 
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(Main.levelManager.paused)		//If paused
				return;							//then do nothing
			if(event.keyCode == Keyboard.LEFT)
				leftKey = true;
				
			if(event.keyCode == Keyboard.RIGHT)
				rightKey = true;
			
			if(event.keyCode == Keyboard.UP)
				upKey = true;
			
			if(event.keyCode == Keyboard.DOWN)
				downKey = true;
				
			if(event.keyCode == Keyboard.R)
				Main.restartLevel();
				
			if(event.keyCode == Keyboard.T)
				Main.reloadLevel();
				
			if(event.keyCode == Keyboard.N)
				Main.nextLevel();

			if(event.keyCode == Keyboard.Z && !MovieClip(parent).paused)
				polarity = !polarity;
				
			if(event.keyCode == Keyboard.F)
				Main.fullscreen = !Main.fullscreen;

		}
		
		/*
		 *	onKeyUp
		 *
		 *	sets booleans for arrow keys to false
		 *
		 ************************************/
		private function onKeyUp(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.LEFT)
				leftKey = false;
			
			if(event.keyCode == Keyboard.RIGHT)
				rightKey = false;
			
			if(event.keyCode == Keyboard.UP)
				upKey = false;
				
			if(event.keyCode == Keyboard.DOWN)
				downKey = false;
		}

		/*
		 *	createSmokeParticles
		 *
		 *	Creates Pablo's smoke from his cigarette
		 *
		 *********************************/
		private function createSmokeParticles()
		{
			var smokeTrailParticle:SmokeTrail = new SmokeTrail();			//Initialize smokeParticle
			var angleToCig:Number = 47.75;			//Angle to cig: 47.75
			var distToCig:Number = 14.8;			//Distance to cig: 14.8
			smokeTrailParticle.x = x+Math.cos((rotation+angleToCig)*Main.PIOVER180)*distToCig;	//Place smokeParticle
			smokeTrailParticle.y = y+Math.sin((rotation+angleToCig)*Main.PIOVER180)*distToCig;
			
			MovieClip(parent).addChild(smokeTrailParticle);			//Add smokeParticle to level
			MovieClip(parent).setChildIndex(smokeTrailParticle, MovieClip(parent).numChildren-1);	//Set it on top of everything
			
			smokeTrailCounter+=.1;			//Increase the smokeTrailCounter to animate smoke
			
			if(smokeTrailCounter>2*3.14)		//If smokeTrailCounter is bigger than 2*3.14 (The period of the cos and sin function)
				smokeTrailCounter -=2*3.14;		//Keep it from getting too big!
		}
		
		/*
		 *	checkAnimation()
		 *
		 *	Tests player and makes sure he is playing appropriate animations
		 *
		 ******************************************/
		private function checkAnimation(player:MovieClip)
		{
			if(!alive)				//If player is dead
			{
				if(player.currentLabel=="endShocked")		//If just finished shocked anim
				{
					Main.restartLevel();					//Restart level at last checkpoint
					alive = true;							//Set alive to true
				}
				else									//If not finished shocked anim
				if(player.currentLabel!="shocked")		//And currently not on it
					player.gotoAndPlay("shocked");		//Goto and play it!
				return;									//Don't do anything else just return!
			}
			if(!beingAttracted && grounded)			//If not affected by magnets and grounded
			{
				if(vx>4 && rightKey)	//If running right and right key is being held down
				{
					player.scaleX = 1;						//Make sure he is facing right
					if(player.currentLabel!="walking")		//If not playing walking anim
					{
						if(player.currentLabel=="endWalking")	//If you have reached the end of the walk animation
							player.gotoAndPlay("walking");		//Loop again
						else							//Otherwise we have not started the walk animation
						if(player.currentLabel!="transWalk")	//So play the transition
							player.gotoAndPlay("transWalk");	//(which will lead straight into the walk animation
					}
				}
				else
				if(vx>4)		//If moving right but not holding down the right key
				{
					player.scaleX = 1;							//Face right
					if(player.currentLabel!="slidingRight")		//If not sliding already
						player.gotoAndPlay("slidingRight");		//Slide right
				}
				else
				if(vx<-4 && leftKey)				//If running left
				{
					player.scaleX = -1;				//Face left
					if(player.currentLabel!="walking")		//If not playing walking anim
					{
						if(player.currentLabel=="endWalking")	//If end of walk
							player.gotoAndPlay("walking");		//Loop walk
						else
						if(player.currentLabel!="transWalk")	//If haven't started walk
							player.gotoAndPlay("transWalk");	//Play transition
					}
				}
				else
				if(vx<-4)		//If moving left but not holding left arrow key
				{
					player.scaleX = 1;						//Face right
					if(player.currentLabel!="slidingLeft")		//If not already playing slide anim
						player.gotoAndPlay("slidingLeft");		//Slide animation
				}
				if(Math.abs(vx) < 4 && player.currentLabel!="idle")		//If barely moving and not playing idle anim
				{
					player.scaleX = 1;					//Face right
					//Use a random number to play the idle animation
					if((int)(Math.random()*60)==1)		//If number 1-60 equals 1
						player.gotoAndPlay("idle");		//Play idle anim
					else								//else
						player.gotoAndStop("idleStart");//Stop on idleStart
				}
			}
			else
			if(beingAttracted)				//If player is being affected by magnet
			{
				player.scaleX = 1;				//Face right
				player.gotoAndPlay("idle");		//play Idle anim
			}
			else		//If in the air and not being affected by a magnet
			{
				if(vx > 0.8)				//If moving right
					player.scaleX = 1;		//Face right
				if(vx < -0.8)				//If moving left
					player.scaleX = -1;		//Face left
				if(vy<0)					//If velocity is moving up
				{
					if(player.currentLabel!="jump")				//If not already in jump anim
					{
						if(player.currentLabel!="transJump")	//If not already in transJump anim
							player.gotoAndPlay("transJump")		//Play it (It will lead into the jump anim
					}
					else					//If in the jump anim
					{
						player.stop();		//Stop in that frame
					}
				}
				if(vy > 0)				//If falling
					player.gotoAndStop("falling");		//Play falling anim
				
			}			
		}
		
		/*
		 *	setRotation
		 *
		 *	Function uses magnetEffectPerFrame to set Pablo's
		 *	rotation if he is being affected by a magnet
		 *
		 ********************************/
		private function setRotation()
		{
			if(beingAttracted)			//If being affected by a magnet
			{
				//Set rotation
				positivePablo.rotation = negativePablo.rotation = ((Math.atan2(magnetEffectPerFrame.y, magnetEffectPerFrame.x)*(180/3.14)+90));	
				grounded = false;		//Also make sure grounded is false
			}
			else		//If not being affected
				positivePablo.rotation = negativePablo.rotation = 0;		//Set rotation to 0
			magnetEffectPerFrame.x = 0;				//Reset magnetEffectPerFrame for next frame
			magnetEffectPerFrame.y = 0;
		}
		
		/*
		 *	checkKeys()
		 *
		 *	Function checks what keys are being pressed
		 *	and reacts accordingly
		 *
		 *************************************/
		private function checkKeys()
		{
			if(leftKey)					//If pressing left
				if(beingAttracted)		//And being affected by a magnet
					vx-=(Main.magnetControlAccel);		//Apply magnet accel
				else					//Else
					vx-=(Main.ACCELERATION);	//Apply normal accel
			
			if(rightKey)				//If pressing right
				if(beingAttracted)		//And in a magnet field
					vx+=(Main.magnetControlAccel);	//Apply magnet accel
				else					//Else
					vx+= Main.ACCELERATION;			//Apply normal accel
					
			if(upKey)					//If pressing up
				if(beingAttracted)		//And in a magnet field
					vy-= Main.magnetControlAccel;	//Apply magnet accel
								//NOTE: Jump happens below

			if(downKey)					//If pressing down
				if(beingAttracted)		//And in magnet field
					vy+= Main.magnetControlAccel;	//Apply magnet accel
				else					//else
					if(grounded)		//If grounded
						Main.camera.vy-=Main.camera.accel;		//Camera looks down
					
			//If up being pressed and grounded and not being affected and not already jumping
			if(upKey&&grounded&&!beingAttracted&&!jumping)		
				{
					//Then start a jump
					grounded = false;			//Set grounded to false
					jumping = true;				//Set jumping to true
					jumpFrames = 1;				//Set jump frames to 1
				}
			if(jumping&&!upKey)			//If up not being pressed and currently jumping
				jumping = false;		//Set jumping to false
			if(jumping)					//If jumping
				if(jumpFrames>Main.maxJumpFrames)	//If can't jump any longer
					jumping = false;			//Set jumping to false
				
			//If pressing up and not being affected and jumping
			if(upKey&&!beingAttracted&&jumping)
			{
				vy-=Main.jumpAccel/jumpFrames;		//Accelerate upward
				jumpFrames++;						//Increase number of frames player has jumped
			}
		}
		
		// capSpeed
		//		Simply caps the max and min speed of player
		private function capSpeed()
		{
			if(Math.abs(vx)<Main.MIN_SPEED)
				vx = 0;
			if(Math.abs(vy)<Main.MIN_SPEED)
				vy = 0;
			//Make sure we are not going to fast in any direction
			if(vx > Main.MAX_SPEED)
				vx = Main.MAX_SPEED;
			if(vx < -Main.MAX_SPEED)
				vx = -Main.MAX_SPEED;
			if(vy > Main.MAX_SPEED)
				vy = Main.MAX_SPEED;
			if(vy < -Main.MAX_SPEED)
				vy = -Main.MAX_SPEED;
		}
		
		//Returns a pablo movieClip (Used for testing)
		public function getPablo():MovieClip
		{
			return negativePablo;
		}
		
		//Make sure Positive and Negative Pablo's are in correct position
		public function updatePNMovieClips()
		{
			positivePablo.x = x;
			positivePablo.y = y;
			negativePablo.x = x;
			negativePablo.y = y;
		}
		
		/*
		 *	update()
		 *
		 *	checkAnimation
		 *	Make sure negative and Positive Pablo are on the same page
		 *	apply velocity
		 *
		 ******************************/
		public function update()
		{
		   checkAnimation(positivePablo);					//Make sure positivePablo is on right frame
		   negativePablo.gotoAndStop(positivePablo.currentFrame);		//Set negative pablo to the same frame
		   negativePablo.scaleX = positivePablo.scaleX;				//Make sure scaleX is the same also
			   
			if(polarity)			//If positive
			{
				
				//Make sure negative is on top for alpha blend effect
			  	MovieClip(parent).setChildIndex(positivePablo, MovieClip(parent).numChildren-1);
				MovieClip(parent).setChildIndex(negativePablo, MovieClip(parent).numChildren-1);
				
					positivePablo.alpha = 1;		//make positive pablo completely visible
				if(negativePablo.alpha>0)			//Fade negative pablo away
					negativePablo.alpha-=.1;
			}
			else				//If negative
			{
				//Make sure positive pablo is on top for alpha blend effect
				MovieClip(parent).setChildIndex(negativePablo, MovieClip(parent).numChildren-1);
				MovieClip(parent).setChildIndex(positivePablo, MovieClip(parent).numChildren-1);
				
				checkAnimation(negativePablo);		//Make sure negativePablo is on right anim
				negativePablo.alpha = 1;			//Make negative pablo completely visible
				if(positivePablo.alpha>0)			//Fade positive pablo away
					positivePablo.alpha-=.1;
			}
			

			if(!alive)			//If dead
				return;			//Stop here
			
			setRotation();			//Set rotation of Pablo
			
			//Add velocity to your position
			x += vx;
			y += vy;

			
			if(!won) 			//If not currently in win anim
			{
				createSmokeParticles();			//create cigarette smoke
				checkKeys();					//Check keys for controls
			}
			else			//If won
				{
					//Set both pablo's to invisible and apply major friction
					positivePablo.alpha = 0;
					negativePablo.alpha = 0;
					vx*=.6;
				}
			
			//Reset beingAttracted to false before running magnet tests
			beingAttracted = false;
			
			if (vy > 0)				//If falling
				grounded=false;		//Definitely not grounded
			
			//If we are moving... Do not apply any friction
			//Note: velocity is multiplied by friction... Therefore a value of '1' equals "No friction".
			if((leftKey&&vx<0)||(rightKey&&vx>0))
				Main._friction = 1;
			else
				Main._friction = Main.FRICTION;
				
			//Add gravity to y velocity
			vy += Main.GRAVITY;

			capSpeed();			//Cap speeds		

			
		}
		
		/*******
		 *
		 *	Getters and Setters for polarity
		 *
		 **********************/
		public function get polarity():Boolean
		{
			return playerPolarity;
		}
		public function set polarity(newPolarity:Boolean):void
		{
			playerPolarity = newPolarity
		}
	}
}
