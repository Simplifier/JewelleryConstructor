package {
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import events.LoadEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import models.CoresetData;
	import serverConnector.JewServerConnector;
	
	public class GalleryItem extends Sprite {
		private var picContainer:Sprite = new Sprite;
		private var selectingBorder:Sprite = new Sprite;
		private var loadIndicator:Sprite;
		
		private var _data:CoresetData;
		
		public function GalleryItem(data:CoresetData, picWidth:int, picHeight:int, imageLoadMethod:String = null, imageLoadParams:Object = null):void {
			_data = data;
			
			buttonMode = true;
			mouseChildren = false;
			
			picContainer.graphics.beginFill(0, 0);
			picContainer.graphics.drawRect(0, 0, picWidth, picHeight);
			addChild(picContainer);
			
			selectingBorder.graphics.lineStyle(1, 0xaaaaaa, 1, true);
			selectingBorder.graphics.drawRoundRect(0, 0, picWidth, picHeight, 10);
			selectingBorder.alpha = 0;
			addChild(selectingBorder);
			
			var tformat:TextFormat = new TextFormat;
			tformat.font = 'CharterI';
			tformat.size = 15;
			//tformat.bold = true;
			//tformat.italic = true;
			tformat.color = 0x7F8388;
			tformat.align = TextFieldAutoSize.CENTER;
			var tfield:TextField = new TextField;
			tfield.defaultTextFormat = tformat;
			tfield.autoSize = TextFieldAutoSize.CENTER;
			tfield.mouseEnabled = false;
			tfield.embedFonts = true;
			tfield.wordWrap = true;
			tfield.text = data.name;
			tfield.width = picWidth;
			tfield.y = picContainer.height + 10;
			addChild(tfield);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			loadIndicator.x = picContainer.width / 2;
			loadIndicator.y = picContainer.height / 2;
			loadIndicator.scaleX = loadIndicator.scaleY = .8;
			picContainer.addChild(loadIndicator);
			
			var loader:JewServerConnector = new JewServerConnector;
			if (imageLoadMethod) {
				loader.load(imageLoadMethod, imageLoadParams, false, URLLoaderDataFormat.BINARY);
			} else {
				loader.load('elementImages', {elementID: data.id, photoTypeID: 2}, false, URLLoaderDataFormat.BINARY);
			}
			
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		private function onLoadError(e:IOErrorEvent):void {
			picContainer.removeChild(loadIndicator);
			loadIndicator = null;
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			picContainer.removeChild(loadIndicator);
			loadIndicator = null;
			
			var loader:Loader = new Loader;
			loader.loadBytes(ByteArray(e.data));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
		}
		
		private function onParseComplete(e:Event):void {
			var loader:Loader = e.target.loader as Loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onParseComplete);
			if (loader.width > picContainer.width - 2 || loader.height > picContainer.height - 2) {
				if (loader.width / (picContainer.width - 2) > loader.height / (picContainer.height - 2)) {
					loader.width = picContainer.width - 2;
					loader.scaleY = loader.scaleX;
				} else {
					loader.height = picContainer.height - 2;
					loader.scaleX = loader.scaleY;
				}
			}
			loader.x = picContainer.width / 2 - loader.width / 2;
			loader.y = picContainer.height / 2 - loader.height / 2;
			Bitmap(loader.content).smoothing = true;
			
			picContainer.addChild(loader);
		}
		
		private function onMouseOver(e:Event):void {
			TweenLite.to(selectingBorder, .5, {alpha: 1});
		}
		
		private function onMouseOut(e:Event):void {
			TweenLite.to(selectingBorder, .8, {alpha: 0});
		}
		
		public function get data():CoresetData {
			return _data;
		}
	}
}