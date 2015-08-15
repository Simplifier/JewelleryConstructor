package {
	import beadParticles.Bead;
	import beadParticles.Lock;
	import colliders.Bracelet;
	import colliders.Collider;
	import colliders.Necklace;
	import events.PageEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import models.CoresetData;
	import models.OrderData;
	import models.ParticleData;
	import pages.BeadsPage;
	import pages.BuyPage;
	import pages.SelectBasePage;
	import pages.StartPage;
	
	[Event(name="change",type="PageEvent")]
	
	public class PagesLayer extends Sprite {
		private var currentPage:Sprite;
		
		private var startPage:StartPage = new StartPage;
		private var selectBasePages:Object = new Object; /*of SelectBasePage`s instances*/
		private var selectBasePage:SelectBasePage;
		private var beadsPage:BeadsPage;
		private var locksPage:BeadsPage;
		private var buyPage:BuyPage;
		
		private var coresetType:String;
		
		private var collider:Collider;
		private var _orderData:OrderData;
		
		public static const START_PAGE:String = 'startPage';
		public static const SELECT_BASE_PAGE:String = 'selectBasePage';
		public static const BEADS_PAGE:String = 'beadsPage';
		public static const LOCKS_PAGE:String = 'locksPage';
		public static const BUY_PAGE:String = 'buyPage';
		
		public static const BRACELET:String = '1';
		public static const NECKLACE:String = '2';
		public static const EARRING:String = '3';
		public static const BEAD:String = '10';
		public static const LOCK:String = '11';
		
		public function PagesLayer():void {
			currentPage = startPage;
			addChild(startPage);
			startPage.addEventListener(PageEvent.PAGE_CHANGE, page_changeHandler);
		}
		
		public function get orderData():OrderData {
			if (!_orderData)
				_orderData = new OrderData;
			return _orderData;
		}
		
		private function page_changeHandler(e:PageEvent):void {
			gotoPage(e.page, e.coresetData, e.particlesData, e);
		}
		
		public function gotoPage(page:String, coresetData:CoresetData = null, particlesData:Vector.<ParticleData> = null, catchedEvt:PageEvent = null):void {
			var event:PageEvent = catchedEvt;
			
			if (!catchedEvt) {
				event = new PageEvent(PageEvent.PAGE_CHANGE);
				event.page = page;
			}
			
			removeChild(currentPage);
			
			switch (page) {
				case START_PAGE: 
					currentPage = startPage;
					startPage.resetProductsData();
					addChild(currentPage);
					break;
				
				case SELECT_BASE_PAGE: 
					if (coresetData) {
						coresetType = coresetData.type;
						selectBasePage = selectBasePages[coresetData.type];
					}
					if (!selectBasePage) {
						selectBasePage = selectBasePages[coresetType] = new SelectBasePage(coresetType);
						selectBasePage.addEventListener(PageEvent.PAGE_CHANGE, page_changeHandler);
					}
					currentPage = selectBasePage;
					addChild(currentPage);
					break;
				
				case BEADS_PAGE:
					if (event.fromPage == SELECT_BASE_PAGE) orderData.productName = null;
					if (event.productName) orderData.productName = event.productName;
					
					if (coresetData) {
						coresetType = coresetData.type;
						
						if (collider)
							collider.destroy();
						
						if (coresetData.type == BRACELET) {
							collider = new Bracelet(coresetData);
							collider.x = stage.stageWidth / 2 + 350 / 2;
							collider.y = 55 + stage.stageWidth / 2 - 350 / 2;
						} else if (coresetData.type == NECKLACE) {
							collider = new Necklace(coresetData);
							collider.x = stage.stageWidth / 2 + 350 / 2;
							collider.y = 250;
						}
						for each (var particleData:ParticleData in particlesData) {
							if (particleData.type == BEAD)
								collider.threadBead(new Bead(particleData), particleData.parameter);
							else if (particleData.type == LOCK)
								collider.threadLock(new Lock(particleData), particleData.parameter);
						}
						
						if (!beadsPage){
							beadsPage = new BeadsPage(PagesLayer.BEAD, orderData);
							beadsPage.addEventListener(BeadsPage.WISH_LIST_CHANGED, page_wishListChangedHandler);
						}
						beadsPage.coresetType = coresetType;
					}
					beadsPage.setCollider(collider);
					beadsPage.updateProductName();
					beadsPage.synchronizeWishList();
					
					currentPage = beadsPage;
					addChild(currentPage);
					break;
				
				case LOCKS_PAGE: 
					if (!locksPage){
						locksPage = new BeadsPage(PagesLayer.LOCK, orderData);
						locksPage.addEventListener(BeadsPage.WISH_LIST_CHANGED, page_wishListChangedHandler);
					}
					
					locksPage.setCollider(collider);
					locksPage.coresetType = coresetType;
					locksPage.updateProductName();
					locksPage.synchronizeWishList();
					
					currentPage = locksPage;
					addChild(currentPage);
					break;
				
				case BUY_PAGE: 
					buyPage = new BuyPage(collider, orderData);
					currentPage = buyPage;
					addChild(currentPage);
					break;
				
				default: 
					throw new ArgumentError('Страницы с таким именем не существует');
			}
			
			//если получено событие,
			//то распространяем его выше.
			//если gotoPage() вызван непосредственно,
			//то ничего не делаем
			if(catchedEvt) dispatchEvent(catchedEvt);
		}
		
		private function page_wishListChangedHandler(e:Event):void {
			beadsPage.wishListIsChanged = true;
			if (locksPage) locksPage.wishListIsChanged = true;
		}
	}
}