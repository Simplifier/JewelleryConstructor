package events{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ScrollBarEvent extends Event {
		private var _scrollingPosition:Number;
		private var _relatedObject:DisplayObject;
		
		public static const SCROLL:String = 'scroll';
		
		public function ScrollBarEvent(type:String, scrollingPosition:Number, relatedObject:DisplayObject, bubbles:Boolean = false, cancelable:Boolean = false):void {
			_scrollingPosition = scrollingPosition;
			_relatedObject = relatedObject;
			super(type, bubbles, cancelable);
		}
		
		public function get scrollingPosition():Number {
			return _scrollingPosition;
		}
		
		public function get relatedObject():DisplayObject {
			return _relatedObject;
		}
	}
}