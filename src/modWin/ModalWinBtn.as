package modWin {
	import com.greensock.TweenLite;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class ModalWinBtn extends Sprite {
		private var _enabled:Boolean = true;
		private var _highlighted:Boolean;
		
		private var tformat:TextFormat = new TextFormat;
		private var tfield:TextField = new TextField;
		private var back:Shape = new Shape;
		
		public function ModalWinBtn(label:String, enabled:Boolean = true, highlighted:Boolean = false):void {
			buttonMode = true;
			this.enabled = enabled;
			this.highlighted = highlighted;
			
			tformat.font = 'CharterI';
			tformat.size = 15;
			//tformat.bold = true;
			//tformat.italic = true;
			tformat.color = 0xffffff;
			tfield.defaultTextFormat = tformat;
			tfield.autoSize = TextFieldAutoSize.LEFT;
			tfield.mouseEnabled = false;
			tfield.embedFonts = true;
			tfield.text = label;
			//tfield.filters = [new GlowFilter(0,.3,2,2,1,3)];
			tfield.x = 13;
			tfield.y = 2;
			
			back.graphics.beginFill(0x8DA0A6);
			back.graphics.drawRoundRect(0, 0, int(tfield.width + 26), int(tfield.height + 5), 5);
			
			addChild(back);
			addChild(tfield);
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			if (enabled == value)
				return;
			
			_enabled = value;
			if (value) {
				buttonMode = true;
				//back.alpha = 1;
				TweenLite.to(back, .5, {alpha: 1});
			} else {
				buttonMode = false;
				//back.alpha = .4;
				TweenLite.to(back, .5, {alpha: .5});
			}
		}
		
		public function get highlighted():Boolean {
			return _highlighted;
		}
		
		public function set highlighted(value:Boolean):void {
			if (highlighted == value)
				return;
			
			_highlighted = value;
			if (value) {
				TweenLite.to(back, .5, {tint: 0xC9DD02, overwrite:false});
			} else {
				TweenLite.to(back, .5, {removeTint: true, overwrite:false});
			}
		}
	}
}