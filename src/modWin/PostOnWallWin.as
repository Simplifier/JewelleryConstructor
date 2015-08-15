package modWin {
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import components.tf.TextFieldToForms;
	import events.LoadEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import models.OrderData;
	import serverConnector.JewServerConnector;
	import vk.VKApiWrapper;
	
	[Event(name="complete",type="flash.events.Event")]
	
	public class PostOnWallWin extends ModalWin {
		private var confirmBtn:ModalWinBtn = new ModalWinBtn('» Разместить', false);
		private var productNameField:TextFieldToForms;
		private var descrField:TextFieldToForms;
		
		private var userSex:int;
		
		private var accessToProductIsPublic:Boolean = true;
		private var accessSwitcher:MovieClip = new CheckBox;
		private var accessSwitcherContainer:Sprite = new Sprite;
		
		private var orderData:OrderData;
		private var coresetType:String;
		private var vkcon:VKApiWrapper;
		private var binariedImg:ByteArray;
		private var xml:XML;
		private var wallMessage:String;
		private var uploadedImageData:Object;
		
		public function PostOnWallWin(vkcon:VKApiWrapper, xml:XML, orderData:OrderData, coresetType:String, binariedImg:ByteArray):void {
			super(500, 370);
			this.xml = xml;
			this.binariedImg = binariedImg;
			this.coresetType = coresetType;
			this.vkcon = vkcon;
			this.orderData = orderData;
			
			var productNameLable:TextField = new TextField;
			productNameLable.autoSize = TextFieldAutoSize.LEFT;
			productNameLable.mouseEnabled = false;
			productNameLable.embedFonts = true;
			productNameLable.htmlText = '<font face="CharterI" size="16" color="#444444">Придумайте название для своей композиции</font>';
			productNameLable.x = 30;
			productNameLable.y = 40;
			addChild(productNameLable);
			
			productNameField = new TextFieldToForms(win.width - 60, 0, 'Дикая роза');
			productNameField.addEventListener(Event.CHANGE, onTextChange);
			if (orderData.productName) {
				productNameField.text = orderData.productName;
			} else {
				productNameField.captureFocus();
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
			
			var descrLable:TextField = new TextField;
			descrLable.autoSize = TextFieldAutoSize.LEFT;
			descrLable.mouseEnabled = false;
			descrLable.embedFonts = true;
			descrLable.htmlText = '<font face="CharterI" size="16" color="#444444">Добавьте описание</font>';
			descrLable.x = 30;
			descrLable.y = int(productNameField.y + productNameField.height + 70);
			addChild(descrLable);
			
			descrField = new TextFieldToForms(win.width - 60, 100);
			descrField.x = 30;
			descrField.y = int(descrLable.y + descrLable.height + 5);
			addChild(descrField);
			
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
		
		private function onUserNameLoadComplete(data:Object):void {
			userSex = data[0].sex;
			orderData.customer.name = data[0].first_name + ' ' + data[0].last_name;
		}
		
		private function onApiRequestFail(data:Object):void {
			trace('vk error:', data.error_msg);
		}
		
		private function get formIsFillingIn():Boolean {
			return productNameField && productNameField.text;
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
			if (!productNameField.text)
				TweenLite.to(productNameField, 1.2, {glowFilter: {color: 0xff00cc, alpha: 1, blurX: 6, blurY: 6, remove: true, quality: 3}, ease: Elastic.easeInOut});
			else if (!orderData.customer.name) {
				trace('Имя пользователя еще не получено');
			} else {
				orderData.productName = xml.product.@caption = productNameField.text;
				xml.product.@accessIsPublic = accessToProductIsPublic;
				xml..customer.@name = orderData.customer.name;
				xml..customer.@sex = userSex;
				xml.@actionType = 1;
				
				var con:JewServerConnector = new JewServerConnector;
				con.load('builderProduct', {productInfo: xml}, true, URLLoaderDataFormat.TEXT, URLRequestMethod.POST);
				con.addEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
				
				if (!vkcon) vkcon = new VKApiWrapper(JewelleryConstructor.vkApi);
				vkcon.uploadImage(binariedImg);
				vkcon.addEventListener(LoadEvent.UPLOAD_COMPLETE, onUploadImageToVK);
				
				remove();
			}
		}
		
		private function onUploadComplete(e:LoadEvent):void {
			JewServerConnector(e.target).removeEventListener(LoadEvent.LOAD_COMPLETE, onUploadComplete);
			
			var recordID:String = e.data as String;
			
			var type:String;
			if (coresetType == PagesLayer.BRACELET) {
				type = 'Браслет';
			} else if (coresetType == PagesLayer.NECKLACE) {
				type = 'Колье';
			} else if (coresetType == PagesLayer.EARRING) {
				type = 'Серьги';
			}
			wallMessage = type + ' ' + productNameField.text + '\n\n' + descrField.text + '\n\n' + 'Заказать или дополнить: http://vk.com/app3094380#' + recordID + '\n\n' + 'Группа «Украшения в стиле Pandora» http://vk.com/lorenza_pandora';
			
			if (imageIsUploadedToVK) postImageOnWall(uploadedImageData, wallMessage);
		}
		
		private function onUploadImageToVK(e:LoadEvent):void {
			uploadedImageData = e.data;
			
			if (imageIsUploadedToSelfServer) postImageOnWall(uploadedImageData, wallMessage);
		}
		
		private function postImageOnWall(uploadedImageData:Object, message:String):void {
			if (!vkcon) vkcon = new VKApiWrapper(JewelleryConstructor.vkApi);
			vkcon.saveWallPhoto(uploadedImageData, message);
		}
		
		private function get imageIsUploadedToSelfServer():Boolean {
			return wallMessage;
		}
		
		private function get imageIsUploadedToVK():Boolean {
			return uploadedImageData;
		}
	}
}