package events {
	import beadParticles.Particle;
	import flash.events.Event;
	public class ColliderEvent extends Event {
		public static const ELEMENT_ADDED:String = 'elementAdded';
		public static const ELEMENT_REMOVED:String = 'elementRemoved';
		
		public var relatedObject:Particle;
		
		public function ColliderEvent(type:String, relatedObject:Particle, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
			this.relatedObject = relatedObject;
		}
	}
}