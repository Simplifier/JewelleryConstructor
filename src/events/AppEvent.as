package events {
	import flash.events.Event;
	
	public class AppEvent extends Event {
		private var _newHeight:int;
		public static const APP_RESIZE:String = 'appResize';
		
		public function AppEvent(type:String, newHeight:int, bubbles:Boolean = false, cancelable:Boolean = false):void {
			_newHeight = newHeight;
			super(type, bubbles, cancelable);
		}
		
		public function get newHeight():int {
			return _newHeight;
		}
	}
}