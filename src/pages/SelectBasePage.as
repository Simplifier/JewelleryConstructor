package pages {
	import components.scrollBar.ScrollBar;
	import events.LoadEvent;
	import events.PageEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import models.CoresetData;
	import modWin.DetailsOfBaseWin;
	import serverConnector.JewServerConnector;
	
	public class SelectBasePage extends Sprite {
		private var gallery:ProductsGallery;
		private var modalWins:Object = new Object;
		
		private var _type:String;
		
		public function SelectBasePage(type:String):void {
			_type = type;
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('coresets', {productTypeID: type});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			gallery = new ProductsGallery(e.data, type);
			gallery.x = 38;
			gallery.y = 100;
			addChild(gallery);
			
			var galleryScroller:ScrollBar = new ScrollBar(new BaseScrollBar, gallery, 150, ScrollBar.HORIZONTAL, 750);
			galleryScroller.x = 38;
			galleryScroller.y = gallery.y + gallery.height + 50;
			addChild(galleryScroller);
			
			gallery.addEventListener(MouseEvent.CLICK, onGalleryItemClick);
		}
		
		private function onGalleryItemClick(e:MouseEvent):void {
			var itemData:CoresetData = e.target.data as CoresetData;
			var modalWin:DetailsOfBaseWin = modalWins[itemData.id];
			if (!modalWin)
				modalWin = modalWins[itemData.id] = new DetailsOfBaseWin(itemData);
			modalWin.add();
			
			modalWin.addEventListener(PageEvent.PAGE_CHANGE, dispatchEvent);
		}
		
		public function get type():String {
			return _type;
		}
	}
}