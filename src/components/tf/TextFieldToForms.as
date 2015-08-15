package components.tf {
	import com.greensock.TweenLite;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	[Event(name="change", type="flash.events.Event")]
	public class TextFieldToForms extends Sprite {
		private var _border:Shape = new Shape;
		private var _tfield:TextField = new TextField;
		private var hintfield:TextField;
		private var focusIsCaptured:Boolean;
		
		public function TextFieldToForms(width:int, height:int = 0, hint:String = null):void {
			var tformat:TextFormat = new TextFormat;
			tformat.font = 'Charter';
			tformat.size = 18;
			
			tfield.defaultTextFormat = tformat;
			tfield.type = TextFieldType.INPUT;
			tfield.embedFonts = true;
			tfield.width = width - 8;
			if (height) {
				tfield.height = height - 4;
				tfield.multiline = true;
				tfield.wordWrap = true;
			} else {
				tfield.text = 'A';
				tfield.height = tfield.textHeight + 5;
				tfield.text = '';
			}
			tfield.x = 4;
			tfield.y = 2;
			
			if (hint) {
				tformat.font = 'CharterI';
				tformat.color = 0xbbbbbb;
				
				hintfield = new TextField;
				hintfield.defaultTextFormat = tformat;
				hintfield.multiline = tfield.multiline;
				hintfield.wordWrap = tfield.wordWrap;
				hintfield.mouseEnabled = false;
				hintfield.embedFonts = true;
				hintfield.text = hint;
				hintfield.width = tfield.width;
				hintfield.height = tfield.height;
				hintfield.x = 4;
				hintfield.y = 2;
				
				tfield.addEventListener(Event.CHANGE, dispatchEvent);
				addEventListener(Event.CHANGE, onTextChange);
			}
			
			var back:Shape = new Shape;
			back.graphics.beginFill(0xffffff);
			back.graphics.drawRoundRect(0, 0, tfield.width + 8, tfield.height + 4, 10);
			
			border.graphics.lineStyle(1, 0xc8cbcd, 1, true);
			border.graphics.drawRoundRect(0, 0, tfield.width + 8, tfield.height + 4, 10);
			
			addChild(back);
			addChild(border);
			if (hintfield)
				addChild(hintfield);
			addChild(tfield);
			
			if (stage) addedToStageHandler();
			else addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(e:Event=null):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(MouseEvent.CLICK, onBackGroundClick, true);
			addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
		}
		
		private function focusInHandler(e:FocusEvent):void {
			if (!focusIsCaptured) TweenLite.to(border, .3, { tint: 0xC9DD02 } );
			focusIsCaptured = true;
		}
		
		private function focusOutHandler(e:FocusEvent):void {
			if (focusIsCaptured) TweenLite.to(border, .3, { removeTint: true } );
			focusIsCaptured = false;
		}
		
		private function onTextChange(e:Event):void {
			if (tfield.text == '') {
				hintfield.visible = true;
			} else {
				hintfield.visible = false;
			}
		}
		
		private function onClick(e:MouseEvent):void {
			if (focusIsCaptured) return;
			
			focusIsCaptured = true;
			stage.focus = tfield;
			TweenLite.to(border, .3, { tint: 0xC9DD02 } );
		}
		
		private function onBackGroundClick(e:MouseEvent):void {
			if (focusIsCaptured) TweenLite.to(border, .3, { removeTint: true } );
			focusIsCaptured = false;
		}
		
		public function captureFocus(focusManager:Stage = null):void {
			if (!focusManager) focusManager = this.stage;
			if (!focusManager) return;
			
			focusIsCaptured = true;
			focusManager.focus = tfield;
			//tfield.setSelection(0, 0);
			TweenLite.to(border, .3, {tint: 0xC9DD02});
		}
		
		public function get border():Shape {
			return _border;
		}
		
		public function get tfield():TextField {
			return _tfield;
		}
		
		public function set text(value:String):void {
			tfield.text = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get text():String {
			return tfield.text;
		}
	}
}