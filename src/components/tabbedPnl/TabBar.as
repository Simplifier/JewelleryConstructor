package components.tabbedPnl{
	import events.TabEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TabBar extends Sprite {
		private var titles:Vector.<String>;
		
		private var tabs:Vector.<Tab> = new Vector.<Tab>;
		private var selectedTab:Sprite;
		private var tabCap:Sprite = new TabCap;
		private var tabGraphics:Sprite = new Sprite;
		
		private var tformat:TextFormat = new TextFormat;
		private var _width:Number;
		
		public function TabBar(titles:Vector.<String>, width:int = 0, indentFirstTab:int = 10, ids:Vector.<String> = null, indexOfSelected:int = 0):void {
			this.titles = titles;
			if (indexOfSelected < 0)
				indexOfSelected = 0;
			else if (indexOfSelected > titles.length + 1)
				indexOfSelected = titles.length + 1;
			
			tabGraphics.mouseEnabled = false;
			addChild(tabGraphics);
			tabGraphics.addChild(tabCap);
			
			tformat.font = 'CharterI';
			tformat.size = 15;
			//tformat.bold = true;
			//tformat.italic = true;
			tformat.color = 0x7F8388;
			
			var tabXPos:int = indentFirstTab;
			for (var i:String in titles) {
				var tfield:TextField = createTfield(titles[i]);
				tfield.x = 12;
				
				var tab:Tab = new Tab;
				if(ids)tab.id = ids[i];
				tab.index = int(i);
				tab.buttonMode = true;
				tab.graphics.beginFill(0, 0);
				tab.graphics.drawRect(0, 0, tfield.width + 24, tfield.height + 2);
				tab.x = tabXPos;
				tab.y = 1;
				tabXPos += tab.width + 2;
				
				tabs.push(tab);
				
				addChild(tab);
				tab.addChild(tfield);
				
				tab.addEventListener(MouseEvent.CLICK, tab_clickHandler);
			}
			_width = Math.max(width, tab.x + tab.width + 10);
			selectTab(tabs[indexOfSelected]);
		}
		
		private function tab_clickHandler(e:MouseEvent):void {
			selectTab(e.target as Sprite);
			dispatchEvent(new TabEvent(TabEvent.SELECT, e.target.index, e.target.id));
		}
		
		private function createTfield(text:String):TextField {
			var tfield:TextField = new TextField;
			tfield.defaultTextFormat = tformat;
			tfield.mouseEnabled = false;
			tfield.autoSize = TextFieldAutoSize.LEFT;
			tfield.embedFonts = true;
			tfield.text = text;
			
			return tfield;
		}
		
		private function selectTab(tab:Sprite):void {
			if (selectedTab == tab)
				return;
			
			tabGraphics.graphics.clear();
			tabGraphics.graphics.lineStyle(1, 0x7F8388);
			tabGraphics.graphics.moveTo(0, tab.height);
			tabGraphics.graphics.lineTo(tab.x - 9, tab.height);
			tabGraphics.graphics.moveTo(tab.x + tab.width + 9, tab.height);
			tabGraphics.graphics.lineTo(_width, tab.height);
			
			tabCap.width = tab.width + 20;
			tabCap.height = tab.height + 1;
			tabCap.x = tab.x - 10;
			selectedTab = tab;
		}
		
		public function get quantity():int {
			return tabs.length;
		}
	}
}

import flash.display.Sprite;

class Tab extends Sprite {
	public var index:int;
	public var id:String;
}