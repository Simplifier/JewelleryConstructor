package modWin {
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import components.tf.TextFieldToForms;
	import events.LoadEvent;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import models.OrderData;
	import serverConnector.JewServerConnector;
	
	public class JewelleryNamerWin extends ModalWin {
		private var confirmBtn:ModalWinBtn = new ModalWinBtn('» Готово', false);
		private var productNameField:TextFieldToForms;
		private var nameIsValid:Boolean;
		
		private var focusedField:TextFieldToForms;
		
		private var userSex:int;
		
		private var accessToProductIsPublic:Boolean = true;
		private var accessSwitcher:MovieClip = new CheckBox;
		private var accessSwitcherContainer:Sprite = new Sprite;
		
		private var closeBtn:ModalWinBtn = new ModalWinBtn('Закрыть', true, true);
		
		private var xml:XML;
		
		private var firstContainer:Sprite = new Sprite;
		private var secondContainer:Sprite = new Sprite;
		private var orderData:OrderData;
		
		public function JewelleryNamerWin(xml:XML, orderData:OrderData):void {
			super(400, 220);
			this.orderData = orderData;
			this.xml = xml;
			addChild(firstContainer);
			
			var titleField:TextField = new TextField;
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.mouseEnabled = false;
			titleField.embedFonts = true;
			titleField.htmlText = '<font face="CharterI" size="17" color="#444444">Придумайте название для своей композиции</font>';
			titleField.x = 20;
			titleField.y = 40;
			firstContainer.addChild(titleField);
			
			productNameField = new TextFieldToForms(win.width - 40, 0, 'Дикая роза');
			productNameField.addEventListener(Event.CHANGE, onNameChange);
			if (orderData.productName) {
				productNameField.text = orderData.productName;
			} else {
				productNameField.captureFocus(stage);
			}
			productNameField.x = 20;
			productNameField.y = int(titleField.y + titleField.height + 5);
			firstContainer.addChild(productNameField);
			
			accessSwitcherContainer.buttonMode = true;
			accessSwitcher.gotoAndStop('on');
			accessSwitcherContainer.x = productNameField.x;
			accessSwitcherContainer.y = int(productNameField.y + productNameField.height + 13);
			
			var accessSwitcherField:TextField = new TextField;
			accessSwitcherField.autoSize = TextFieldAutoSize.LEFT;
			accessSwitcherField.mouseEnabled = false;
			accessSwitcherField.embedFonts = true;
			accessSwitcherField.htmlText = '<font face="CharterI" size="15" color="#444444">Открыть общий доступ к композиции</font>';
			accessSwitcherField.x = 20;
			accessSwitcherField.y = -2;
			
			firstContainer.addChild(accessSwitcherContainer);
			accessSwitcherContainer.addChild(accessSwitcher);
			accessSwitcherContainer.addChild(accessSwitcherField);
			accessSwitcherContainer.addEventListener(MouseEvent.CLICK, accessSwitcher_clickHandler);
			
			confirmBtn.x = 382 - confirmBtn.width;
			confirmBtn.y = int(win.height - confirmBtn.height - 20);
			firstContainer.addChild(confirmBtn);
			
			var successMessageField:TextField = new TextField;
			successMessageField.mouseEnabled = false;
			successMessageField.embedFonts = true;
			successMessageField.wordWrap = true;
			successMessageField.htmlText = '<p align="center"><font face="CharterI" size="18" color="#444444">Ваше изделие сохранено. Вы можете найти его в разделе «Собранные мной»</font></p>';
			successMessageField.x = 20;
			successMessageField.y = 50;
			successMessageField.width = 360;
			successMessageField.height = successMessageField.textHeight + 5;
			secondContainer.addChild(successMessageField);
			
			closeBtn.x = 200 - closeBtn.width / 2;
			closeBtn.y = int(200 - closeBtn.height - 20);
			secondContainer.addChild(closeBtn);
			
			if (!orderData.customer.name)
				JewelleryConstructor.vkApi.api('getProfiles', {uids: xml..customer.@vkId.toString(), fields: 'first_name,last_name,sex'}, onUserNameLoadComplete, onApiRequestFail);
			
			confirmBtn.addEventListener(MouseEvent.CLICK, confirmBtn_clickHandler);
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
		}
		
		private function accessSwitcher_clickHandler(e:MouseEvent):void {
			if (accessToProductIsPublic)
				accessSwitcher.gotoAndStop('off');
			else
				accessSwitcher.gotoAndStop('on');
			accessToProductIsPublic = !accessToProductIsPublic;
		}
		
		private function onUserNameLoadComplete(data:Object):void {
			userSex = data[0].sex;
			orderData.customer.name = data[0].first_name + ' ' + data[0].last_name;
		}
		
		private function onApiRequestFail(data:Object):void {
			trace('vk error:', data.error_msg);
		}
		
		private function onNameChange(e:Event):void {
			if (productNameField.text == '') {
				nameIsValid = false;
				confirmBtn.enabled = false;
				confirmBtn.highlighted = false;
			} else {
				nameIsValid = true;
				confirmBtn.enabled = true;
				confirmBtn.highlighted = true;
			}
		}
		
		private function confirmBtn_clickHandler(e:MouseEvent):void {
			if (!nameIsValid)
				TweenLite.to(productNameField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
			else if (!orderData.customer.name) {
				trace('Имя пользователя еще не получено');
			} else {
				xml.product.@accessIsPublic = accessToProductIsPublic;
				xml.product.@caption = productNameField.text;
				xml..customer.@name = orderData.customer.name;
				xml..customer.@sex = userSex;
				xml.@actionType = 1;
				
				var con:JewServerConnector = new JewServerConnector;
				con.load('builderProduct', {productInfo: xml}, true, URLLoaderDataFormat.TEXT, URLRequestMethod.POST);
				con.addEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
				win.removeChild(firstContainer);
				addChild(secondContainer);
				
				var timer:Timer = new Timer(4000, 1);
				timer.start();
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			}
		}
		
		private function onUploadComplete(e:LoadEvent):void {
			JewServerConnector(e.target).removeEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
			trace('answer',e.data);
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