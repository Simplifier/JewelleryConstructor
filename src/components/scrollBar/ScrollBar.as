package components.scrollBar {
	import com.greensock.TweenLite;
	import events.ScrollBarEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import ru.etcs.ui.MouseWheel;
	
	[Event(name="scroll", type="events.ScrollBarEvent")]
	public class ScrollBar extends Sprite {
		private var scroller:Sprite;
		private var scrollerPath:Sprite;
		
		private var target:DisplayObject;
		private var position:String;
		private var _length:int;
		private var needToClip:Boolean;
		private var needInertia:Boolean;
		private var inertialTime:Number;
		private var wheelSensibility:Number;
		
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastScrollerPos:Point = new Point;
		private var neutralTargetPosition:Point;
		
		private var rect:Rectangle;
		private var _targetLength:Number;
		
		private var scrollerCoef:Number = 0;
		private var scrollerIsDown:Boolean;
		
		public static const VERTICAL:String = 'vertical';
		public static const HORIZONTAL:String = 'horizontal';
		private const MIN_LENGTH:int = 24;
		
		public function ScrollBar(skin:MovieClip, target:DisplayObject, wheelSensibility:Number = 20, position:String = ScrollBar.VERTICAL, length:int = 100, needToClip:Boolean = false, viewportLength:int = 100, needInertia:Boolean = false, inertialTime:Number = .5):void {
			scroller = skin.scroller;
			scrollerPath = skin.scrollerPath;
			this.target = target;
			this.wheelSensibility = wheelSensibility;
			this.position = position;
			this.length = length;
			this.needToClip = needToClip;
			this.viewportLength = viewportLength;
			this.needInertia = needInertia;
			this.inertialTime = inertialTime;
			
			setup();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function setup():void {
			addChild(scrollerPath);
			addChild(scroller);
			
			if (position == VERTICAL) {
				scrollerPath.height = this.length;
				_targetLength = target.height;
			} else if (position == HORIZONTAL) {
				scrollerPath.width = this.length;
				_targetLength = target.width;
			}
			
			if ( (needToClip && targetLength <= this.viewportLength) || (!needToClip && targetLength <= this.length) ) {
				mouseEnabled = false;
				mouseChildren = false;
				alpha = .3;
				scroller.visible = false;
				return;
			}
			
			scroller.buttonMode = true;
			scrollerLength = calcScrollerLength(this.length, targetLength, this.viewportLength);
			neutralTargetPosition = new Point(target.x, target.y);
			
			target.cacheAsBitmap = true;
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			scroller.addEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollerDrag);
			target.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			target.addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			target.addEventListener(MouseEvent.ROLL_OUT, onOut);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		private function onOver(e:MouseEvent):void {
			MouseWheel.capture();
		}
		
		private function onOut(e:MouseEvent):void {
			MouseWheel.release();
		}
		
		public function destroy():void {
			scroller.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollerDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollerUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollerDrag);
			target.removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			target.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			removeEventListener(MouseEvent.ROLL_OVER, onOver);
			target.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			removeEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		//event handlers
		/////////////////////
		private function onScrollerDown(e:MouseEvent):void {
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			scrollerIsDown = true;
		}
		
		private function onScrollerUp(e:MouseEvent):void {
			scrollerIsDown = false;
		}
		
		private function onScrollerDrag(e:MouseEvent):void {
			if (!scrollerIsDown) return;
			
			if (position == VERTICAL) {
				scroller.y += mouseY - lastMouseY;
				if (scroller.y > length - scrollerLength || (lastScrollerPos.y == length - scrollerLength && mouseY > length - scrollerLength / 2) ) {
					scroller.y = length - scrollerLength;
				}else if (scroller.y < 0 || (lastScrollerPos.y == 0 && mouseY < scrollerLength / 2) ) {
					scroller.y = 0;
				}
				scrollerCoef = scroller.y / (length - scrollerLength);
			}else if (position == HORIZONTAL) {
				scroller.x += mouseX - lastMouseX;
				if (scroller.x > length - scrollerLength || (lastScrollerPos.x == length - scrollerLength && mouseX > length - scrollerLength / 2) ) {
					scroller.x = length - scrollerLength;
				}else if (scroller.x < 0 || (lastScrollerPos.x == 0 && mouseX < scrollerLength / 2) ) {
					scroller.x = 0;
				}
				scrollerCoef = scroller.x / (length - scrollerLength);
			}
			lastScrollerPos.x = scroller.x;
			lastScrollerPos.y = scroller.y;
			
			if (needToClip) {
				if(needInertia)TweenLite.to(this, inertialTime, { targetPosition: - scrollerCoef * (targetLength - viewportLength), onComplete:dispatchScrollEvent } );
				else {
					targetPosition = - scrollerCoef * (targetLength - viewportLength);
					dispatchScrollEvent();
				}
			}else {
				if(needInertia)TweenLite.to(this, inertialTime, { targetPosition: - scrollerCoef * (targetLength - length), onComplete:dispatchScrollEvent } );
				else {
					targetPosition = - scrollerCoef * (targetLength - length);
					dispatchScrollEvent();
				}
			}
			
			lastMouseX = mouseX;
			lastMouseY = mouseY;
			e.updateAfterEvent();
		}
		
		private function onWheel(e:MouseEvent):void {
			var deltaOfScrollingPosition:Number = wheelSensibility * e.delta / 3;
			var deltaOfCoef:Number = (needToClip)?deltaOfScrollingPosition / (targetLength - viewportLength):deltaOfScrollingPosition / (targetLength - length);
			scrollerCoef -= deltaOfCoef;
			if (scrollerCoef > 1) {
				scrollerCoef = 1;
			} else if (scrollerCoef < 0) {
				scrollerCoef = 0;
			}
			
			if (needToClip) {
				if (needInertia) TweenLite.to(this, inertialTime, { targetPosition: - scrollerCoef * (targetLength - viewportLength), scrollerPosition:scrollerCoef * (length - scrollerLength), onComplete:dispatchScrollEvent } );
				else {
					targetPosition = - scrollerCoef * (targetLength - viewportLength);
					scrollerPosition = scrollerCoef * (length - scrollerLength);
					dispatchScrollEvent();
				}
			}else {
				if(needInertia)TweenLite.to(this, inertialTime, { targetPosition: - scrollerCoef * (targetLength - length), scrollerPosition:scrollerCoef * (length - scrollerLength), onComplete:dispatchScrollEvent } );
				else {
					targetPosition = - scrollerCoef * (targetLength - length);
					scrollerPosition = scrollerCoef * (length - scrollerLength);
					dispatchScrollEvent();
				}
			}
			lastScrollerPos.x = scroller.x;
			lastScrollerPos.y = scroller.y;
			e.preventDefault();
		}
		
		private function dispatchScrollEvent():void {
			lastScrollerPos.x = scroller.x;
			lastScrollerPos.y = scroller.y;
			dispatchEvent(new ScrollBarEvent(ScrollBarEvent.SCROLL, targetPosition, target));
		}
		
		//accessors
		/////////////////////
		public function get targetPosition():Number {
			var result:Number;
			if (needToClip) {
				if (position == VERTICAL) result = -rect.y;
				else if (position == HORIZONTAL) result = -rect.x;
			}else {
				if (position == VERTICAL) result = target.y - neutralTargetPosition.y;
				else if (position == HORIZONTAL) result = target.x - neutralTargetPosition.x;
			}
			return result;
		}
		
		public function set targetPosition(value:Number):void {
			if (needToClip) {
				if (position == VERTICAL) rect.y = -value;
				else if (position == HORIZONTAL) rect.x = -value;
				target.scrollRect = rect;
			}else {
				if (position == VERTICAL) target.y = neutralTargetPosition.y + value;
				else if (position == HORIZONTAL) target.x = neutralTargetPosition.x + value;
			}
		}
		
		public function get length():int {
			return _length;
		}
		
		public function set length(value:int):void {
			if (value < MIN_LENGTH)
				value = MIN_LENGTH;
			
			_length = value;
			if (position == VERTICAL) scrollerPath.height = value;
			else if (position == HORIZONTAL) scrollerPath.width = value;
		}
		
		/**высота скроллируемого объекта*/
		public function get targetLength():Number {
			/*var result:Number;
			if (needToClip) {
				if (position == VERTICAL) result = target.transform.pixelBounds.height;
				else if (position == HORIZONTAL) result = target.transform.pixelBounds.width;
			}else {
				if (position == VERTICAL) result = target.height;
				else if (position == HORIZONTAL) result = target.width;
			}
			
			return result;*/
			return _targetLength;
		}
		
		public function get viewportLength():int {
			var result:int;
			if (position == VERTICAL) result = rect.height;
			else if (position == HORIZONTAL) result = rect.width;
			
			return result;
		}
		
		public function set viewportLength(value:int):void {
			if (!rect)
				rect = new Rectangle(0, 0, target.width, target.height);
			
			if (position == VERTICAL)
				rect.height = value;
			else if (position == HORIZONTAL)
				rect.width = value;
				
			if(needToClip)target.scrollRect = rect;
		}
		
		public function get scrollerLength():int {
			var result:int;
			if (position == VERTICAL) result = scroller.height;
			else if (position == HORIZONTAL) result = scroller.width;
			
			return result;
		}
		
		public function set scrollerLength(value:int):void {
			if (value < MIN_LENGTH)
				value = MIN_LENGTH;
			
			if (position == VERTICAL) scroller.height = value;
			else if (position == HORIZONTAL) scroller.width = value;
		}
		
		public function get scrollerPosition():Number {
			var res:Number;
			if (position == VERTICAL) {
				res = scroller.y;
			}else if (position == HORIZONTAL) {
				res = scroller.x;
			}
			return res;
		}
		
		public function set scrollerPosition(value:Number):void {
			if (position == VERTICAL) {
				scroller.y = value;
			}else if (position == HORIZONTAL) {
				scroller.x = value;
			}
		}
		
		private function calcScrollerLength(length:int, targetLength:int, viewportLength:int = 0):Number {
			if (needToClip) return length * (viewportLength / targetLength);
			else return length * (length / targetLength);
		}
	}
}