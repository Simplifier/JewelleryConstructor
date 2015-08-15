package {
	import com.flashdynamix.utils.SWFProfiler;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.ColorTransformPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.RemoveTintPlugin;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import events.AppEvent;
	import events.LoadEvent;
	import events.PageEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import models.CoresetData;
	import models.DeadSpaceData;
	import models.ParticleData;
	import modWin.ModalWin;
	import serverConnector.JewServerConnector;
	import vk.APIConnection;
	import vk.events.CustomEvent;
	
	public class JewelleryConstructor extends Sprite {
		[Embed(source="../font/CharterITC.otf",fontFamily="Charter",unicodeRange="U+0020-007F, U+00A0-00BF, U+0401, U+0410-0451, U+2012-201F",advancedAntiAliasing="true",embedAsCFF="false",mimeType="application/x-font")]
		private var charterITC:Class;
		[Embed(source="../font/CharterITC Italic.otf",fontFamily="CharterI",unicodeRange="U+0020-007F, U+00A0-00BF, U+0401, U+0410-0451, U+2012-201F",advancedAntiAliasing="true",embedAsCFF="false",mimeType="application/x-font")]
		private var charterITCItalic:Class;
		[Embed(source="../font/CharterITC Bold.otf",fontFamily="CharterB",unicodeRange="U+0020-007F, U+00A0-00BF, U+0401, U+0410-0451, U+2012-201F",advancedAntiAliasing="true",embedAsCFF="false",mimeType="application/x-font")]
		private var charterITCBold:Class;
		//[Embed(systemFont="CharterITC",fontName="CharterITC",fontWeight="bold", fontStyle="italic",unicodeRange="U+0020-007F, U+00A0-00BF, U+0401, U+0410-0451, U+2012-201F",advancedAntiAliasing="true",embedAsCFF="false",mimeType="application/x-font")]private var charterITC:Class;
		
		private var pagesLayer:PagesLayer;
		private var navMenu:NavigationMenu = new NavigationMenu;
		public static var vkApi:APIConnection;
		public static var flashVars:Object;
		
		private var resized:Boolean;
		private var masker:Shape;
		private var border:Shape;
		
		public function JewelleryConstructor():void {
			TweenPlugin.activate([TintPlugin, ColorTransformPlugin, RemoveTintPlugin, GlowFilterPlugin, AutoAlphaPlugin, ShortRotationPlugin]);
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Security.allowDomain("*");
			Security.allowInsecureDomain('*');
			stage.dispatchEvent(new Event(Event.DEACTIVATE));
			stage.dispatchEvent(new Event(Event.ACTIVATE));
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			flashVars = loaderInfo.parameters;
			if (!flashVars.api_id) {
				flashVars['api_id'] = 3094380;
				flashVars['viewer_id'] = 125573310;
				flashVars['sid'] = "fd30799218457678c87508b948a2de7f0cbf47c4283baaebd214c339e407921b2630f43555a629dbe94f2";
				flashVars['secret'] = "85801b66cb";
			} else {
				//onLocationChanged(flashVars.hash);
			}
			vkApi = new APIConnection(flashVars);
			vkApi.addEventListener('onLocationChanged', locationChangedHandler);
			
			var serviceURL:String = (loaderInfo.parameters.serviceURL) ? loaderInfo.parameters.serviceURL : 'http://api.lorenza.ru/';
			JewServerConnector.init(serviceURL);
			SWFProfiler.init(stage, this);
			
			pagesLayer = new PagesLayer;
			pagesLayer.y = int(navMenu.height);
			addChild(navMenu);
			addChild(pagesLayer);
			
			masker = new Shape;
			masker.graphics.beginFill(0);
			masker.graphics.drawRoundRect(0, 0, stage.stageWidth, stage.stageHeight, 17);
			mask = masker;
			addChild(masker);
			
			border = new Shape;
			border.graphics.lineStyle(2, 0xffffff, 1, true);
			border.graphics.drawRoundRect(0, 0, stage.stageWidth, stage.stageHeight, 17);
			addChild(border);
			
			var modalwins:Sprite = new Sprite;
			addChild(modalwins);
			ModalWin.init(modalwins);
			
			navMenu.addEventListener(MouseEvent.CLICK, navMenu_clickHandler);
			pagesLayer.addEventListener(PageEvent.PAGE_CHANGE, page_changeHandler);
			
			var con:JewServerConnector = new JewServerConnector;
			//con.load('builderProduct', {id: '5B5A083B-9A10-4D6E-97FA-D08A52E6578E'}, false);
			con.addEventListener(LoadEvent.LOAD_COMPLETE, productDataLoadedHandler);
			
			addEventListener(AppEvent.APP_RESIZE, appResizeHandler);
		}
		
		private function appResizeHandler(e:AppEvent):void {
			resizeApp(e.newHeight);
		}
		
		private function resizeApp(height:int):void {
			ExternalInterface.call('resizeWindow', 827, height);
			
			masker.graphics.clear();
			masker.graphics.beginFill(0);
			masker.graphics.drawRoundRect(0, 0, 827, height, 17);
			border.graphics.clear();
			border.graphics.lineStyle(2, 0xffffff, 1, true);
			border.graphics.drawRoundRect(0, 0, 827, height, 17);
		}
		
		private function page_changeHandler(e:PageEvent):void {
			changePageBtn(e.page);
		}
		
		private function changePageBtn(newPage:String):void {
			if (resized) {
				resizeApp(600);
				resized = false;
			}
			
			switch (newPage) {
				case PagesLayer.START_PAGE:
					navMenu.selectBtn(navMenu.startPageBtn);
					
					navMenu.startPageBtn.mouseEnabled = false;
					navMenu.selectBaseBtn.mouseEnabled = false;
					navMenu.beadsPageBtn.mouseEnabled = false;
					navMenu.locksPageBtn.mouseEnabled = false;
					navMenu.buyPageBtn.mouseEnabled = false;
					break;
				
				case PagesLayer.SELECT_BASE_PAGE:
					navMenu.selectBtn(navMenu.selectBaseBtn);
					
					navMenu.startPageBtn.mouseEnabled = true;
					navMenu.selectBaseBtn.mouseEnabled = false;
					navMenu.beadsPageBtn.mouseEnabled = false;
					navMenu.locksPageBtn.mouseEnabled = false;
					navMenu.buyPageBtn.mouseEnabled = false;
					break;
				
				case PagesLayer.BEADS_PAGE:
					navMenu.selectBtn(navMenu.beadsPageBtn);
					
					navMenu.startPageBtn.mouseEnabled = true;
					navMenu.selectBaseBtn.mouseEnabled = true;
					navMenu.beadsPageBtn.mouseEnabled = false;
					navMenu.locksPageBtn.mouseEnabled = true;
					navMenu.buyPageBtn.mouseEnabled = true;
					break;
				
				case PagesLayer.LOCKS_PAGE:
					navMenu.selectBtn(navMenu.locksPageBtn);
					
					navMenu.startPageBtn.mouseEnabled = true;
					navMenu.selectBaseBtn.mouseEnabled = true;
					navMenu.beadsPageBtn.mouseEnabled = true;
					navMenu.locksPageBtn.mouseEnabled = false;
					navMenu.buyPageBtn.mouseEnabled = true;
					break;
				
				case PagesLayer.BUY_PAGE:
					if (height + 10 > 600) {
						resizeApp(height + 10);
						resized = true;
					}
					
					navMenu.selectBtn(navMenu.buyPageBtn);
					
					navMenu.startPageBtn.mouseEnabled = true;
					navMenu.selectBaseBtn.mouseEnabled = true;
					navMenu.beadsPageBtn.mouseEnabled = true;
					navMenu.locksPageBtn.mouseEnabled = true;
					navMenu.buyPageBtn.mouseEnabled = false;
					break;
			}
		}
		
		private function navMenu_clickHandler(e:MouseEvent):void {
			var newPage:String;
			
			switch (e.target) {
				case navMenu.startPageBtn:
					newPage = PagesLayer.START_PAGE;
					break;
				
				case navMenu.selectBaseBtn:
					newPage = PagesLayer.SELECT_BASE_PAGE;
					break;
				
				case navMenu.beadsPageBtn:
					newPage = PagesLayer.BEADS_PAGE;
					break;
				
				case navMenu.locksPageBtn:
					newPage = PagesLayer.LOCKS_PAGE;
					break;
				
				case navMenu.buyPageBtn:
					newPage = PagesLayer.BUY_PAGE;
					break;
			}
			
			pagesLayer.gotoPage(newPage);
			changePageBtn(newPage);
		}
		
		public function locationChangedHandler(e:CustomEvent):void {
			var locationHash:String = e.params[0];
			if (!locationHash)
				return;
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProduct', {id: locationHash}, false);
			con.addEventListener(LoadEvent.LOAD_COMPLETE, productDataLoadedHandler);
		}
		
		private function productDataLoadedHandler(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, productDataLoadedHandler);
			
			var sourceStr:String = e.data as String;
			sourceStr = sourceStr.substring(1, sourceStr.length - 1);
			sourceStr = sourceStr.replace(/\\"/g, '"');
			
			var xml:XML = XML(sourceStr);
			pagesLayer.orderData.productName = xml.product.@caption;
			if (!pagesLayer.orderData.productName)
				return;
			
			var coresetData:CoresetData = new CoresetData(xml.product.@type, xml..baseElement.@name, xml..baseElement.@id);
			coresetData.size = xml..baseElement.@lenght;
			coresetData.price = xml..baseElement.@price;
			coresetData.article = xml..baseElement.@article;
			coresetData.dontBuyBase = xml..baseElement.@dontBuy == 'true';
			coresetData.majorRadius = xml..math.@majorRadius;
			coresetData.minorRadius = xml..math.@minorRadius;
			for each (var deadSpace:XML in xml..deadSpace) {
				coresetData.deadSpaces.push(new DeadSpaceData(deadSpace.@width, deadSpace.@parameter));
			}
			
			var particlesData:Vector.<ParticleData> = new Vector.<ParticleData>;
			var part:ParticleData;
			for each (var element:XML in xml..element) {
				part = new ParticleData(element.@name, element.@price, element.@id, element.@type, element.@article, element.@realWidth, element.@isTransp == 'true', element.@centerFromTop);
				part.parameter = element.@parameter;
				particlesData.push(part);
			}
			
			pagesLayer.gotoPage(PagesLayer.BEADS_PAGE, coresetData, particlesData);
			changePageBtn(PagesLayer.BEADS_PAGE);
		}
	}
}