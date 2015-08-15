package colliders{
	import beadParticles.Bead;
	import beadParticles.Lock;
	import beadParticles.Particle;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import models.CoresetData;
	import models.ParticleData;
	
	[Event(name="elementRemoved", type="events.ColliderEvent")]
	[Event(name="elementAdded", type="events.ColliderEvent")]
	public class Collider extends Sprite {
		public var realWidth:int;
		protected var _coresetData:CoresetData;
		protected var shiftPressed:Boolean;
		
		public function Collider(coresetData:CoresetData):void {
			_coresetData = coresetData;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if(e.shiftKey)shiftPressed = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if(!e.shiftKey)shiftPressed = false;
		}
		
		public function addBeadHandling(bead:Bead):void {
			throw new IllegalOperationError('override me');
		}
		
		public function addLockHandling(lock:Lock):void {
			throw new IllegalOperationError('override me');
		}
		
		public function threadBead(bead:Bead, parameter:Number = NaN):void {
			throw new IllegalOperationError('override me');
		}
		
		public function threadLock(lock:Lock, parameter:Number = NaN):void {
			throw new IllegalOperationError('override me');
		}
		
		public function releaseParticle(particle:Particle, particleIsSnapped:Boolean):void {
			throw new IllegalOperationError('override me');
		}
		
		public function destroy():void {
			throw new IllegalOperationError('override me');
		}
		
		public function get particlesData():Vector.<ParticleData> {
			throw new IllegalOperationError('override me');
		}
		
		public function get coresetData():CoresetData {
			return _coresetData;
		}
	}
}