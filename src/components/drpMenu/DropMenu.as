package components.drpMenu {
	import com.greensock.TweenLite;
	import components.scrollBar.ScrollBar;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class DropMenu extends Sprite {
		public var promptField:TextField;
		public var box:MovieClip;
		
		private var listContainer:Sprite = new Sprite;
		private var list:Sprite = new Sprite;
		private var listBorder:Shape = new Shape;
		private var listMasker:Shape = new Shape;
		private var scroller:ScrollBar;
		
		private var isOpened:Boolean;
		
		private var _stage:Stage;
		
		private var _selectedData:*;
		
		private var _prompt:String;
		private var rowCount:int;
		private var _width:int;
		private var items:Array;
		
		public var id:String;
		
		public function DropMenu(items:Array, width:int, prompt:String = '', rowCount:int = 5):void {
			this.items = items;
			_width = width;
			_prompt = prompt;
			this.rowCount = rowCount;
			buttonMode = true;
			
			setup();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_stage = stage;
		}
		
		private function setup():void {
			box.width = _width;
			
			var tformat:TextFormat = promptField.getTextFormat();
			tformat.font = 'CharterI';
			promptField.defaultTextFormat = tformat;
			//promptField.autoSize = TextFieldAutoSize.LEFT;
			promptField.mouseEnabled = false;
			promptField.text = prompt;
			promptField.width = _width - 50;
			promptField.height = promptField.textHeight;
			
			listContainer.graphics.beginFill(0xeef1f2);
			listContainer.graphics.drawRect(0, 0, _width, 10);
			listContainer.y = box.height - 10;
			listContainer.alpha = 0;
			
			list.y = 10;
			
			var itemYPos:int = 0;
			for each (var itemData:* in items) {
				var item:DropMenuItem;
				if (itemData is String) {
					item = new DropMenuItem(itemData, _width);
				} else {
					item = new DropMenuItem(itemData.label, _width, itemData.isDefault, itemData.data);
				}
				item.y = itemYPos;
				itemYPos += item.height;
				list.addChild(item);
				
				item.addEventListener(MouseEvent.CLICK, item_clickHandler);
			}
			
			listBorder.graphics.lineStyle(1, 0x8DA0A6, 1, true);
			listBorder.graphics.drawRoundRect(0, 0, _width - 1, list.height + 10, 12);
			
			listMasker.graphics.beginFill(0);
			listMasker.graphics.drawRoundRect(0, 0, _width, list.height + 10, 12);
			list.mask = listMasker;
			
			listContainer.addChild(list);
			listContainer.addChild(listMasker);
			listContainer.addChild(listBorder);
			
			if (list.height - 10 > rowCount * item.height) {
				listMasker.graphics.clear();
				listMasker.graphics.beginFill(0);
				listMasker.graphics.drawRoundRect(0, 0, _width, rowCount * item.height + 10, 12);
				list.mask = listMasker;
				
				var scrollerMasker:Shape = new Shape;
				scrollerMasker.graphics.beginFill(0);
				scrollerMasker.graphics.drawRoundRect(0, 0, _width, rowCount * item.height + 10, 12);
				list.mask = scrollerMasker;
				listContainer.addChild(scrollerMasker);
				
				scroller = new ScrollBar(new DropMenuScrollBar, list, 20, ScrollBar.VERTICAL, rowCount * item.height, true, rowCount * item.height, true, .3);
				scroller.x = list.width - scroller.width;
				scroller.y = 10;
				scroller.mask = listMasker;
				listContainer.addChild(scroller);
				
				listBorder.graphics.clear();
				listBorder.graphics.lineStyle(1, 0x8DA0A6, 1, true);
				listBorder.graphics.drawRoundRect(0, 0, _width - 1, rowCount * item.height + 10, 12);
				
			}
			
			addChild(box);
			addChild(promptField);
			
			box.addEventListener(MouseEvent.CLICK, box_clickHandler);
		}
		
		private function item_clickHandler(e:MouseEvent):void {
			var item:DropMenuItem = e.target as DropMenuItem;
			if (item.data)
				_selectedData = item.data;
			else
				_selectedData = item.label;
			
			if (promptField.text == item.label)
				return;
			
			if (item.isDefault) {
				promptField.text = prompt;
			}else {
				promptField.text = item.label;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function box_clickHandler(e:MouseEvent):void {
			if (!isOpened) {
				e.stopPropagation();
				open();
			}
		}
		
		public function open():void {
			//listContainer.visible = true;
			if (!contains(listContainer))
				addChildAt(listContainer, 0);
			TweenLite.to(listContainer, .3, {alpha: 1});
			_stage.addEventListener(MouseEvent.CLICK, close);
			isOpened = true;
		}
		
		public function close(e:MouseEvent = null):void {
			if (scroller && scroller.contains(e.target as DisplayObject))
				return;
			if (!isOpened)
				return;
			
			//listContainer.visible = false;
			TweenLite.to(listContainer, .3, {alpha: 0, onComplete: removeChild, onCompleteParams: [listContainer]});
			_stage.removeEventListener(MouseEvent.CLICK, close);
			isOpened = false;
		}
		
		public function get selectedData():* {
			return _selectedData;
		}
		
		public function get prompt():String {
			return _prompt;
		}
	}
}