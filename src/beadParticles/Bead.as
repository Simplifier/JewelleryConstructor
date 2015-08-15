package beadParticles{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import models.ParticleData;
	
	public class Bead extends Particle implements DynamicBead {
		private var _acceleration:Number = 0.6;
		private var lastSpeeds:Vector.<Number> = new Vector.<Number>;
		private var lastPosition:Point = new Point;
		
		public function Bead(particleData:ParticleData):void {
			super(particleData);
			/*graphics.beginFill(0x99CCFF, .7);
			graphics.drawCircle(0, 0, 25);*/
			//_radius = 27;
		}
		
		override public function initAngle(angle:Number):void {
			super.initAngle(angle);
			
			if (angle > 0 && angle < 180)
				acceleration = -Math.abs(acceleration);
			else
				acceleration = Math.abs(acceleration);
		/*if (normalizeAngle(angle) > 90 && normalizeAngle(angle) < 270)
		   acceleration = -Math.abs(acceleration);
		 else acceleration = Math.abs(acceleration);*/
		}
		
		public function suppressShivering():int {
			lastSpeeds.push(angle-prevAngle);
			if (lastSpeeds.length > 10) lastSpeeds.shift();
			
			var totalSpeed:Number = 0;
			var lastSpeed:Number;
			var changeCount:int;
			for each(var speed:Number in lastSpeeds) {
				totalSpeed += speed;
				if (lastSpeed * speed < 0) changeCount++;
				lastSpeed = speed;
			}
			var avgSpeed:Number = Math.abs(totalSpeed / lastSpeeds.length);
			//trace(avgSpeed, changeCount, Math.abs(velocity), lastSpeeds.length)
			if (changeCount > 1 && avgSpeed < .1 && Math.abs(angle-prevAngle) < .3 && lastSpeeds.length == 10) {
				angle = prevAngle;
				x = getLastPosition().x;
				y = getLastPosition().y;
				rotation = angle;
				velocity = 0;
				//lastSpeeds[lastSpeeds.length - 1] = 0;
			}
			return changeCount;
		}
		
		public function setLastPosition(x:Number, y:Number):void {
			lastPosition.x = x;
			lastPosition.y = y;
		}
		
		public function getLastPosition():Point {
			return lastPosition;
		}
		
		private function normalizeAngle(degAngle:Number):Number {
			var res:Number = degAngle % 360;
			if (res < 0)
				res += 360;
			return res;
		}
		
		public function set velocity(value:Number):void {
			_velocity = value;
		}
		
		public function set velocityBeforeExchange(value:Number):void {
			_velocityBeforeExchange = value;
		}
		
		public function get acceleration():Number {
			return _acceleration;
		}
		
		public function set acceleration(value:Number):void {
			_acceleration = value;
		}
		
		public function set prevAngle(value:Number):void {
			_prevAngle = value;
		}
		
		override public function toString():String {
			return '[' + velocity + ', ' + angle + ']';
		}
	}
}