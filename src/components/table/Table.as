package components.table {
	import com.greensock.TweenLite;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Table extends Sprite {
		private var columnsAmount:int;
		private var columnWidths:Vector.<int> = new Vector.<int>;
		private var _rows:Vector.<TableRow> = new Vector.<TableRow>;
		
		public function Table(headData:Vector.<TableCellData>, minHeight:int = 0):void {
			columnsAmount = headData.length;
			
			var textContainer:Sprite = new Sprite;
			
			var back:Sprite = new Sprite;
			back.graphics.beginFill(0x8da0a6);
			
			var tf:TextField;
			var cellIndent:int;
			for each (var cellData:TableCellData in headData) {
				columnWidths.push(cellData.width);
				
				tf = createText(cellData.text, cellData.width - 10, 0xffffff, cellData.align, false);
				tf.x = cellIndent + 6;
				textContainer.addChild(tf);
				
				cellIndent += tf.width + 10;
			}
			
			var rowheight:int = Math.max(minHeight, textContainer.height);
			textContainer.y = (rowheight - textContainer.height) / 2;
			back.graphics.drawRoundRectComplex(0, 0, cellIndent, rowheight, 0, 0, 0, 0);
			
			back.graphics.lineStyle(1, 0xffffff, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			cellIndent = 0;
			for (var i:int; i < columnWidths.length - 1; i++) {
				cellIndent += columnWidths[i];
				back.graphics.moveTo(cellIndent, 0);
				back.graphics.lineTo(cellIndent, rowheight);
			}
			back.addChild(textContainer);
			addChild(back);
		}
		
		public function createText(htmlText:String, width:int = -1, color:uint = 0, align:String = TextFormatAlign.LEFT, multiline:Boolean = true):TextField {
			var tfield:TextField = new TextField;
			var tformat:TextFormat = new TextFormat;
			
			tformat.align = align;
			
			tfield.defaultTextFormat = tformat;
			//tfield.selectable = false;
			
			if (multiline) {
				tfield.multiline = true;
				tfield.wordWrap = true;
			}
			
			tfield.embedFonts = true;
			tfield.htmlText = htmlText;
			
			if (width < 0)
				tfield.autoSize = TextFieldAutoSize.LEFT;
			else {
				tfield.width = width;
				tfield.height = tfield.textHeight + 5;
			}
			
			return tfield;
		}
		
		public function addRow(rowData:Vector.<TableCellData>, minHeight:int = -1, indent:uint = 0 /*in cells*/, backColor:uint = 0xffffff, backAlpha:Number = 1, reactOnOver:Boolean = false):TableRow {
			var row:TableRow = new TableRow;
			row.graphics.beginFill(backColor, backAlpha);
			row.y = height;
			addChild(row);
			if (reactOnOver) {
				row.alpha = .6;
				row.addEventListener(MouseEvent.ROLL_OVER, onRowOver);
				row.addEventListener(MouseEvent.ROLL_OUT, onRowOut);
			}
			
			row.x = computeFirstCellIndent(indent, columnWidths);
			var widthsForUnitedCells:Vector.<int> = computeWidthsForUnitedCells(indent, columnWidths, rowData);
			
			var content:Vector.<DisplayObject> = addContent(rowData, row, widthsForUnitedCells, minHeight);
			
			var rowheight:int = Math.max(minHeight, row.height);
			var rowwidth:uint;
			for each(var unitedCellWidth:uint in widthsForUnitedCells) {
				rowwidth += unitedCellWidth;
			}
			row.graphics.drawRect(0, 0, rowwidth, rowheight);
			
			row.graphics.lineStyle(1, 0x8da0a6, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			row.graphics.moveTo(0, 0);
			row.graphics.lineTo(0, rowheight);
			
			alignContentByHeight(content, rowheight);
			drawDividingLines(widthsForUnitedCells, content, rowheight, row);
			
			row.fields = content;
			_rows.push(row);
			return row;
		}
		
		private function computeFirstCellIndent(indent:uint, columnWidths:Vector.<int>):int {
			var res:int;
			for (var i:int = 0; i < indent; i++) {
				res += columnWidths[i];
			}
			return res;
		}
		
		private function computeWidthsForUnitedCells(indent:uint, columnWidths:Vector.<int>, rowData:Vector.<TableCellData>):Vector.<int> {
			var cellIndex:uint;
			var widthsForUnitedCells:Vector.<int> = new Vector.<int>;
			
			for (var i:int = indent; i < columnWidths.length; i++) {
				var unitedCellWidth:uint = columnWidths[i];
				var j:int = i;
				i++;
				
				for (i; i < j + rowData[cellIndex].length; i++) {
					unitedCellWidth += columnWidths[i];
				}
				widthsForUnitedCells.push(unitedCellWidth);
				i--;
				cellIndex++;
			}
			return widthsForUnitedCells;
		}
		
		private function addContent(rowData:Vector.<TableCellData>, row:TableRow, widthsForUnitedCells:Vector.<int>, minHeight:int):Vector.<DisplayObject> {
			var content:Vector.<DisplayObject> = new Vector.<DisplayObject>;
			var cellIndent:int;
			
			for (var i:String in widthsForUnitedCells) {
				var unitedCellWidth:uint = widthsForUnitedCells[i];
				
				if (rowData[i].image) {
					var image:DisplayObject = rowData[i].image;
					resizeImage(image, unitedCellWidth - 8, minHeight - 4);
					image.x = cellIndent + unitedCellWidth / 2 - image.width / 2;
					row.addChild(image);
					content.push(image);
				} else if (rowData[i].text) {
					var tf:TextField = createText(rowData[i].text, unitedCellWidth - 10, 0, rowData[i].align);
					tf.x = cellIndent + 5;
					content.push(row.addChild(tf));
				} else {
					content.push(null);
				}
				cellIndent += unitedCellWidth;
			}
			return content;
		}
		
		private function alignContentByHeight(content:Vector.<DisplayObject>, rowheight:int):void {
			for each(var img:DisplayObject in content ) {
				if (img) {
					img.y = rowheight / 2 - img.height / 2;
				}
			}
		}
		
		private function drawDividingLines(widthsForUnitedCells:Vector.<int>, content:Vector.<DisplayObject>, rowheight:int, row:TableRow):void {
			var cellIndent:int;
			
			for (var i:int; i < content.length; i++) {
				cellIndent += widthsForUnitedCells[i];
				
				if (i == content.length - 1) {
					row.graphics.moveTo(cellIndent - 1, 0);
					row.graphics.lineTo(cellIndent - 1, rowheight);
				} else {
					row.graphics.moveTo(cellIndent, 0);
					row.graphics.lineTo(cellIndent, rowheight);
				}
			}
			row.graphics.moveTo(0, rowheight);
			row.graphics.lineTo(cellIndent, rowheight);
		}
		
		private function onRowOver(e:MouseEvent):void {
			TweenLite.to(e.target, .5, {alpha: 1});
		}
		
		private function onRowOut(e:MouseEvent):void {
			TweenLite.to(e.target, .5, {alpha: .6});
		}
		
		private function resizeImage(img:DisplayObject, maxWidth:Number, maxHeight:Number):void {
			if (img.width > maxWidth || img.height > maxHeight) {
				if (img.width / maxWidth > img.height / maxHeight) {
					img.width = maxWidth;
					img.scaleY = img.scaleX;
				} else {
					img.height = maxHeight;
					img.scaleX = img.scaleY;
				}
			}
		}
		
		public function get rows():Vector.<TableRow> {
			return _rows;
		}
	}
}