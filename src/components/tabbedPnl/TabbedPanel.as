package components.tabbedPnl {
	import components.scrollBar.ScrollBar;
	import events.LoadEvent;
	import events.PageEvent;
	import events.TabEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import models.CoresetData;
	import models.DeadSpaceData;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	public class TabbedPanel extends Sprite {
		private var panels:Vector.<Sprite>;
		private var selectedPanel:Sprite;
		private var selectedTabIndex:int;
		
		public function TabbedPanel(sourceData:Array, width:int):void {
			panels = new Vector.<Sprite>(sourceData.length, true);
			var tabsTitles:Vector.<String> = new Vector.<String>;
			var tabsIDs:Vector.<String> = new Vector.<String>;
			for each (var data:Object in sourceData) {
				tabsTitles.push(data.Name);
				tabsIDs.push(data.ID);
			}
			
			var tabs:TabBar = new TabBar(tabsTitles, width, 20, tabsIDs);
			addChild(tabs);
			
			loadTabData(tabsIDs[0]);
			
			tabs.addEventListener(TabEvent.SELECT, onTabSelect);
		}
		
		private function onTabSelect(e:TabEvent):void {
			if (e.index == selectedTabIndex) return;
			
			selectedTabIndex = e.index;
			if (panels[e.index]) {
				selectedPanel.visible = false;
				selectedPanel = panels[e.index];
				selectedPanel.visible = true;
			} else {
				loadTabData(e.id);
			}
		}
		
		private function loadTabData(tabID:String):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProductPage', {pageID: tabID});
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onTabDataLoaded);
		}
		
		private function onTabDataLoaded(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onTabDataLoaded);
			
			var panel:Gallery = new Gallery(e.data);
			
			var scroller:ScrollBar = new ScrollBar(new BaseScrollBar, panel, 150, ScrollBar.HORIZONTAL, 806);
			scroller.y = 225;
			
			var scrolledPanel:Sprite = new Sprite;
			panels[selectedTabIndex] = scrolledPanel;
			if (selectedPanel)
				selectedPanel.visible = false;
			selectedPanel = scrolledPanel;
			scrolledPanel.x = 10;
			scrolledPanel.y = 40;
			
			scrolledPanel.addChild(panel);
			scrolledPanel.addChild(scroller);
			addChild(scrolledPanel);
			
			panel.addEventListener(MouseEvent.CLICK, onItemClick);
		}
		
		private function onItemClick(e:MouseEvent):void {
			var con:JewServerConnector = new JewServerConnector;
			con.load('builderProduct', {id: e.target.data.id}, false);
			con.addEventListener(LoadEvent.LOAD_COMPLETE, onProductDataLoaded);
		}
		
		private function onProductDataLoaded(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onProductDataLoaded);
			
			var sourceStr:String = e.data as String;
			sourceStr = sourceStr.substring(1, sourceStr.length - 1);
			sourceStr = sourceStr.replace(/\\"/g, '"');
			
			var xml:XML = XML(sourceStr);
			if (!xml.product.@caption)
				return;
			
			var pgEvent:PageEvent = new PageEvent(PageEvent.PAGE_CHANGE, true);
			pgEvent.page = PagesLayer.BEADS_PAGE;
			pgEvent.productName = xml.product.@caption;
			
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
			pgEvent.coresetData = coresetData;
			
			var particlesData:Vector.<ParticleData> = new Vector.<ParticleData>;
			var part:ParticleData;
			for each (var element:XML in xml..element) {
				part = new ParticleData(element.@name, element.@price, element.@id, element.@type, element.@article, element.@realWidth, element.@isTransp == 'true', element.@centerFromTop);
				part.parameter = element.@parameter;
				pgEvent.particlesData.push(part);
			}
			dispatchEvent(pgEvent);
		}
	}
}