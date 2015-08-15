package events {
	import flash.events.Event;
	
	public class TabEvent extends Event {
		private var _index:int;
		private var _id:String;
		public static const SELECT:String = 'select';
		
		public function TabEvent(type:String, index:int, id:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			_id = id;
			_index = index;
			super(type, bubbles, cancelable);
		}
		
		public function get index():int {
			return _index;
		}
		
		public function get id():String {
			return _id;
		}
	}
}