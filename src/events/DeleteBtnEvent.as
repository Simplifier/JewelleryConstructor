package events {
	import flash.events.Event;
	
	public class DeleteBtnEvent extends Event {
		private var _id:String;
		public static const DELETE_BTN_CLICKED:String = 'deleteBtnClicked';
		
		public function DeleteBtnEvent(type:String, id:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			_id = id;
			super(type, bubbles, cancelable);
		}
		
		public function get id():String {
			return _id;
		}
	}
}