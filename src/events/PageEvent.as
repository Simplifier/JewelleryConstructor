package events {
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import models.CoresetData;
	import models.ParticleData;
	
	public class PageEvent extends Event {
		private static var _page:String;
		private static var _fromPage:String;
		
		public var coresetData:CoresetData;
		public var particlesData:Vector.<ParticleData> = new Vector.<ParticleData>;
		public var productName:String;
		
		public static const PAGE_CHANGE:String = 'pageChange';
		
		public function PageEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String {
			return formatToString(getQualifiedClassName(this), 'type', 'bubbles', 'cancelable', 'eventPhase', 'page', 'fromPage', 'coresetData', 'particlesData', 'productName');
		}
		
		override public function clone():Event {
			var e:PageEvent = new PageEvent(type, bubbles, cancelable);
			e.coresetData = coresetData;
			e.particlesData = particlesData;
			e.productName = productName;
			return e;
		}
		
		public function get page():String {
			return _page;
		}
		
		public function set page(value:String):void {
			_fromPage = _page;
			_page = value;
		}
		
		public function get fromPage():String {
			return _fromPage;
		}
	}
}