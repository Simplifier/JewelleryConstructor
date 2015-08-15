package pages {
	import beadParticles.Bead;
	import beadParticles.Lock;
	import beadParticles.Particle;
	import colliders.Collider;
	import com.greensock.TweenLite;
	import components.drpMenu.DropMenu;
	import components.scrollBar.ScrollBar;
	import components.tabbedPnl.TabBar;
	import events.ColliderEvent;
	import events.DeleteBtnEvent;
	import events.LoadEvent;
	import events.PageEvent;
	import events.ScrollBarEvent;
	import events.TabEvent;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import models.OrderData;
	import models.ParticleData;
	import modWin.DetailsOfBeadWin;
	import serverConnector.JewServerConnector;
	
	public class BeadsPage extends Sprite {
		private var contentPanel:Sprite = new Sprite;
		private var selectedTab:Sprite = new Sprite;
		private var tabsContent:Vector.<Sprite> = new Vector.<Sprite>(2, true);
		
		private var particlesGrid:ContentGrid;
		private var particlesGridScroller:ScrollBar;
		private var wishGrid:ContentGrid;
		private var wishGridScroller:ScrollBar;
		
		private var modalWins:Object = new Object;
		private var collider:Collider;
		private var clickedItemData:ParticleData;
		private var filterMenus:Object = {};
		private var productNameField:ProductName = new ProductName;
		private var costField:TextField = new TextField;
		private var totalCost:Number;
		
		public var coresetType:String;
		private var elementType:String;
		private var orderData:OrderData;
		private var userID:int = JewelleryConstructor.flashVars.viewer_id;
		private var particleIsCaptured:Boolean;
		public var wishListIsChanged:Boolean = true;
		
		public static const WISH_LIST_CHANGED:String = 'wishListChanged';
		
		public function BeadsPage(elementType:String, orderData:OrderData):void {
			this.orderData = orderData;
			this.elementType = elementType;
			
			productNameField.x = 361;
			productNameField.y = 21;
			addChild(productNameField);
			productNameField.addEventListener(Event.CHANGE, onProductNameChange);
			
			costField.autoSize = TextFieldAutoSize.LEFT;
			costField.type = TextFieldType.INPUT;
			costField.mouseEnabled = false;
			costField.embedFonts = true;
			costField.x = 725;
			costField.y = 21;
			addChild(costField);
			
			var con:JewServerConnector = new JewServerConnector;
			con.load('elementsAndFilters', {productTypeID: PagesLayer.BRACELET, elementCategoryID: elementType});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		}
		
		public function setCollider(collider:Collider):void {
			if (this.collider && contains(this.collider))
				removeChild(this.collider);
			this.collider = collider;
			collider.mouseEnabled = false;
			addChild(collider);
			
			totalCost = (collider.coresetData.dontBuyBase)?0:collider.coresetData.price;
			for each(var part:ParticleData in collider.particlesData) {
				totalCost += part.price;
			}
			updateCost(totalCost);
			
			collider.addEventListener(ColliderEvent.ELEMENT_ADDED, collider_elementAddedHandler);
			collider.addEventListener(ColliderEvent.ELEMENT_REMOVED, collider_elementRemovedHandler);
		}
		
		private function collider_elementAddedHandler(e:ColliderEvent):void {
			totalCost += e.relatedObject.particleData.price;
			updateCost(totalCost);
		}
		
		private function collider_elementRemovedHandler(e:ColliderEvent):void {
			totalCost -= e.relatedObject.particleData.price;
			updateCost(totalCost);
		}
		
		public function updateProductName():void {
			if (orderData.productName)
				productNameField.update(orderData.productName);
			else {
				if (coresetType == PagesLayer.BRACELET) {
					productNameField.update('Мой браслет');
				} else if (coresetType == PagesLayer.NECKLACE) {
					productNameField.update('Мое колье');
				} else if (coresetType == PagesLayer.EARRING) {
					productNameField.update('Мои серьги');
				}
			}
		}
		
		public function updateCost(cost:Number):void {
			costField.htmlText = '<font face="CharterB" size="17" color="#333333">' + cost + ' руб.</font>';
		}
		
		public function synchronizeWishList():void {
			if (selectedTab == tabsContent[1] && wishListIsChanged) loadWishListData();
		}
		
		private function onProductNameChange(e:Event):void {
			orderData.productName = productNameField.text;
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			JewServerConnector(e.target).removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			
			contentPanel.x = 20;
			contentPanel.y = 21;
			addChildAt(contentPanel, 0);
			
			var tabs:TabBar = new TabBar(new < String > [elementType == PagesLayer.BEAD?'Бусины':'Замки', 'Список предпочтений'], 349, 20, new < String > ['0', '1']);
			tabs.x = -20;
			contentPanel.addChild(tabs);
			tabs.addEventListener(TabEvent.SELECT, onTabSelect);
			
			var allBeadsTab:Sprite = new Sprite;
			allBeadsTab.y = 60;
			contentPanel.addChild(allBeadsTab);
			tabsContent[0] = allBeadsTab;
			selectedTab = allBeadsTab;
			
			var dropMenus:Sprite = new Sprite;
			var filterDropMenu:DropMenu;
			var menuData:Array = [];
			var item:Object;
			var menuYPos:int;
			var i:int = 0;
			
			filterMenus.materials = dropMenus.addChild(createDropList(e.data.MaterialFilter, 'Материал'));
			
			filterMenus.colors = dropMenus.addChild(createDropList(e.data.ColorFilter, 'Цвет'));
			filterMenus.colors.y = int(filterMenus.materials.y + filterMenus.materials.height + 10);
			
			filterMenus.collections = dropMenus.addChild(createDropList(e.data.CollectionFilter, 'Коллекция'));
			filterMenus.collections.y = int(filterMenus.colors.y + filterMenus.colors.height + 10);
			
			var beadsTrap:Sprite = new Sprite;
			beadsTrap.graphics.beginFill(0xF3F4F5);
			beadsTrap.graphics.drawRoundRect(0, 0, 330 - dropMenus.width - 10, dropMenus.height, 10);
			beadsTrap.filters = [new DropShadowFilter(1, 45, 0, .3, 2, 2, 1, 3, true)];
			beadsTrap.x = int(dropMenus.width) + 10;
			beadsTrap.y = dropMenus.y;
			var tf:TextField = new TextField;
			tf.mouseEnabled = false;
			tf.embedFonts = true;
			tf.wordWrap = true;
			tf.htmlText = '<p  align="center"><font face="CharterI" size="14" color="#687A7A">Перетяните ' + (elementType == PagesLayer.BEAD?'бусину':'замок') + ' в избранные</font></p>';
			tf.width = beadsTrap.width - 14;
			tf.height = tf.textHeight+5;
			tf.x = 7;
			tf.y = int(beadsTrap.height / 2 - tf.height / 2);
			beadsTrap.addChild(tf);
			beadsTrap.addEventListener(MouseEvent.MOUSE_UP, beadsTrap_mouseUpHandler);
			beadsTrap.addEventListener(MouseEvent.ROLL_OVER, beadsTrap_rollOverHandler);
			beadsTrap.addEventListener(MouseEvent.ROLL_OUT, beadsTrap_rollOutHandler);
			
			particlesGrid = new ContentGrid(e.data.Elements, elementType, 4, 4);
			particlesGrid.y = dropMenus.y + dropMenus.height + 15;
			
			particlesGridScroller = new ScrollBar(new ContentGridScrollBar, particlesGrid, 76, ScrollBar.VERTICAL, 300, true, 300, true);
			particlesGridScroller.x = particlesGrid.x + particlesGrid.width + 10;
			particlesGridScroller.y = particlesGrid.y;
			addToLoadOfGrid(particlesGrid, particlesGridScroller, 0);
			
			allBeadsTab.addChild(beadsTrap);
			allBeadsTab.addChild(particlesGrid);
			allBeadsTab.addChild(particlesGridScroller);
			allBeadsTab.addChild(dropMenus);
			
			particlesGridScroller.addEventListener(ScrollBarEvent.SCROLL, grid_scrollHandler);
			
			particlesGrid.addEventListener(MouseEvent.CLICK, onGridItemClick);
			particlesGrid.addEventListener(MouseEvent.MOUSE_DOWN, onGridItemMouseDown);
		}
		
		private function beadsTrap_rollOutHandler(e:MouseEvent):void {
			TweenLite.to(e.target, .7, {removeTint: true, glowFilter:{color:0xffffff, alpha:0, blurX:30, blurY:30}});
		}
		
		private function beadsTrap_rollOverHandler(e:MouseEvent):void {
			if(particleIsCaptured)
			TweenLite.to(e.target, .3, {colorTransform:{tint: 0x00aaff, tintAmount:.1}, glowFilter:{color:0xffffff, alpha:.8, blurX:40, blurY:40, inner:true, strength:1.5}});
		}
		
		private function beadsTrap_mouseUpHandler(e:MouseEvent):void {
			if (!particleIsCaptured) return;
			
			TweenLite.to(e.target, .7, { removeTint: true, glowFilter: { color:0xffffff, alpha:0, blurX:30, blurY:30 }} );
			addToWishList(clickedItemData.id);
		}
		
		private function addToWishList(elementID:String):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('wishList', {action: 'add', clientID: userID, elementID:elementID});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, addedToWishListHandler);
		}
		
		private function addedToWishListHandler(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, addedToWishListHandler);
			dispatchEvent(new Event(WISH_LIST_CHANGED));
			
			trace(e.data, '+1');
		}
		
		private var selectedTabIndex:int;
		private function onTabSelect(e:TabEvent):void {
			if (e.index == selectedTabIndex) return;
			
			selectedTabIndex = e.index;
			if (tabsContent[e.index]) {
				selectedTab.visible = false;
				selectedTab = tabsContent[e.index];
				selectedTab.visible = true;
				
				if (e.index == 1 && wishListIsChanged) {
					loadWishListData();
				}
			} else {
				var wishBeadsTab:Sprite = new Sprite;
				contentPanel.addChild(wishBeadsTab);
				tabsContent[1] = wishBeadsTab;
				selectedTab.visible = false;
				selectedTab = wishBeadsTab;
				
				loadWishListData();
			}
		}
		
		private function loadWishListData():void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('wishList', {clientID: userID});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, wishListDataLoadedHandler);
		}
		
		private function wishListDataLoadedHandler(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, wishListDataLoadedHandler);
			
			updateWishGrid(e.data as Array);
		}
		
		private function updateWishGrid(sourceData:Array):void {
			if(wishGrid){
				wishGrid.destroy();
				wishGridScroller.destroy();
				tabsContent[1].removeChild(wishGrid);
				tabsContent[1].removeChild(wishGridScroller);
				wishGrid.removeEventListener(MouseEvent.CLICK, onGridItemClick);
				wishGrid.removeEventListener(MouseEvent.MOUSE_DOWN, onGridItemMouseDown);
				wishGridScroller.removeEventListener(ScrollBarEvent.SCROLL, grid_scrollHandler);
			}
			
			wishGrid = new ContentGrid(sourceData, elementType, 4, 4, true);
			wishGrid.y = 60;
			tabsContent[1].addChild(wishGrid);
			
			wishGridScroller = new ScrollBar(new ContentGridScrollBar, wishGrid, 76, ScrollBar.VERTICAL, 415, true, 415, true);
			wishGridScroller.x = wishGrid.x + wishGrid.width + 10;
			wishGridScroller.y = wishGrid.y;
			tabsContent[1].addChild(wishGridScroller);
			addToLoadOfGrid(wishGrid, wishGridScroller, 0);
			
			wishGrid.addEventListener(MouseEvent.CLICK, onGridItemClick);
			wishGrid.addEventListener(MouseEvent.MOUSE_DOWN, onGridItemMouseDown);
			wishGrid.addEventListener(DeleteBtnEvent.DELETE_BTN_CLICKED, wishGrid_deleteBtnClickedHandler);
			wishGridScroller.addEventListener(ScrollBarEvent.SCROLL, grid_scrollHandler);
			
			wishListIsChanged = false;
		}
		
		private function wishGrid_deleteBtnClickedHandler(e:DeleteBtnEvent):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('wishList', {action: 'delete', clientID: userID, elementID:e.id});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, removedFromWishListHandler);
		}
		
		private function removedFromWishListHandler(e:LoadEvent):void {
			dispatchEvent(new Event(WISH_LIST_CHANGED));
			
			trace(e.data, '-1');
			loadWishListData();
		}
		
		private function createDropList(sourceData:Array, promptText:String):DropMenu {
			var menuData:Array = [];
			var i:int = 0;
			for each (var item:Object in sourceData) {
				if (i == 0)
					menuData.push({label: item.Name, data: item.ID, isDefault: true});
				else
					menuData.push({label: item.Name, data: item.ID});
				i++;
			}
			var dropMenu:DropMenu = new DropMenu(menuData, 200, promptText, 8);
			
			dropMenu.addEventListener(MouseEvent.ROLL_OVER, filterDropMenu_overHandler);
			dropMenu.addEventListener(Event.CHANGE, filterDropMenu_changeHandler);
			
			return dropMenu;
		}
		
		private function filterDropMenu_changeHandler(e:Event):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('elements', {productTypeID: coresetType, elementCategoryID: elementType, filterMaterialID: filterMenus.materials.selectedData, filterColorID: filterMenus.colors.selectedData, filterCollectionID: filterMenus.collections.selectedData});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, filterBeads);
		}
		
		private function filterBeads(e:LoadEvent):void {
			JewServerConnector(e.target).removeEventListener(LoadEvent.LOAD_COMPLETE, filterBeads);
			
			var yPos:int = particlesGrid.y;
			particlesGrid.destroy();
			particlesGridScroller.destroy();
			tabsContent[0].removeChild(particlesGrid);
			tabsContent[0].removeChild(particlesGridScroller);
			particlesGrid.removeEventListener(MouseEvent.CLICK, onGridItemClick);
			particlesGrid.removeEventListener(MouseEvent.MOUSE_DOWN, onGridItemMouseDown);
			particlesGridScroller.removeEventListener(ScrollBarEvent.SCROLL, grid_scrollHandler);
			
			particlesGrid = new ContentGrid(e.data, elementType, 4, 4);
			particlesGrid.y = yPos;
			tabsContent[0].addChildAt(particlesGrid, 0);
			
			particlesGridScroller = new ScrollBar(new ContentGridScrollBar, particlesGrid, 76, ScrollBar.VERTICAL, 300, true, 300, true);
			particlesGridScroller.x = particlesGrid.x + particlesGrid.width + 10;
			particlesGridScroller.y = particlesGrid.y;
			tabsContent[0].addChildAt(particlesGridScroller, 0);
			addToLoadOfGrid(particlesGrid, particlesGridScroller, 0);
			
			particlesGridScroller.addEventListener(ScrollBarEvent.SCROLL, grid_scrollHandler);
			
			particlesGrid.addEventListener(MouseEvent.CLICK, onGridItemClick);
			particlesGrid.addEventListener(MouseEvent.MOUSE_DOWN, onGridItemMouseDown);
		}
		
		private function addToLoadOfGrid(grid:ContentGrid, scroller:ScrollBar, gridScrollingPosition:Number):void {
			var cellIndex:int = (Math.ceil(gridScrollingPosition / (grid.cellHeight + grid.vertCellIndent)) - 1) * grid.rowCount;
			if (cellIndex < 0)
				cellIndex = 0;
			var cellsAmount:int = (Math.floor(scroller.viewportLength / (grid.cellHeight + grid.vertCellIndent)) + 2) * grid.rowCount;
			var i:int = cellIndex;
			for (i; i < cellIndex + cellsAmount; i++) {
				if (i > grid.cellsAmount) {
					break;
				}
				grid.loadCell(i);
			}
		}
		
		private function grid_scrollHandler(e:ScrollBarEvent):void {
			addToLoadOfGrid(e.relatedObject as ContentGrid, e.target as ScrollBar, -e.scrollingPosition);
		}
		
		private function filterDropMenu_overHandler(e:MouseEvent):void {
			var dropMenu:Sprite = e.currentTarget as Sprite;
			dropMenu.parent.addChild(dropMenu);
		}
		
		private function onGridItemClick(e:MouseEvent):void {
			if (!(e.target is ContentGridCell))
				return;
			
			var itemID:String = e.target.data.id;
			var modalWin:DetailsOfBeadWin = modalWins[itemID];
			if (!modalWin) {
				modalWin = modalWins[itemID] = new DetailsOfBeadWin(PagesLayer.BEAD, itemID);
				
				modalWin.addEventListener(DetailsOfBeadWin.TREAD_BEAD_CLICK, modalWin_treadBeadClickHandler);
				modalWin.addEventListener(DetailsOfBeadWin.FAV_BTN_CLICK, modalWin_favBtnClickHandler);
			}
			modalWin.add();
		}
		
		private function modalWin_favBtnClickHandler(e:Event):void {
			addToWishList(clickedItemData.id);
		}
		
		private function modalWin_treadBeadClickHandler(e:Event):void {
			trace(clickedItemData.type)
			if (clickedItemData.type == PagesLayer.BEAD) {
				collider.threadBead(new Bead(clickedItemData));
			}else if (clickedItemData.type == PagesLayer.LOCK) {
				collider.threadLock(new Lock(clickedItemData));
			}
		}
		
		private function onGridItemMouseDown(e:MouseEvent):void {
			if (!(e.target is ContentGridCell))
				return;
			
			particleIsCaptured = true;
			clickedItemData = e.target.data;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseMove(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			particlesGrid.mouseChildren = false;
			if(wishGrid)wishGrid.mouseChildren = false;
			
			trace(clickedItemData.type)
			if (clickedItemData.type == PagesLayer.BEAD) {
				collider.addBeadHandling(new Bead(clickedItemData));
			}else if (clickedItemData.type == PagesLayer.LOCK) {
				collider.addLockHandling(new Lock(clickedItemData));
			}
		}
		
		private function onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			particleIsCaptured = false;
			particlesGrid.mouseChildren = true;
			if(wishGrid)wishGrid.mouseChildren = true;
		}
	}
}
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;

[Event(name="change",type="flash.events.Event")]

class ProductName extends Sprite {
	private var tfield:TextField = new TextField;
	private var editIcon:Sprite = new EditIcon;
	
	public function ProductName():void {
		tfield.autoSize = TextFieldAutoSize.LEFT;
		tfield.type = TextFieldType.INPUT;
		tfield.mouseEnabled = false;
		tfield.embedFonts = true;
		tfield.maxChars = 30;
		addChild(tfield);
		
		editIcon.buttonMode = true;
		editIcon.x = tfield.width + 5;
		editIcon.y = 4;
		addChild(editIcon);
		
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	private function init(e:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		tfield.addEventListener(Event.CHANGE, onTextChange);
		editIcon.addEventListener(MouseEvent.CLICK, onEditIconClick);
		stage.addEventListener(MouseEvent.CLICK, onBackGroundClick);
	}
	
	public function update(text:String):void {
		tfield.htmlText = '<font face="CharterB" size="17" color="#000000">' + text + '</font>';
		editIcon.x = tfield.width + 5;
	}
	
	public function get text():String {
		return tfield.text;
	}
	
	private function onTextChange(e:Event):void {
		editIcon.x = tfield.width + 5;
		dispatchEvent(e);
	}
	
	private function onEditIconClick(e:MouseEvent):void {
		tfield.mouseEnabled = true;
		stage.focus = tfield;
		tfield.setSelection(0, tfield.length);
	}
	
	private function onBackGroundClick(e:MouseEvent):void {
		if (e.target == tfield || e.target == editIcon)
			return;
		
		tfield.mouseEnabled = false;
	}
}