package modWin {
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import components.tf.TextFieldToForms;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import events.LoadEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import models.OrderData;
	import serverConnector.JewServerConnector;
	
	[Event(name="complete",type="flash.events.Event")]
	
	public class OrderWin extends ModalWin {
		private var confirmBtn:ModalWinBtn = new ModalWinBtn('» Завершить заказ', false);
		private var userNameField:TextFieldToForms;
		private var phoneField:TextFieldToForms;
		private var addressField:TextFieldToForms;
		private var commentField:TextFieldToForms;
		private var productNameField:TextFieldToForms;
		private var emailField:TextFieldToForms;
		
		private var userSex:int;
		
		private var accessToProductIsPublic:Boolean = true;
		private var accessSwitcher:MovieClip = new CheckBox;
		private var accessSwitcherContainer:Sprite = new Sprite;
		
		private var xml:XML;
		private var orderData:OrderData;
		
		public function OrderWin(xml:XML, orderData:OrderData):void {
			super(620, 560);
			this.orderData = orderData;
			this.xml = xml;
			
			var titleField:TextField = new TextField;
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.mouseEnabled = false;
			titleField.embedFonts = true;
			titleField.htmlText = '<font face="CharterI" size="17" color="#444444">Укажите свои контактные данные</font>';
			titleField.x = 30;
			titleField.y = 40;
			addChild(titleField);
			
			var userNameLable:TextField = new TextField;
			userNameLable.autoSize = TextFieldAutoSize.LEFT;
			userNameLable.mouseEnabled = false;
			userNameLable.embedFonts = true;
			userNameLable.htmlText = '<font face="CharterI" size="16" color="#444444">Полное имя</font>';
			userNameLable.x = 30;
			userNameLable.y = int(titleField.y + titleField.height + 9);
			addChild(userNameLable);
			
			userNameField = new TextFieldToForms(win.width - userNameLable.x - userNameLable.width - 35, 0, xml..customer.@name);
			userNameField.addEventListener(Event.CHANGE, onTextChange);
			userNameField.mouseEnabled = false;
			userNameField.mouseChildren = false;
			if (orderData.customer.name) {
				userNameField.text = orderData.customer.name;
				userNameField.mouseEnabled = true;
				userNameField.mouseChildren = true;
			}
			userNameField.x = userNameLable.x + userNameLable.width + 5;
			userNameField.y = int(titleField.y + titleField.height + 5);
			addChild(userNameField);
			
			var phoneLable:TextField = new TextField;
			phoneLable.autoSize = TextFieldAutoSize.LEFT;
			phoneLable.mouseEnabled = false;
			phoneLable.embedFonts = true;
			phoneLable.htmlText = '<font face="CharterI" size="16" color="#444444">Телефон</font>';
			phoneLable.x = 30;
			phoneLable.y = int(userNameField.y + userNameField.height + 19);
			addChild(phoneLable);
			
			phoneField = new TextFieldToForms(150, 0, xml..customer.@mobile);
			phoneField.addEventListener(Event.CHANGE, onTextChange);
			if (orderData.customer.phone) {
				phoneField.text = orderData.customer.phone;
			} else {
				phoneField.captureFocus(stage);
			}
			phoneField.x = phoneLable.x + phoneLable.width + 5;
			phoneField.y = int(userNameField.y + userNameField.height + 15);
			addChild(phoneField);
			
			var emailLable:TextField = new TextField;
			emailLable.autoSize = TextFieldAutoSize.LEFT;
			emailLable.mouseEnabled = false;
			emailLable.embedFonts = true;
			emailLable.htmlText = '<font face="CharterI" size="16" color="#444444">Электропочта</font>';
			emailLable.x = phoneField.x + phoneField.width + 10;
			emailLable.y = int(userNameField.y + userNameField.height + 19);
			addChild(emailLable);
			
			emailField = new TextFieldToForms(win.width - emailLable.x - emailLable.width - 35, 0, xml..customer.@email);
			emailField.addEventListener(Event.CHANGE, onTextChange);
			if (orderData.customer.email) {
				emailField.text = orderData.customer.email;
			}
			emailField.x = emailLable.x + emailLable.width + 5;
			emailField.y = int(userNameField.y + userNameField.height + 15);
			addChild(emailField);
			
			var addressLable:TextField = new TextField;
			addressLable.autoSize = TextFieldAutoSize.LEFT;
			addressLable.mouseEnabled = false;
			addressLable.embedFonts = true;
			addressLable.htmlText = '<font face="CharterI" size="16" color="#444444">Адрес</font>';
			addressLable.x = 30;
			addressLable.y = int(phoneField.y + phoneField.height + 19);
			addChild(addressLable);
			
			addressField = new TextFieldToForms(win.width - addressLable.x - addressLable.width - 35, 0, xml..customer.@address);
			if (orderData.customer.address) {
				addressField.text = orderData.customer.address;
			}
			addressField.x = addressLable.x + addressLable.width + 5;
			addressField.y = int(phoneField.y + phoneField.height + 15);
			addChild(addressField);
			
			var productNameLable:TextField = new TextField;
			productNameLable.autoSize = TextFieldAutoSize.LEFT;
			productNameLable.mouseEnabled = false;
			productNameLable.embedFonts = true;
			productNameLable.htmlText = '<font face="CharterI" size="16" color="#444444">Придумайте название для своей композиции</font>';
			productNameLable.x = 30;
			productNameLable.y = int(addressField.y + addressField.height + 30);
			addChild(productNameLable);
			
			productNameField = new TextFieldToForms(win.width - 60, 0, 'Дикая роза');
			productNameField.addEventListener(Event.CHANGE, onTextChange);
			if (orderData.productName) {
				productNameField.text = orderData.productName;
			}
			productNameField.x = 30;
			productNameField.y = int(productNameLable.y + productNameLable.height + 5);
			addChild(productNameField);
			
			accessSwitcherContainer.buttonMode = true;
			accessSwitcher.gotoAndStop('on');
			accessSwitcherContainer.x = 30;
			accessSwitcherContainer.y = int(productNameField.y + productNameField.height + 13);
			
			var accessSwitcherField:TextField = new TextField;
			accessSwitcherField.autoSize = TextFieldAutoSize.LEFT;
			accessSwitcherField.mouseEnabled = false;
			accessSwitcherField.embedFonts = true;
			accessSwitcherField.htmlText = '<font face="CharterI" size="15" color="#444444">Открыть общий доступ к композиции</font>';
			accessSwitcherField.x = 20;
			accessSwitcherField.y = -2;
			
			addChild(accessSwitcherContainer);
			accessSwitcherContainer.addChild(accessSwitcher);
			accessSwitcherContainer.addChild(accessSwitcherField);
			accessSwitcherContainer.addEventListener(MouseEvent.CLICK, accessSwitcher_clickHandler);
			
			var commentLable:TextField = new TextField;
			commentLable.autoSize = TextFieldAutoSize.LEFT;
			commentLable.mouseEnabled = false;
			commentLable.embedFonts = true;
			commentLable.htmlText = '<font face="CharterI" size="16" color="#444444">Оставьте комментарии и пожелания к покупке</font>';
			commentLable.x = 30;
			commentLable.y = int(productNameField.y + productNameField.height + 80);
			addChild(commentLable);
			
			commentField = new TextFieldToForms(win.width - 60, 100, xml..customer.@comment);
			commentField.x = 30;
			commentField.y = int(commentLable.y + commentLable.height + 5);
			addChild(commentField);
			
			confirmBtn.x = win.width - confirmBtn.width - 30;
			confirmBtn.y = int(win.height - confirmBtn.height - 20);
			addChild(confirmBtn);
			
			if (!orderData.customer.name)
				JewelleryConstructor.vkApi.api('getProfiles', {uids: xml..customer.@vkId.toString(), fields: 'first_name,last_name,sex'}, onUserNameLoadComplete, onApiRequestFail);
			
			confirmBtn.addEventListener(MouseEvent.CLICK, confirmBtn_clickHandler);
		}
		
		private function accessSwitcher_clickHandler(e:MouseEvent):void {
			if (accessToProductIsPublic)
				accessSwitcher.gotoAndStop('off');
			else
				accessSwitcher.gotoAndStop('on');
			accessToProductIsPublic = !accessToProductIsPublic;
		}
		
		private function get formIsFillingIn():Boolean {
			return userNameField && phoneField && emailField && productNameField && userNameField.text && phoneField.text && emailField.text && productNameField.text;
		}
		
		private function onUserNameLoadComplete(data:Object):void {
			userSex = data[0].sex;
			userNameField.text = data[0].first_name + ' ' + data[0].last_name;
			userNameField.mouseEnabled = true;
			userNameField.mouseChildren = true;
			
			orderData.customer.name = userNameField.text;
		}
		
		private function onTextChange(e:Event):void {
			if (!formIsFillingIn) {
				confirmBtn.enabled = false;
				confirmBtn.highlighted = false;
			} else {
				confirmBtn.enabled = true;
				confirmBtn.highlighted = true;
			}
		}
		
		private function confirmBtn_clickHandler(e:MouseEvent):void {
			if (!formIsFillingIn) {
				if (!userNameField.text)
					TweenLite.to(userNameField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
				if (!phoneField.text)
					TweenLite.to(phoneField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
				if (!emailField.text)
					TweenLite.to(emailField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
				if (!productNameField.text)
					TweenLite.to(productNameField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
			} else {
				orderData.customer.name = xml..customer.@name = userNameField.text;
				orderData.customer.phone = xml..customer.@mobile = phoneField.text;
				orderData.customer.email = xml..customer.@email = emailField.text;
				if (addressField.text)
					orderData.customer.address = xml..customer.@address = addressField.text;
				orderData.productName = xml.product.@caption = productNameField.text;
				xml.product.@accessIsPublic = accessToProductIsPublic;
				xml..customer.@comment = commentField.text;
				xml..customer.@sex = userSex;
				xml.@actionType = 2;
				trace(xml);
				
				var con:JewServerConnector = new JewServerConnector;
				con.load('builderProduct', {productInfo: xml}, true, URLLoaderDataFormat.TEXT, URLRequestMethod.POST);
				con.addEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
				
				remove();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function onUploadComplete(e:LoadEvent):void {
			JewServerConnector(e.target).removeEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
			trace(e.data);
		}
		
		private function onApiRequestFail(data:Object):void {
			trace('vk error:', data.error_msg);
		}
	}
}