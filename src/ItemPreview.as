package {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import events.LoadEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import serverConnector.JewServerConnector;
	
	public class ItemPreview extends Sprite {
		private var picContainer:Sprite = new Sprite;
		private var _id:String;
		private var loadIndicator:Sprite;
		
		public function ItemPreview(id:String, width:int, height:int, picWidth:int, picHeight:int):void {
			_id = id;
			
			graphics.lineStyle(1, 0x8da0a6, 1, true);
			graphics.drawRoundRect(0, 0, width, height, 14);
			
			picContainer.graphics.beginFill(0, 0);
			picContainer.graphics.drawRect(0, 0, picWidth, picHeight);
			picContainer.x = width / 2 - picContainer.width / 2;
			picContainer.y = height / 2 - picContainer.height / 2;
			addChild(picContainer);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			loadIndicator.x = width / 2;
			loadIndicator.y = height / 2;
			loadIndicator.scaleX = loadIndicator.scaleY = .8;
			addChild(loadIndicator);
			
			var loader:JewServerConnector = new JewServerConnector;
			loader.load('elementImages', {elementID: id, photoTypeID:3}, false, URLLoaderDataFormat.BINARY);
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			var loader:Loader = new Loader;
			loader.loadBytes(ByteArray(e.data));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
		}
		
		private function onParseComplete(e:Event):void {
			removeChild(loadIndicator);
			loadIndicator = null;
			
			var loader:Loader = e.target.loader as Loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onParseComplete);
			if (loader.width > picContainer.width || loader.height > picContainer.height) {
				if (loader.width / picContainer.width > loader.height / picContainer.height) {
					loader.width = picContainer.width;
					loader.scaleY = loader.scaleX;
				} else {
					loader.height = picContainer.height;
					loader.scaleX = loader.scaleY;
				}
			}
			loader.x = picContainer.width / 2 - loader.width / 2;
			loader.y = picContainer.height / 2 - loader.height / 2;
			Bitmap(loader.content).smoothing = true;
			
			picContainer.addChild(loader);
		}
		
		public function get id():String {
			return _id;
		}
	}
}