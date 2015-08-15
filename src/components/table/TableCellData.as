package components.table {
	import flash.display.DisplayObject;
	import flash.text.TextFormatAlign;
	
	public class TableCellData {
		public var width:int;
		public var text:String;
		public var align:String;
		public var image:DisplayObject;
		public var length:int;
		
		public function TableCellData(text:String = null, width:int = -1, image:DisplayObject = null, align:String = 'left', length:int = 1):void {
			this.length = length;
			this.text = text;
			this.image = image;
			this.align = align;
			this.width = width;
			
			if (text && image)
				throw new ArgumentError('Передавайте только текст или только изображение в ячейку');
		}
	}
}