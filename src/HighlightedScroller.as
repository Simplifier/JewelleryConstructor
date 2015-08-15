package {
import com.greensock.TweenLite;
import flash.display.Sprite;
import flash.events.MouseEvent;
	public class HighlightedScroller extends Sprite {
		public function HighlightedScroller():void {
			addEventListener(MouseEvent.ROLL_OVER, onOver);
			addEventListener(MouseEvent.ROLL_OUT, onOut);
		}
		
		private function onOver(e:MouseEvent):void {
			TweenLite.to(this, .5, {tint: 0xC9DD02, overwrite:false});
		}
		
		private function onOut(e:MouseEvent):void {
			TweenLite.to(this, .5, {removeTint: true, overwrite:false});
		}
	}
}