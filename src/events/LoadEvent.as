package events {
	import flash.events.Event;
	public class LoadEvent extends Event {
		public static const LOAD_COMPLETE:String = 'loadComplete';
		public static const UPLOAD_COMPLETE:String = 'uploadComplete';
		
		public var data:Object;
		
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
		}
	}
}