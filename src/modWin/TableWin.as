package modWin {
	import com.greensock.TweenLite;
	import components.table.Table;
	import components.table.TableCellData;
	import components.table.TableRow;
	import events.AppEvent;
	import events.LoadEvent;
	import events.PageEvent;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import models.CoresetData;
	import models.DeadSpaceData;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	[Event(name="pageChange", type="events.PageEvent")]
	public class TableWin extends ModalWin {
		private var data:Array;
		private var table:Table;
		private var showUserName:Boolean;
		private var previewWin:ImageWin;
		
		public function TableWin(data:Array, title:String, showUserName:Boolean = false):void {
			this.showUserName = showUserName;
			this.data = data;
			
			super(stageSize.width, 600);
			buildTable(data, showUserName);
			
			var gotoMainContainer:Sprite = new Sprite;
			gotoMainContainer.buttonMode = true;
			var gotoMainField:TextField = new TextField;
			gotoMainField.autoSize = TextFieldAutoSize.LEFT;
			gotoMainField.mouseEnabled = false;
			gotoMainField.embedFonts = true;
			gotoMainField.htmlText = '<font face="CharterI" size="22" color="#444444">Главная страница</font>';
			gotoMainField.x = 13;
			gotoMainField.y = 10;
			gotoMainContainer.addChild(gotoMainField);
			addChild(gotoMainContainer);
			gotoMainContainer.addEventListener(MouseEvent.ROLL_OVER, gotoMainField_rollOverHandler);
			gotoMainContainer.addEventListener(MouseEvent.ROLL_OUT, gotoMainField_rollOutHandler);
			gotoMainContainer.addEventListener(MouseEvent.CLICK, gotoMainField_clickHandler);
			
			var titleField:TextField = new TextField;
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.mouseEnabled = false;
			titleField.embedFonts = true;
			titleField.htmlText = '<font face="CharterI" size="22" color="#444444">» '+title+'</font>';
			titleField.x = gotoMainField.x + gotoMainField.width + 5;
			titleField.y = 10;
			addChild(titleField);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onAddedToStage(e:Event):void {
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			if (table && table.height + 100 > 600) {
				dispatchEvent(new AppEvent(AppEvent.APP_RESIZE, table.height + 100, true));
			}
		}
		
		private function onRemovedFromStage(e:Event):void {
			stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			if (height > 600) {
				dispatchEvent(new AppEvent(AppEvent.APP_RESIZE, 600, true));
			}
		}
		
		private function stage_resizeHandler(e:Event):void {
			resize(827, stage.stageHeight, false);
		}
		
		private function gotoMainField_clickHandler(e:MouseEvent):void {
			remove();
		}
		
		private function gotoMainField_rollOverHandler(e:MouseEvent):void {
			e.target.getChildAt(0).htmlText = '<font face="CharterI" size="22" color="#879601">Главная страница</font>';
		}
		
		private function gotoMainField_rollOutHandler(e:MouseEvent):void {
			e.target.getChildAt(0).htmlText = '<font face="CharterI" size="22" color="#444444">Главная страница</font>';
		}
		
		private function buildTable(data:Array, showUserName:Boolean):void {
			if (table) destroyTable();
			
			if (data.length) {
				table = new Table(new <TableCellData>[new TableCellData('<font face="CharterB" size="15" color="#ffffff">Миниатюра</font>', 100, null, TextFormatAlign.CENTER), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Описание</font>', 320), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Действия</font>', 170, null, TextFormatAlign.CENTER), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Дата создания</font>', 120, null, TextFormatAlign.RIGHT), new TableCellData('<font face="CharterB" size="15" color="#ffffff">Цена</font>', 90, null, TextFormatAlign.RIGHT)], 38);
				
				for (var i:int; i < data.length; i++) {
					var actions:MovieClip = new MovieClip;
					actions.buttonMode = true;
					actions.visible = false;
					
					var editBtn:MovieClip = new EditBtn;
					actions.editBtn = editBtn;
					editBtn.alpha = .5;
					actions.addChild(editBtn);
					
					var delBtn:MovieClip = new DelBtn;
					actions.delBtn = delBtn;
					delBtn.alpha = .5;
					delBtn.y = 42;
					actions.addChild(delBtn);
					editBtn.id = data[i].ID;
					delBtn.id = data[i].ID;
					
					editBtn.addEventListener(MouseEvent.ROLL_OVER, onActionBtnOver);
					editBtn.addEventListener(MouseEvent.ROLL_OUT, onActionBtnOut);
					delBtn.addEventListener(MouseEvent.ROLL_OVER, onActionBtnOver);
					delBtn.addEventListener(MouseEvent.ROLL_OUT, onActionBtnOut);
					editBtn.addEventListener(MouseEvent.CLICK, onEditBtnClick);
					delBtn.addEventListener(MouseEvent.CLICK, onDelBtnClick);
					
					var preview:AutoLoadedImage = new AutoLoadedImage(data[i].ID, 96, 86);
					preview.addEventListener(MouseEvent.CLICK, onPreviewClick);
					
					var descr:String = '<font face="CharterB" size="15" color="#333333">' + data[i].Name + '</font>';
					if (showUserName) descr += '<font face="Charter" size="15" color="#333333"><br><br>Собрал </font><font face="CharterB" size="15" color="#0088ff"><a href="http://vk.com/id' + data[i].CreateUserID + '" target="_blank"><u>' + data[i].CreateUserName + '</u></a></font>';
					var row:TableRow = table.addRow(new <TableCellData>[new TableCellData(null, -1, preview, TextFormatAlign.CENTER), new TableCellData(descr), new TableCellData(null, -1, actions, TextFormatAlign.CENTER), new TableCellData('<font face="Charter" size="15" color="#333333">' + data[i].CreateDate.replace('T', ' ') + '</font>', -1, null, TextFormatAlign.RIGHT), new TableCellData('<font face="Charter" size="15" color="#333333">' + data[i].Price + ' руб.</font>', -1, null, TextFormatAlign.RIGHT)], 90, 0, 0xffffff, 1, true);
					row.addEventListener(MouseEvent.ROLL_OVER, onRowOver);
					row.addEventListener(MouseEvent.ROLL_OUT, onRowOut);
					
					editBtn.linkedRow = row;
					delBtn.linkedRow = row;
				}
				table.x = 13;
				table.y = 70;
				addChild(table);
			} else {
				var tfield:TextField = new TextField;
				var tformat:TextFormat = new TextFormat;
				
				tformat.align = TextFormatAlign.CENTER;
				
				tfield.defaultTextFormat = tformat;
				tfield.selectable = false;
				tfield.multiline = true;
				tfield.wordWrap = true;
				tfield.embedFonts = true;
				tfield.htmlText = '<font face="CharterB" size="18" color="#999999">В этой категории еще нет композиций</font>';
				
				tfield.width = stageSize.width - 100;
				tfield.height = tfield.textHeight + 5;
				tfield.x = 50;
				tfield.y = 110;
				
				addChild(tfield);
			}
		}
		
		override public function destroy():void {
			super.destroy();
			if(table)destroyTable();
		}
		
		private function destroyTable():void {
			for each(var row:TableRow in table.rows) {
				row.removeEventListener(MouseEvent.ROLL_OVER, onRowOver);
				row.removeEventListener(MouseEvent.ROLL_OUT, onRowOut);
				
				var editBtn:MovieClip = MovieClip(row.fields[2]).editBtn;
				var delBtn:MovieClip = MovieClip(row.fields[2]).delBtn;
				var preview:AutoLoadedImage = row.fields[0] as AutoLoadedImage;
				
				editBtn.removeEventListener(MouseEvent.ROLL_OVER, onActionBtnOver);
				editBtn.removeEventListener(MouseEvent.ROLL_OUT, onActionBtnOut);
				delBtn.removeEventListener(MouseEvent.ROLL_OVER, onActionBtnOver);
				delBtn.removeEventListener(MouseEvent.ROLL_OUT, onActionBtnOut);
				editBtn.removeEventListener(MouseEvent.CLICK, onEditBtnClick);
				delBtn.removeEventListener(MouseEvent.CLICK, onDelBtnClick);
				preview.removeEventListener(MouseEvent.CLICK, onPreviewClick);
			}
			table = null;
		}
		
		private function onPreviewClick(e:MouseEvent):void {
			previewWin = new ImageWin(e.target.bitmapData);
			previewWin.add();
		}
		
		private function onEditBtnClick(e:MouseEvent):void {
			//e.target.mouseEnabled = false;
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProduct', {id: e.target.id}, false);
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onProductDataLoaded);
		}
			
		private function onProductDataLoaded(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onProductDataLoaded);
			
			//trace(e.data);
			var sourceStr:String = e.data as String;
			sourceStr = sourceStr.substring(1, sourceStr.length - 1);
			sourceStr = sourceStr.replace(/\\"/g, '"');
			
			var xml:XML = XML(sourceStr);
			if (!xml.product.@caption) return;
			
			var pgEvent:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE);
			pgEvent.page = PagesLayer.BEADS_PAGE;
			pgEvent.productName = xml.product.@caption;
			
			var coresetData:CoresetData = new CoresetData(xml.product.@type, xml..baseElement.@name, xml..baseElement.@id);
			coresetData.size = xml..baseElement.@lenght;
			coresetData.price = xml..baseElement.@price;
			coresetData.article = xml..baseElement.@article;
			coresetData.dontBuyBase = xml..baseElement.@dontBuy == 'true';
			coresetData.majorRadius = xml..math.@majorRadius;
			coresetData.minorRadius = xml..math.@minorRadius;
			for each(var deadSpace:XML in xml..deadSpace) {
				coresetData.deadSpaces.push(new DeadSpaceData(deadSpace.@width, deadSpace.@parameter));
			}
			pgEvent.coresetData = coresetData;
			
			var particlesData:Vector.<ParticleData> = new Vector.<ParticleData>;
			var part:ParticleData;
			for each(var element:XML in xml..element) {
				part = new ParticleData(element.@name, element.@price, element.@id, element.@type, element.@article, element.@realWidth, element.@isTransp=='true', element.@centerFromTop);
				part.parameter = element.@parameter;
				pgEvent.particlesData.push(part);
			}
			dispatchEvent(pgEvent);
			remove();
		}
		
		private function onDelBtnClick(e:MouseEvent):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('deleteBuilderProduct', {id: e.target.id});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onDeleteComplete);
		}
		
		private function onDeleteComplete(e:LoadEvent):void {
			removeChild(table);
			for (var i:String in data) {
				if (data[i].ID == e.data) {
					data.splice(i, 1);
					break;
				}
			}
			buildTable(data, showUserName);
			if (height > 600) dispatchEvent(new AppEvent(AppEvent.APP_RESIZE, table.height + 100, true));
		}
		
		private function onRowOver(e:MouseEvent):void {
			TweenLite.to(TableRow(e.target).fields[2], .7, {autoAlpha: 1});
		}
		
		private function onRowOut(e:MouseEvent):void {
			TweenLite.to(TableRow(e.target).fields[2], .3, {autoAlpha: 0});
		}
		
		private function onActionBtnOver(e:MouseEvent):void {
			TweenLite.to(e.target, .5, {alpha: 1});
		}
		
		private function onActionBtnOut(e:MouseEvent):void {
			TweenLite.to(e.target, .5, {alpha: .5});
		}
	}
}
import events.LoadEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.net.URLLoaderDataFormat;
import flash.utils.ByteArray;
import modWin.ModalWin;
import serverConnector.JewServerConnector;

class AutoLoadedImage extends Sprite {
	private var loadIndicator:Sprite;
	private var w:int;
	private var h:int;
	private var bmd:BitmapData;
	public function AutoLoadedImage(productID:String, w:int, h:int):void {
		this.h = h;
		this.w = w;
		
		buttonMode = true;
		mouseEnabled = false;
		mouseChildren = false;
		
		var loader:JewServerConnector = new JewServerConnector;
		loader.load('builderProductImage', {id: productID}, false, URLLoaderDataFormat.BINARY);
		loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		
		if (stage)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		loadIndicator = new CircleLoadIndicator;
		loadIndicator.scaleX = loadIndicator.scaleY = .7;
		loadIndicator.mouseEnabled = false;
		addChild(loadIndicator);
	}
	
	private function onLoadComplete(e:LoadEvent):void {
		e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		
		var loader:Loader = new Loader;
		addChild(loader);
		loader.loadBytes(ByteArray(e.data));
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
	}
	
	private function onParseComplete(e:Event):void {
		removeChild(loadIndicator);
		loadIndicator = null;
		mouseEnabled = true;
		
		var loader:Loader = e.target.loader as Loader;
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		if (loader.width > w || loader.height > h) {
			if (loader.width / w > loader.height / h) {
				loader.width = w;
				loader.scaleY = loader.scaleX;
			} else {
				loader.height = h;
				loader.scaleX = loader.scaleY;
			}
		}
		loader.x = -loader.width / 2;
		loader.y = -loader.height / 2;
		Bitmap(loader.content).smoothing = true;
		bmd = Bitmap(loader.content).bitmapData;
	}
	
	public function get bitmapData():BitmapData {
		return bmd;
	}
}

class ImageWin extends ModalWin {
	private var bmp:Bitmap;
	public function ImageWin(bitmapData:BitmapData):void {
		super(bitmapData.width + 20, bitmapData.height + 40);
		
		bmp = new Bitmap(bitmapData);
		bmp.x = 10;
		bmp.y = 30;
		addChild(bmp);
	}
	
	override public function remove():void {
		destroy();
		super.remove();
	}
}