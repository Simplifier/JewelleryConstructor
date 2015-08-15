package {
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class NavigationBtn extends Sprite {
		private var activeSkin:DisplayObject;
		private var inactiveSkin:DisplayObject;
		private var tfield:TextField = new TextField;
		private var tformat:TextFormat = new TextFormat;
		
		public function NavigationBtn(activeSkin:DisplayObject, inactiveSkin:DisplayObject, label:String, labelXPosition:int):void {
			this.activeSkin = activeSkin;
			this.inactiveSkin = inactiveSkin;
			buttonMode = true;
			
			addChild(activeSkin);
			addChild(inactiveSkin);
			addChild(tfield);
			
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
			tfield.text = label;
			tfield.x = labelXPosition;
			tfield.y = int(height / 2 - tfield.height / 2);
		}
		
		public function set selected(value:Boolean):void {
			if (value) {
				activeSkin.visible = true;
				inactiveSkin.visible = false;
				tformat.color = 0xffffff;
				tfield.setTextFormat(tformat);
			}else {
				activeSkin.visible = false;
				inactiveSkin.visible = true;
				tformat.color = 0x738287;
				tfield.setTextFormat(tformat);
			}
		}
	}
}