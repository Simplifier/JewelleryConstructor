package pages {
	import components.scrollBar.ScrollBar;
	import components.tabbedPnl.TabbedPanel;
	import events.LoadEvent;
	import events.PageEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import models.CoresetData;
	import modWin.TableWin;
	import serverConnector.JewServerConnector;
	
	public class StartPage extends Sprite {
		public var selectBraceletBtn:Sprite;
		public var selectNecklaceBtn:Sprite;
		public var selectEarringBtn:Sprite;
		
		public var showOrderedBtn:Sprite;
		public var showConstructedByMeBtn:Sprite;
		public var showConstructedBySomeonesBtn:Sprite;
		public var showRandomIdeaBtn:Sprite;
		
		private var orderedWin:TableWin;
		private var constructedByMeWin:TableWin;
		
		private var _stage:Stage;
		
		public function StartPage():void {
			selectBraceletBtn.buttonMode = true;
			selectNecklaceBtn.buttonMode = true;
			selectEarringBtn.buttonMode = true;
			showOrderedBtn.buttonMode = true;
			showConstructedByMeBtn.buttonMode = true;
			showConstructedBySomeonesBtn.buttonMode = true;
			showRandomIdeaBtn.buttonMode = true;
			
			//скроем пока
			selectNecklaceBtn.visible = false;
			selectEarringBtn.visible = false;
			showConstructedBySomeonesBtn.visible = false;
			showRandomIdeaBtn.visible = false;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_stage = stage;
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProductPage');
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onTabsLoadComplete);
			
			selectBraceletBtn.addEventListener(MouseEvent.CLICK, selectBraceletBtn_clickHandler);
			selectNecklaceBtn.addEventListener(MouseEvent.CLICK, selectNecklaceBtn_clickHandler);
			selectEarringBtn.addEventListener(MouseEvent.CLICK, selectEarringBtn_clickHandler);
			
			showOrderedBtn.addEventListener(MouseEvent.CLICK, showOrderedBtn_clickHandler);
			showConstructedByMeBtn.addEventListener(MouseEvent.CLICK, showConstructedByMeBtn_clickHandler);
		}
		
		public function resetProductsData():void {
			if (orderedWin) {
				orderedWin.removeEventListener(PageEvent.PAGE_CHANGE, dispatchEvent);
				orderedWin.destroy();
				orderedWin = null;
			}
			if (constructedByMeWin) {
				constructedByMeWin.destroy();
				constructedByMeWin = null;
			}
		}
		
		private function onTabsLoadComplete(e:LoadEvent):void {
			var tpan:TabbedPanel = new TabbedPanel(e.data as Array, _stage.stageWidth);
			tpan.y = 255;
			addChild(tpan);
		}
		
		private function selectBraceletBtn_clickHandler(e:MouseEvent):void {
			var event:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE);
			event.page = PagesLayer.SELECT_BASE_PAGE;
			event.coresetData = new CoresetData(PagesLayer.BRACELET);
			dispatchEvent(event);
		}
		
		private function selectNecklaceBtn_clickHandler(e:MouseEvent):void {
			var event:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE);
			event.page = PagesLayer.SELECT_BASE_PAGE;
			event.coresetData = new CoresetData(PagesLayer.NECKLACE);
			dispatchEvent(event);
		}
		
		private function selectEarringBtn_clickHandler(e:MouseEvent):void {
			var event:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE);
			event.page = PagesLayer.SELECT_BASE_PAGE;
			event.coresetData = new CoresetData(PagesLayer.EARRING);
			dispatchEvent(event);
		}
		
		private function showOrderedBtn_clickHandler(e:MouseEvent):void {
			if (orderedWin) {
				orderedWin.add();
				return;
			}
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProduct', {clientID: JewelleryConstructor.flashVars.viewer_id, actionTypeID: 2});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onOrderedDataLoadComplete);
		}
		
		private function onOrderedDataLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onOrderedDataLoadComplete);
			
			orderedWin = new TableWin(e.data as Array, 'Заказанные мной');
			orderedWin.addEventListener(PageEvent.PAGE_CHANGE, dispatchEvent);
			orderedWin.add();
		}
		
		private function showConstructedByMeBtn_clickHandler(e:MouseEvent):void {
			if (constructedByMeWin) {
				constructedByMeWin.add();
				return;
			}
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProduct', {clientID: JewelleryConstructor.flashVars.viewer_id, actionTypeID: 1});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onConstructedByMeComplete);
		}
		
		private function onConstructedByMeComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onConstructedByMeComplete);
			constructedByMeWin = new TableWin(e.data as Array, 'Собранные мной');
			constructedByMeWin.addEventListener(PageEvent.PAGE_CHANGE, dispatchEvent);
			constructedByMeWin.add();
		}
	}
}