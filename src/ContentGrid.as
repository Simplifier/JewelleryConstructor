package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import models.ParticleData;
	
	public class ContentGrid extends Sprite {
		private var items:Vector.<ContentGridCell> = new Vector.<ContentGridCell>;
		
		private var _cellsAmount:int;
		private var _rowCount:int;
		private var _columnCount:int;
		private var _cellWidth:Number = 71;
		private var _cellHeight:Number = 71;
		private var _horCellIndent:Number = 5;
		private var _vertCellIndent:Number = 5;
		
		public function ContentGrid(sourceData:Object, elementsType:String, rowCount:int, columnCount:int, showDeleteBtn:Boolean = false):void {
			_rowCount = rowCount;
			_columnCount = columnCount;
			
			var itemXPos:int;
			var itemYPos:int;
			var itemNum:int;
			var item:ContentGridCell;
			var data:ParticleData;
			for each (var itemData:Object in sourceData) {
				data = new ParticleData(itemData.Name, itemData.Price, itemData.ID, elementsType, itemData.Article, itemData.RealWidth, itemData.IsTransp, itemData.CenterFromTop);
				item = new ContentGridCell(data, cellWidth - 1, cellHeight - 1, cellWidth - 11, cellHeight - 11, showDeleteBtn);
				item.x = itemXPos;
				item.y = itemYPos;
				itemXPos += int(item.width) + horCellIndent;
				if ((itemNum + 1) % columnCount == 0) {
					itemXPos = 0;
					itemYPos += int(item.height) + vertCellIndent;
				}
				itemNum++;
				addChild(item);
				items.push(item);
			}
			_cellsAmount = itemNum - 1;
			
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, columnCount * (cellWidth + horCellIndent - 1), (height)?height:10);
		}
		
		public function loadCell(cellIndex:int):void {
			if (!items[cellIndex].isLoadStarted)
				items[cellIndex].load();
		}
		
		public function destroy():void {
		
		}
		
		public function get rowCount():int {
			return _rowCount;
		}
		
		public function get columnCount():int {
			return _columnCount;
		}
		
		public function get cellWidth():Number {
			return _cellWidth;
		}
		
		public function get cellHeight():Number {
			return _cellHeight;
		}
		
		public function get horCellIndent():Number {
			return _horCellIndent;
		}
		
		public function get vertCellIndent():Number {
			return _vertCellIndent;
		}
		
		public function get cellsAmount():int {
			return _cellsAmount;
		}
	}
}