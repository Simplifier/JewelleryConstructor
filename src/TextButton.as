package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextButton extends Sprite {
		private var tfield:TextField = new TextField;
		private var tformat:TextFormat = new TextFormat;
		
		public function TextButton(text:String):void {
			buttonMode = true;
			
			tformat.font = 'CharterI';
			tformat.size = 17;
			//tformat.bold = true;
			//tformat.italic = true;
			tformat.color = 0x738287;
			//tfield.rotation = 10;
			tfield.defaultTextFormat = tformat;
			tfield.mouseEnabled = false;
			tfield.autoSize = TextFieldAutoSize.LEFT;
			tfield.embedFonts = true;
			tfield.text = text;
			addChild(tfield);
		}
	}
}