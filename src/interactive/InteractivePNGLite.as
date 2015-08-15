package interactive {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class InteractivePNGLite extends Sprite {
		private var basePoint:Point = new Point;
		private var mousePoint:Point = new Point;
		private var activeArea:Sprite = new Sprite;
		private var bmp:Bitmap;
		
		private var _alphaTolerance:uint = 128;
		private var _exactShape:Boolean;
		
		public function InteractivePNGLite() {
			activeArea.mouseEnabled = false;
			activeArea.visible = false;
			addChildAt(activeArea, 0);
			
			//addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, int.MAX_VALUE);
			//addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			//addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		}
		
		public function setBitmap(bmp:Bitmap):void {
			if (this.bmp) removeChild(this.bmp);
			this.bmp = bmp;
			addChild(bmp);
			
			var rect:Rectangle = calcBounds(bmp);
			//trace(rect);
			
			activeArea.graphics.clear();
			activeArea.graphics.beginFill(0);
			activeArea.graphics.drawRect(0, 0, rect.width, rect.height);
			activeArea.x = rect.x;
			activeArea.y = rect.y;
			hitArea = activeArea;
		}
		
		private function calcBounds(bmp:Bitmap):Rectangle {
			var copy:BitmapData = new BitmapData(bmp.width, bmp.height, true, 0);
			var m:Matrix = bmp.transform.matrix;
			m.tx = 0;
			m.ty = 0;
			copy.draw(bmp, m);
			//trace(111, bmp.width, bmp.height)
			
			var rect:Rectangle = new Rectangle(copy.width, copy.height, 0, 0);
			for (var i:int = 0; i < copy.width; i++) {
				for (var j:int = 0; j < copy.height; j++) {
					if (copy.getPixel32(i, j) != 0) {
						if (i < rect.x)
							rect.x = i;
						if (i > rect.width)
							rect.width = i;
						
						if (j < rect.y)
							rect.y = j;
						if (j > rect.height)
							rect.height = j;
					}
				}
			}
			rect.width -= rect.x;
			rect.height -= rect.y;
			rect.x += bmp.x;
			rect.y += bmp.y;
			
			return rect;
		}
		
		private function shapeHitTest():Boolean {
			if ((activeArea.mouseX >= 0 && activeArea.mouseX <= activeArea.width) || (activeArea.mouseY >= 0 && activeArea.mouseY <= activeArea.height)) {
				return true;
			} else {
				return false;
			}
		}
		
		private function bitmapHitTest():Boolean {
			if (!bmp)
				return false;
			mousePoint.x = bmp.mouseX;
			mousePoint.y = bmp.mouseY;
			return bmp.bitmapData.hitTest(basePoint, alphaTolerance, mousePoint);
		}
		
		private function rollOverHandler(e:MouseEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if (bitmapHitTest()) {
				mouseEnabled = true;
			} else {
				mouseEnabled = false;
			}
		}
		
		private function enterFrameHandler(e:Event):void {
			if (!shapeHitTest()) {
				mouseEnabled = true;
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				return;
			}
			
			if (bitmapHitTest()) {
				mouseEnabled = true;
			} else {
				mouseEnabled = false;
			}
		}
		
		private function mouseDownHandler(e:MouseEvent):void {
			if (!bitmapHitTest()) {
				e.stopImmediatePropagation();
			}
		}
		
		public function get alphaTolerance():uint {
			return _alphaTolerance;
		}
		
		public function set alphaTolerance(value:uint):void {
			_alphaTolerance = Math.min(255, value);
		}
		
		public function get exactShape():Boolean {
			return _exactShape;
		}
		
		public function set exactShape(value:Boolean):void {
			_exactShape = value;
			if (value) {
				addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, int.MAX_VALUE);
			} else {
				removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			}
		}
	}
}