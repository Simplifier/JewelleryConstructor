package {
	import com.greensock.TweenLite;
	import events.DeleteBtnEvent;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import events.LoadEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	[Event(name="deleteBtnClicked", type="events.DeleteBtnEvent")]
	public class ContentGridCell extends Sprite {
		private var picContainer:Sprite = new Sprite;
		private var border:Shape = new Shape;
		private var loader:Loader = new Loader;
		private var loadIndicator:Sprite;
		private var _deleteBtn:Sprite;
		
		private var _data:ParticleData;
		
		private var _isLoadStarted:Boolean;
		
		public function ContentGridCell(data:ParticleData, width:int, height:int, picWidth:int, picHeight:int, showDeleteBtn:Boolean = false):void {
			_data = data;
			
			buttonMode = true;
			mouseEnabled = false;
			picContainer.mouseEnabled = false;
			picContainer.mouseChildren = false;
			
			graphics.beginFill(0xffffff);
			graphics.drawRoundRect(0, 0, width, height, 10);
			
			border.graphics.lineStyle(1, 0xe8ebed, 1, true);
			border.graphics.drawRoundRect(0, 0, width, height, 10);
			addChild(border);
			
			picContainer.graphics.beginFill(0, 0);
			picContainer.graphics.drawRect(0, 0, picWidth, picHeight);
			picContainer.x = width / 2 - picContainer.width / 2;
			picContainer.y = height / 2 - picContainer.height / 2;
			addChild(picContainer);
			
			if (showDeleteBtn) {
				_deleteBtn = new CloseBtn;
				deleteBtn.scaleX = deleteBtn.scaleY = .95;
				deleteBtn.x = width - deleteBtn.width - 3;
				deleteBtn.y = 3;
				addChild(deleteBtn);
				
				deleteBtn.addEventListener(MouseEvent.ROLL_OVER, onDeleteBtnOver);
				deleteBtn.addEventListener(MouseEvent.ROLL_OUT, onDeleteBtnOut);
				deleteBtn.addEventListener(MouseEvent.CLICK, deleteBtn_clickHandler);
			}
		}
		
		public function load():void {
			var loader:JewServerConnector = new JewServerConnector;
			loader.load('elementImages', {elementID: data.id, photoTypeID: 2}, false, URLLoaderDataFormat.BINARY);
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			loadIndicator.x = width / 2;
			loadIndicator.y = height / 2;
			loadIndicator.scaleX = loadIndicator.scaleY = .7;
			addChild(loadIndicator);
			
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			_isLoadStarted = true;
		}
		
		private function onLoadError(e:IOErrorEvent):void {
			removeChild(loadIndicator);
			loadIndicator = null;
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			loader.loadBytes(ByteArray(e.data));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
		}
		
		private function onParseComplete(e:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onParseComplete);
			removeChild(loadIndicator);
			loadIndicator = null;
			
			mouseEnabled = true;
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
			
			data.bmd = Bitmap(loader.content).bitmapData;
			
			picContainer.addChild(loader);
		}
		
		private function onOver(e:MouseEvent):void {
			TweenLite.to(border, .3, {tint: 0xC9DD02});
		}
		
		private function onOut(e:MouseEvent):void {
			TweenLite.to(border, .7, {removeTint: true});
		}
		
		private function onDeleteBtnOver(e:MouseEvent):void {
			TweenLite.to(deleteBtn, .3, {tint: 0xff7700});
		}
		
		private function onDeleteBtnOut(e:MouseEvent):void {
			TweenLite.to(deleteBtn, .7, {removeTint: true});
		}
		
		private function deleteBtn_clickHandler(e:MouseEvent):void {
			dispatchEvent(new DeleteBtnEvent(DeleteBtnEvent.DELETE_BTN_CLICKED, data.id, true));
		}
		
		public function get isLoadStarted():Boolean {
			return _isLoadStarted;
		}
		
		public function get data():ParticleData {
			return _data;
		}
		
		public function get deleteBtn():Sprite {
			return _deleteBtn;
		}
	}
}