package components.tabbedPnl{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import models.CoresetData;
	
	public class Gallery extends Sprite {
		public function Gallery(sourceData:Object):void {
			var itemXPos:int;
			var data:CoresetData;
			var item:TabGalleryItem;
			for each (var itemData:Object in sourceData) {
				data = new CoresetData(null, itemData.Name, itemData.ID);
				item = new TabGalleryItem(data, itemData.Price, 200, 180, 'builderProductImage', {id: itemData.ID});
				item.x = itemXPos;
				itemXPos += int(item.width) - 1;
				addChild(item);
			}
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, width, height);
		}
	}
}