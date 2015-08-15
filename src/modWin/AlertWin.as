package modWin {
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class AlertWin extends ModalWin {
		private var closeBtn:ModalWinBtn = new ModalWinBtn('Закрыть', true, true);
		
		public function AlertWin(message:String, stage:Stage, disappearDelay:int = -1):void {
			super(400, 200, stage);
			
			var messageField:TextField = new TextField;
			messageField.mouseEnabled = false;
			messageField.embedFonts = true;
			messageField.wordWrap = true;
			messageField.htmlText = '<p align="center"><font face="CharterI" size="18" color="#444444">' + message + '</font></p>';
			messageField.x = 20;
			messageField.y = 50;
			messageField.width = 360;
			messageField.height = messageField.textHeight + 5;
			addChild(messageField);
			
			closeBtn.x = 200 - closeBtn.width / 2;
			closeBtn.y = int(200 - closeBtn.height - 20);
			addChild(closeBtn);
			
			if (disappearDelay > 0) {
				var timer:Timer = new Timer(disappearDelay, 1);
				timer.start();
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			}
			
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
		}
		
		private function closeBtn_clickHandler(e:MouseEvent):void {
			remove();
		}
		
		private function onTimer(e:TimerEvent):void {
			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			e.target.stop();
			remove();
		}
	}
}