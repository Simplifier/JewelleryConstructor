package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import models.CoresetData;
	
	public class ProductsGallery extends Sprite {
		public function ProductsGallery(sourceData:Object, productType:String = null, imageLoadMethod:String = null, imageLoadParams:Object = null):void {
			var itemXPos:int;
			var data:CoresetData;
			var item:GalleryItem;
			for each (var itemData:Object in sourceData) {
				data = new CoresetData(productType, itemData.Name, itemData.ID);
				item = new GalleryItem(data, 200, 180, imageLoadMethod, imageLoadParams);
				item.x = itemXPos;
				itemXPos += int(item.width) - 1;
				addChild(item);
			}
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, width, height);
		}
	}
}