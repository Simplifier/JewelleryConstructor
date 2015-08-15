package modWin {
	import flash.display.Sprite;
	import flash.display.Stage;
	import events.LoadEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import serverConnector.JewServerConnector;
	
	[Event(name="threadBeadClick", type="modWin.DetailsOfBeadWin")]
	[Event(name="favBtnClick", type="modWin.DetailsOfBeadWin")]
	public class DetailsOfBeadWin extends ModalWin {
		private var id:String;
		private var type:String;
		
		private var tformat:TextFormat = new TextFormat;
		private var titleField:TextField = new TextField;
		private var descrField:TextField = new TextField;
		private var numField:TextField = new TextField;
		private var priceField:TextField = new TextField;
		private var favField:TextField = new TextField;
		
		private var threadBeadBtn:ModalWinBtn = new ModalWinBtn('» Добавить на основу', true);
		private var favBtn:Sprite = new Sprite;
		
		public static const TREAD_BEAD_CLICK:String = 'threadBeadClick';
		public static const FAV_BTN_CLICK:String = "favBtnClick";
		
		public function DetailsOfBeadWin(type:String, id:String):void {
			this.type = type;
			this.id = id;
			super(700, 400);
			
			tformat.font = 'CharterI';
			tformat.size = 20;
			//tformat.bold = true;
			//tformat.italic = true;
			
			titleField.defaultTextFormat = tformat;
			titleField.embedFonts = true;
			titleField.width = 295;
			titleField.height = 30;
			titleField.x = 380;
			titleField.y = 20;
			
			tformat.size = 15;
			
			descrField.defaultTextFormat = tformat;
			//descrField.autoSize = TextFieldAutoSize.LEFT;
			descrField.embedFonts = true;
			descrField.multiline = true;
			descrField.wordWrap = true;
			descrField.width = 295;
			descrField.height = 100;
			descrField.x = 380;
			
			numField.defaultTextFormat = tformat;
			numField.autoSize = TextFieldAutoSize.LEFT;
			numField.mouseEnabled = false;
			numField.embedFonts = true;
			numField.width = 300;
			numField.x = 380;
			
			tformat.size = 18;
			
			priceField.defaultTextFormat = tformat;
			priceField.autoSize = TextFieldAutoSize.LEFT;
			priceField.mouseEnabled = false;
			priceField.embedFonts = true;
			priceField.width = 300;
			priceField.x = 380;
			
			var favicon:Sprite = new FavIcon;
			
			tformat.size = 15;
			
			favField.defaultTextFormat = tformat;
			favField.autoSize = TextFieldAutoSize.LEFT;
			favField.mouseEnabled = false;
			favField.embedFonts = true;
			favField.text = 'Добавить в избранные';
			favField.x = favicon.width + 3;
			
			win.addChild(threadBeadBtn);
			
			win.addChild(titleField);
			win.addChild(descrField);
			win.addChild(numField);
			win.addChild(priceField);
			
			favBtn.addChild(favicon);
			favBtn.addChild(favField);
			win.addChild(favBtn);
			
			favBtn.graphics.beginFill(0, 0);
			favBtn.graphics.drawRect(0, 0, favBtn.width, favBtn.height);
			favBtn.buttonMode = true;
			favBtn.x = 380;
			favBtn.y = int(370 - favBtn.height);
			
			threadBeadBtn.x = 380;
			threadBeadBtn.y = int(favBtn.y - threadBeadBtn.height - 15);
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('elementInfo', {elementID: id});
			
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			threadBeadBtn.addEventListener(MouseEvent.CLICK, threadBeadBtn_clickHandler);
			threadBeadBtn.addEventListener(MouseEvent.ROLL_OVER, threadBeadBtn_overHandler);
			threadBeadBtn.addEventListener(MouseEvent.ROLL_OUT, threadBeadBtn_outHandler);
			favBtn.addEventListener(MouseEvent.CLICK, favBtn_clickHandler);
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			var pic:ItemPreview = new ItemPreview(id, 350, 350, 300, 300);
			pic.x = 20;
			pic.y = 20;
			win.addChild(pic);
			
			titleField.text = e.data.Name;
			descrField.text = e.data.Description;
			numField.text = 'Артикул ' + e.data.Article;
			priceField.text = e.data.Price + ' руб.';
			descrField.y = int(titleField.y + titleField.height + 5);
			numField.y = int(descrField.y + descrField.height + 20);
			priceField.y = int(numField.y + numField.height + 10);
		}
		
		private function favBtn_clickHandler(e:MouseEvent):void {
			remove();
			dispatchEvent(new Event(FAV_BTN_CLICK));
		}
		
		private function threadBeadBtn_clickHandler(e:MouseEvent):void {
			remove();
			dispatchEvent(new Event(TREAD_BEAD_CLICK));
		}
		
		private function threadBeadBtn_overHandler(e:MouseEvent):void {
			threadBeadBtn.highlighted = true;
		}
		
		private function threadBeadBtn_outHandler(e:MouseEvent):void {
			threadBeadBtn.highlighted = false;
		}
	}
}