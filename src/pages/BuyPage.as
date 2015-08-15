package pages {
	import by.blooddy.crypto.Base64;
	import by.blooddy.crypto.image.JPEGEncoder;
	import colliders.Collider;
	import components.table.Table;
	import components.table.TableCellData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import models.CoresetData;
	import models.OrderData;
	import models.ParticleData;
	import modWin.AlertWin;
	import modWin.JewelleryNamerWin;
	import modWin.ModalWin;
	import modWin.OrderWin;
	import modWin.PostOnWallWin;
	import nt.NumberText;
	import vk.VKApiWrapper;
	
	public class BuyPage extends Sprite {
		private var bmd:BitmapData;
		private var binariedImg:ByteArray;
		private var btn:Sprite = new Sprite;
		private var finalproduct:Collider;
		private var finalproductXML:XML;
		
		private var namerWin:JewelleryNamerWin;
		private var orderWin:ModalWin;
		private var postOnWallWin:PostOnWallWin;
		public var productNameTF:TextField;
		
		private var file:FileReference = new FileReference;
		private var orderData:OrderData;
		
		private var vkcon:VKApiWrapper;
		
		public function BuyPage(finalproduct:Collider, orderData:OrderData):void {
			this.orderData = orderData;
			this.finalproduct = finalproduct;
			
			if (!VKApiWrapper.wallUploadServer) {
				vkcon = new VKApiWrapper(JewelleryConstructor.vkApi);
				vkcon.getSelfWallUploadServer();
			}
			
			bmd = new BitmapData(finalproduct.width, finalproduct.height);
			bmd.draw(finalproduct, new Matrix(1, 0, 0, 1, -finalproduct.getBounds(finalproduct).x, -finalproduct.getBounds(finalproduct).y));
			binariedImg = JPEGEncoder.encode(bmd, 90);
			var bmp:Bitmap = new Bitmap(bmd);
			bmp.smoothing = true;
			if (bmp.width > 480) {
				bmp.width = 480;
				bmp.scaleY = bmp.scaleX;
			}
			bmp.x = int(20 + 250 - bmp.width / 2);
			bmp.y = 70;
			addChild(bmp);
			
			if (orderData.productName)
				productNameTF.htmlText = '<font face="CharterB">' + orderData.productName + '</font>';
			
			var infoField:TextField = new TextField;
			infoField.mouseEnabled = false;
			infoField.multiline = true;
			infoField.wordWrap = true;
			infoField.autoSize = TextFieldAutoSize.LEFT;
			infoField.embedFonts = true;
			infoField.htmlText = '<font face="Charter" size="15" color="#000000">Ваша композиция включает в себя цепочку и ' + finalproduct.particlesData.length + ' ' + new NumberText('элемент', 'элемента', 'элементов').getCase(finalproduct.particlesData.length) + '.</font>';
			infoField.width = 250;
			infoField.height = infoField.textHeight + 5;
			infoField.x = 520;
			infoField.y = 70;
			addChild(infoField);
			
			var costField:TextField = new TextField;
			costField.autoSize = TextFieldAutoSize.LEFT;
			costField.mouseEnabled = false;
			costField.embedFonts = true;
			costField.x = infoField.x;
			costField.y = int(infoField.y + infoField.height + 40);
			addChild(costField);
			
			var bagBtn:Sprite = new BagBtn;
			bagBtn.buttonMode = true;
			bagBtn.x = infoField.x - 3;
			bagBtn.y = int(costField.y + 45);
			
			var bagField:TextField = new TextField;
			bagField.autoSize = TextFieldAutoSize.LEFT;
			bagField.mouseEnabled = false;
			bagField.embedFonts = true;
			bagField.htmlText = '<font face="CharterB" size="17" color="#ffffff">Сделать заказ</font>';
			bagField.x = 55;
			bagField.y = 20;
			addChild(bagBtn);
			bagBtn.addChild(bagField);
			bagBtn.addEventListener(MouseEvent.CLICK, onBagBtnClick);
			
			var icon:Sprite = new FavIcon;
			
			var favField:TextField = new TextField;
			favField.autoSize = TextFieldAutoSize.LEFT;
			favField.mouseEnabled = false;
			favField.embedFonts = true;
			favField.htmlText = '<font face="CharterI" size="15" color="#000000">Добавить в избранные</font>';
			favField.x = icon.width + 3;
			
			var favBtn:Sprite = new Sprite;
			favBtn.graphics.beginFill(0, 0);
			favBtn.graphics.drawRect(0, 0, favBtn.width, favBtn.height);
			favBtn.buttonMode = true;
			favBtn.x = infoField.x;
			favBtn.y = int(bagBtn.y + bagBtn.height + 12);
			favBtn.addEventListener(MouseEvent.CLICK, onFavBtnClick);
			
			favBtn.addChild(icon);
			favBtn.addChild(favField);
			addChild(favBtn);
			
			icon = new FavIcon;
			
			var saveField:TextField = new TextField;
			saveField.autoSize = TextFieldAutoSize.LEFT;
			saveField.mouseEnabled = false;
			saveField.embedFonts = true;
			saveField.htmlText = '<font face="CharterI" size="15" color="#000000">Сохранить изображение</font>';
			saveField.x = icon.width + 3;
			
			var saveBtn:Sprite = new Sprite;
			saveBtn.graphics.beginFill(0, 0);
			saveBtn.graphics.drawRect(0, 0, saveBtn.width, saveBtn.height);
			saveBtn.buttonMode = true;
			saveBtn.x = infoField.x;
			saveBtn.y = int(favBtn.y + favBtn.height + 8);
			saveBtn.addEventListener(MouseEvent.CLICK, onSaveBtnClick);
			
			saveBtn.addChild(icon);
			saveBtn.addChild(saveField);
			addChild(saveBtn);
			
			icon = new FavIcon;
			
			var postOnSelfWallField:TextField = new TextField;
			postOnSelfWallField.autoSize = TextFieldAutoSize.LEFT;
			postOnSelfWallField.mouseEnabled = false;
			postOnSelfWallField.embedFonts = true;
			postOnSelfWallField.htmlText = '<font face="CharterI" size="15" color="#000000">Разместить на стене</font>';
			postOnSelfWallField.x = icon.width + 3;
			
			var postOnSelfWallBtn:Sprite = new Sprite;
			postOnSelfWallBtn.graphics.beginFill(0, 0);
			postOnSelfWallBtn.graphics.drawRect(0, 0, postOnSelfWallBtn.width, postOnSelfWallBtn.height);
			postOnSelfWallBtn.buttonMode = true;
			postOnSelfWallBtn.x = infoField.x;
			postOnSelfWallBtn.y = int(saveBtn.y + saveBtn.height + 8);
			postOnSelfWallBtn.addEventListener(MouseEvent.CLICK, onPostOnSelfWallBtnClick);
			
			postOnSelfWallBtn.addChild(icon);
			postOnSelfWallBtn.addChild(postOnSelfWallField);
			addChild(postOnSelfWallBtn);
			
			var summaryTable:Table = new Table(new <TableCellData>[new TableCellData('<font face="CharterB" size="15" color="#ffffff">Элемент</font>', 100, null, TextFormatAlign.CENTER), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Описание</font>', 360), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Цена</font>', 100, null, TextFormatAlign.RIGHT), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Количество</font>', 100, null, TextFormatAlign.RIGHT), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Стоимость</font>', 140, null, TextFormatAlign.RIGHT)], 38);
			
			var elemPreview:Bitmap;
			elemPreview = new Bitmap(finalproduct.coresetData.bmd);
			elemPreview.smoothing = true;
			if (!finalproduct.coresetData.dontBuyBase)
				summaryTable.addRow(new <TableCellData>[new TableCellData(null, -1, elemPreview, TextFormatAlign.CENTER), new TableCellData('<font face="CharterB" size="15" color="#333333">' + finalproduct.coresetData.name + '</font><font face="Charter" size="15" color="#333333"><br>Артикул ' + finalproduct.coresetData.article + '</font>'), new TableCellData('<font face="Charter" size="15" color="#333333">' + finalproduct.coresetData.price + ' руб.</font>', -1, null, TextFormatAlign.RIGHT), new TableCellData('<font face="Charter" size="15" color="#333333">1</font>', -1, null, TextFormatAlign.RIGHT), new TableCellData('<font face="Charter" size="15" color="#333333">' + finalproduct.coresetData.price + ' руб.</font>', -1, null, TextFormatAlign.RIGHT)], 90, 0, 0xffffff);
			
			var totalCost:Number = (finalproduct.coresetData.dontBuyBase) ? 0 : finalproduct.coresetData.price;
			var partData:ParticleData;
			var dict:Object = {};
			for each (partData in finalproduct.particlesData) {
				if (!dict[partData.id]) {
					dict[partData.id] = {};
					dict[partData.id].partData = partData;
					dict[partData.id].amount = 0;
				}
				dict[partData.id].amount++;
				totalCost += partData.price;
			}
			for each (var obj:Object in dict) {
				partData = obj.partData;
				elemPreview = new Bitmap(partData.bmd);
				elemPreview.smoothing = true;
				summaryTable.addRow(new <TableCellData>[new TableCellData(null, -1, elemPreview, TextFormatAlign.CENTER), new TableCellData('<font face="CharterB" size="15" color="#333333">' + partData.name + '</font><font face="Charter" size="15" color="#333333"><br>Артикул ' + partData.article + '</font>'), new TableCellData('<font face="Charter" size="15" color="#333333">' + partData.price + ' руб.</font>', -1, null, TextFormatAlign.RIGHT), new TableCellData('<font face="Charter" size="15" color="#333333">' + obj.amount + '</font>', -1, null, TextFormatAlign.RIGHT), new TableCellData('<font face="Charter" size="15" color="#333333">' + partData.price * obj.amount + ' руб.</font>', -1, null, TextFormatAlign.RIGHT)], 90, 0, 0xffffff);
			}
			summaryTable.addRow(new <TableCellData>[new TableCellData('<font face="CharterB" size="17" color="#333333">Итого</font>', -1, null, TextFormatAlign.RIGHT, 3), new TableCellData(String('<font face="CharterB" size="17" color="#333333">' + totalCost + ' руб.</font>'), -1, null, TextFormatAlign.RIGHT)], 70, 1, 0xf5f7f8); //0xeef1f2
			summaryTable.x = 13;
			summaryTable.y = Math.max(bmp.y + bmp.height + 20, 460);
			addChild(summaryTable);
			
			costField.htmlText = '<font face="CharterB" size="21" color="#000000">' + totalCost + ' руб.</font>';
		}
		
		private function assembleXML(coresetData:CoresetData, particlesData:Vector.<ParticleData>, endproductBmd:BitmapData):XML {
			var date:Date = new Date;
			
			var xml:XML =
				<builderResult actionType="1" createDate={date.date + '.' + (date.month + 1) + '.' + date.fullYear + ' ' + date.hours + ':' + date.minutes + ':' + date.seconds}>
					<product type={coresetData.type} accessIsPublic={true} price="" caption="Дикая Роза" image={Base64.encode(binariedImg)}>
						<baseElement id={coresetData.id} name={coresetData.name} lenght={coresetData.size} price={coresetData.price} article={coresetData.article} dontBuy={coresetData.dontBuyBase}/>
						<elements>
						
						</elements>
					</product>
					<customer vkId={JewelleryConstructor.flashVars.viewer_id} name="Ванина Таня" sex="2" mobile="+79262354343" email="at@yandex.ru" address="г.Москва ул.Роднева д.34 кв.12" comment="Прошу доставить мне этот браслет до 12 марта"></customer></builderResult>;
			
			if (coresetData.type == PagesLayer.BRACELET) {
				xml..baseElement.appendChild(<math majorRadius={coresetData.majorRadius} minorRadius={coresetData.minorRadius}/>);
			} else if (coresetData.type == PagesLayer.NECKLACE) {
				xml..baseElement.appendChild(<math majorRadius={coresetData.majorRadius} minorRadius={coresetData.minorRadius} straightHeight={coresetData.straightHeight}/>);
			}
			for each (var deadSpace:Object in coresetData.deadSpaces) {
				xml..math.appendChild(<deadSpace width={deadSpace.width} parameter={deadSpace.parameter}/>);
			}
			
			var totalCost:Number = (coresetData.dontBuyBase) ? 0 : coresetData.price;
			for (var i:String in particlesData) {
				totalCost += particlesData[i].price;
				xml..elements.appendChild(<element pos={i} id={particlesData[i].id} type={particlesData[i].type} name={particlesData[i].name} price={particlesData[i].price} article={particlesData[i].article} isTransp={particlesData[i].isTransp} realWidth={particlesData[i].realWidth} centerFromTop={particlesData[i].centerFromTop} parameter={particlesData[i].parameter}/>);
			}
			xml.product.@price = totalCost;
			XML.prettyPrinting = false;
			//trace(xml);
			return xml;
		}
		
		private function onFavBtnClick(e:MouseEvent):void {
			if (!finalproductXML)
				finalproductXML = assembleXML(finalproduct.coresetData, finalproduct.particlesData, bmd);
			
			if (!namerWin)
				namerWin = new JewelleryNamerWin(finalproductXML, orderData);
			namerWin.add();
		}
		
		private function onBagBtnClick(e:MouseEvent):void {
			if (!finalproductXML)
				finalproductXML = assembleXML(finalproduct.coresetData, finalproduct.particlesData, bmd);
			
			if (!orderWin) {
				orderWin = new OrderWin(finalproductXML, orderData);
				orderWin.addEventListener(Event.COMPLETE, onOrderComplete);
			}
			orderWin.add();
		}
		
		private function onOrderComplete(e:Event):void {
			orderWin.removeEventListener(Event.COMPLETE, onOrderComplete);
			orderWin = new AlertWin('Ваш заказ принят', stage, 4000);
			orderWin.add();
		}
		
		private function onSaveBtnClick(e:MouseEvent):void {
			file.save(binariedImg, 'Composition ' + currentDate + '.jpg');
			//file.save(binariedImg, ".jpg");
		}
		
		private function onPostOnSelfWallBtnClick(e:MouseEvent):void {
			if (!finalproductXML)
				finalproductXML = assembleXML(finalproduct.coresetData, finalproduct.particlesData, bmd);
			
			if (!vkcon)
				vkcon = new VKApiWrapper(JewelleryConstructor.vkApi);
			if (!postOnWallWin)
				postOnWallWin = new PostOnWallWin(vkcon, finalproductXML, orderData, finalproduct.coresetData.type, binariedImg);
			postOnWallWin.add();
		}
		
		private function get currentDate():String {
			var date:Date = new Date;
			
			return date.fullYear + '-' + format(date.month + 1) + '-' + format(date.date) + ' ' + format(date.hours) + '.' + format(date.minutes) + '.' + format(date.seconds);
		}
		
		private function format(n:uint):String {
			return ('00' + n).substr( -2);
		}
	}
}