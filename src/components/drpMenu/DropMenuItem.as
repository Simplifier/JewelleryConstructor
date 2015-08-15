package components.drpMenu {
	import com.greensock.TweenLite;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class DropMenuItem extends Sprite {
		private var outBack:Shape = new Shape;
		private var overBack:Shape = new Shape;
		
		private var _label:String;
		private var _data:*;
		private var _isDefault:Boolean;
		private var _width:int;
		
		public function DropMenuItem(label:String, width:int, isDefault:Boolean=false, data:* = null):void {
			_width = width;
			_label = label;
			_data = data;
			_isDefault = isDefault;
			
			setup();
		}
		
		private function setup():void {
			var tformat:TextFormat = new TextFormat;
			var tfield:TextField = new TextField;
			
			tformat.font = 'CharterI';
			tformat.size = 15;
			tfield.defaultTextFormat = tformat;
			//tfield.autoSize = TextFieldAutoSize.LEFT;
			tfield.mouseEnabled = false;
			tfield.embedFonts = true;
			tfield.text = label;
			tfield.width = _width - 40;
			tfield.height = tfield.textHeight;
			tfield.x = 20;
			tfield.y = 2;
			
			outBack.graphics.lineStyle(0, 0xffffff);
			outBack.graphics.beginFill(0xeef1f2);
			outBack.graphics.drawRect(0, 0, _width, tfield.height + 8);
			
			overBack.graphics.beginFill(0xffffff);
			overBack.graphics.drawRect(0, 0, _width, tfield.height + 8);
			overBack.alpha = 0;
			
			addChild(outBack);
			addChild(overBack);
			addChild(tfield);
			
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		private function onOver(e:MouseEvent):void {
			TweenLite.to(overBack, .5, {alpha: 1});
		}
		
		private function onOut(e:MouseEvent):void {
			TweenLite.to(overBack, .5, {alpha: 0});
		}
		
		public function get label():String {
			return _label;
		}
		
		public function get data():* {
			return _data;
		}
		
		public function get isDefault():Boolean {
			return _isDefault;
		}
	}
}