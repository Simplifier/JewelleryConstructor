package modWin {
	import beadParticles.DeadSpace;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import components.drpMenu.DropMenu;
	import events.PageEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import events.LoadEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import models.CoresetData;
	import models.DeadSpaceData;
	import serverConnector.JewServerConnector;
	
	public class DetailsOfBaseWin extends ModalWin {
		private var coresetData:CoresetData;
		
		private var tformat:TextFormat = new TextFormat;
		private var titleField:TextField = new TextField;
		private var descrField:TextField = new TextField;
		private var checkField:TextField = new TextField;
		
		private var dontBuyBase:Boolean;
		private var checkBox:MovieClip = new CheckBox;
		private var checkBoxContainer:Sprite = new Sprite;
		
		private var dropMenu:DropMenu;
		private var confirmBtn:ModalWinBtn = new ModalWinBtn('» Выбрать основу и продолжить', false);
		
		public function DetailsOfBaseWin(coresetData:CoresetData):void {
			this.coresetData = coresetData;
			super(700, 400);
			
			tformat.font = 'CharterI';
			tformat.size = 20;
			//tformat.bold = true;
			//tformat.italic = true;
			
			titleField.defaultTextFormat = tformat;
			//titleField.mouseEnabled = false;
			titleField.embedFonts = true;
			titleField.text = coresetData.name;
			titleField.width = 295;
			titleField.height = 30;
			titleField.x = 380;
			titleField.y = 20;
			
			tformat.size = 15;
			
			descrField.defaultTextFormat = tformat;
			//descrField.autoSize = TextFieldAutoSize.LEFT;
			//descrField.mouseEnabled = false;
			descrField.embedFonts = true;
			descrField.multiline = true;
			descrField.wordWrap = true;
			descrField.width = 295;
			descrField.height = 100;
			descrField.x = 380;
			descrField.y = int(titleField.y + titleField.height + 5);
			
			checkBoxContainer.buttonMode = true;
			checkBoxContainer.x = 380;
			checkBoxContainer.y = 220;
			
			checkField.defaultTextFormat = tformat;
			checkField.autoSize = TextFieldAutoSize.LEFT;
			checkField.mouseEnabled = false;
			checkField.embedFonts = true;
			checkField.multiline = true;
			checkField.wordWrap = true;
			checkField.text = 'Я не хочу покупать данную основу и буду использовать ее лишь для подбора необходимых мне бусин и замков.';
			checkField.width = 275;
			checkField.height = 70;
			checkField.x = 20;
			
			confirmBtn.x = 380;
			confirmBtn.y = int(370 - confirmBtn.height);
			
			addChild(checkBoxContainer);
			checkBoxContainer.addChild(checkBox);
			checkBoxContainer.addChild(checkField);
			win.addChild(confirmBtn);
			
			win.addChild(titleField);
			win.addChild(descrField);
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('coresetinfo', {coresetid: coresetData.id});
			
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			checkBoxContainer.addEventListener(MouseEvent.CLICK, checkBoxContainer_clickHandler);
			confirmBtn.addEventListener(MouseEvent.CLICK, confirmBtn_clickHandler);
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			var pic:ItemPreview = new ItemPreview(coresetData.id, 350, 350, 300, 300);
			pic.x = 20;
			pic.y = 20;
			win.addChild(pic);
			
			descrField.text = e.data.Description;
			coresetData.majorRadius = e.data.Math.MajorRadius;
			coresetData.minorRadius = e.data.Math.MinorRadius;
			coresetData.straightHeight = e.data.Math.StraightHeight;
			for each(var deadSpace:Object in e.data.Math.DeadSpaces) {
				coresetData.deadSpaces.push(new DeadSpaceData(deadSpace.Width, deadSpace.Parameter));
			}
			
			var menuData:Array = [];
			for each(var item:Object in e.data.CoresetLenghts) {
				menuData.push( { label:item.Name, data:{id:item.ID, size:item.Name, price:item.Price, article:item.Article}} );
			}
			dropMenu = new DropMenu(menuData, 295, 'Выберите длину основы');
			dropMenu.x = 380;
			dropMenu.y = int(descrField.y + descrField.height + 20);
			win.addChild(dropMenu);
			dropMenu.addEventListener(Event.CHANGE, dropMenu_changeHandler);
		}
		
		private function checkBoxContainer_clickHandler(e:MouseEvent):void {
			if (dontBuyBase)
				checkBox.gotoAndStop('off');
			else
				checkBox.gotoAndStop('on');
			dontBuyBase = !dontBuyBase;
		}
		
		private function confirmBtn_clickHandler(e:MouseEvent):void {
			if (!confirmBtn.enabled) TweenLite.to(dropMenu, 1.2, { glowFilter: { color:0xff00cc, alpha:1, blurX:6, blurY:6, remove:true, quality:3 }, ease:Elastic.easeInOut } );
			else {
				remove();
				
				var pgEvent:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE);
				pgEvent.page = PagesLayer.BEADS_PAGE;
				coresetData.size = dropMenu.selectedData.size;
				coresetData.price = dropMenu.selectedData.price;
				coresetData.article = dropMenu.selectedData.article;
				coresetData.dontBuyBase = dontBuyBase;
				pgEvent.coresetData = coresetData;
				dispatchEvent(pgEvent);
			}
		}
		
		private function dropMenu_changeHandler(e:Event):void {
			confirmBtn.enabled = true;
			confirmBtn.highlighted = true;
		}
	}
}