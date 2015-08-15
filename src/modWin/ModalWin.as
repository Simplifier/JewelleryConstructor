package modWin {
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ModalWin extends Sprite {
		private var closeBtn:Sprite = new CloseBtn;
		private var blindLayer:Sprite = new Sprite;
		private var _stage:Stage;
		private static var container:DisplayObjectContainer;
		protected var centerByDefaultSize:Boolean;
		protected var win:Sprite = new Sprite;
		
		public function ModalWin(width:int, height:int, centerByDefaultSize:Boolean = true):void {
			if (!container) throw new IllegalOperationError('The ModalWin class must be inited. Calls the init() method at first');
			
			this.centerByDefaultSize = centerByDefaultSize;
			_stage = container.stage;
			
			win.graphics.beginFill(0xffffff);
			win.graphics.drawRoundRect(0, 0, width, height, 10);
			
			closeBtn.buttonMode = true;
			closeBtn.x = width - closeBtn.width - 7;
			closeBtn.y = 7;
			
			super.addChild(blindLayer);
			super.addChild(win);
			addChild(closeBtn);
			
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseBtnClick);
			blindLayer.addEventListener(MouseEvent.CLICK, onCloseBtnClick);
			
			closeBtn.addEventListener(MouseEvent.ROLL_OVER, onCloseBtnOver);
			closeBtn.addEventListener(MouseEvent.ROLL_OUT, onCloseBtnOut);
		}
		
		public static function init(container:DisplayObjectContainer):void {
			ModalWin.container = container;
			
		}
		
		private function onCloseBtnClick(e:MouseEvent):void {
			remove();
		}
		
		private function onCloseBtnOver(e:MouseEvent):void {
			TweenLite.to(closeBtn, .3, {tint: 0});
		}
		
		private function onCloseBtnOut(e:MouseEvent):void {
			TweenLite.to(closeBtn, .7, {removeTint: true});
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			return win.addChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			return win.removeChild(child);
		}
		
		public function add():void {
			blindLayer.graphics.clear();
			blindLayer.graphics.beginFill(0, .5);
			blindLayer.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			if (centerByDefaultSize) {
				win.x = int(827 / 2 - win.width / 2);
				win.y = int(600 / 2 - win.height / 2);
			}else {
				win.x = int(_stage.stageWidth / 2 - win.width / 2);
				win.y = int(_stage.stageHeight / 2 - win.height / 2);
			}
			container.addChild(this);
		}
		
		protected function resize(width:int, height:int, centerByDefaultSize:Boolean = true):void {
			blindLayer.graphics.clear();
			blindLayer.graphics.beginFill(0, .5);
			blindLayer.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			win.graphics.clear();
			win.graphics.beginFill(0xffffff);
			win.graphics.drawRoundRect(0, 0, width, height, 10);
			if (centerByDefaultSize) {
				win.x = int(827 / 2 - win.width / 2);
				win.y = int(600 / 2 - win.height / 2);
			}else {
				win.x = int(_stage.stageWidth / 2 - win.width / 2);
				win.y = int(_stage.stageHeight / 2 - win.height / 2);
			}
		}
		
		public function destroy():void {
			closeBtn.removeEventListener(MouseEvent.CLICK, onCloseBtnClick);
			blindLayer.removeEventListener(MouseEvent.CLICK, onCloseBtnClick);
			
			closeBtn.removeEventListener(MouseEvent.ROLL_OVER, onCloseBtnOver);
			closeBtn.removeEventListener(MouseEvent.ROLL_OUT, onCloseBtnOut);
		}
		
		public function remove():void {
			if (parent)
				parent.removeChild(this);
		}
		
		public function get stageSize():Rectangle {
			return new Rectangle(0, 0, container.stage.stageWidth, container.stage.stageHeight);
		}
	}
}