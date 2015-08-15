package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NavigationMenu extends Sprite {
		[Embed(source='../img/left_active.png')]
		private var ActiveBtnSkin1:Class;
		[Embed(source='../img/left_inactive.png')]
		private var InactiveBtnSkin1:Class;
		[Embed(source='../img/right_active.png')]
		private var ActiveBtnSkin2:Class;
		[Embed(source='../img/right_inactive.png')]
		private var InactiveBtnSkin2:Class;
		
		private var _startPageBtn:NavigationBtn;
		private var _selectBaseBtn:NavigationBtn;
		private var _beadsPageBtn:NavigationBtn;
		private var _locksPageBtn:NavigationBtn;
		private var _buyPageBtn:NavigationBtn;
		
		private var _selectedBtn:NavigationBtn;
		
		public function NavigationMenu():void {
			_startPageBtn = new NavigationBtn(new ActiveBtnSkin1 as DisplayObject, new InactiveBtnSkin1 as DisplayObject, '1. Главная страница', 5);
			_selectBaseBtn = new NavigationBtn(new ActiveBtnSkin1 as DisplayObject, new InactiveBtnSkin1 as DisplayObject, "2. Основы", 71);
			_beadsPageBtn = new NavigationBtn(new ActiveBtnSkin1 as DisplayObject, new InactiveBtnSkin1 as DisplayObject, '3. Бусины', 71);
			_locksPageBtn = new NavigationBtn(new ActiveBtnSkin1 as DisplayObject, new InactiveBtnSkin1 as DisplayObject, '4. Замки', 71);
			_buyPageBtn = new NavigationBtn(new ActiveBtnSkin2 as DisplayObject, new InactiveBtnSkin2 as DisplayObject, '5. Купить и рассказать', 103);
			
			mouseEnabled = false;
			startPageBtn.mouseEnabled = false;
			selectBaseBtn.mouseEnabled = false;
			beadsPageBtn.mouseEnabled = false;
			locksPageBtn.mouseEnabled = false;
			buyPageBtn.mouseEnabled = false;
			
			selectBtn(startPageBtn);
			
			selectBaseBtn.x = 137;
			beadsPageBtn.x = 274;
			locksPageBtn.x = 411;
			buyPageBtn.x = 527;
			
			addChild(buyPageBtn);
			addChild(locksPageBtn);
			addChild(beadsPageBtn);
			addChild(selectBaseBtn);
			addChild(startPageBtn);
		}
		
		public function selectBtn(btn:NavigationBtn):void {
			if (btn == _selectedBtn) return;
			
			if (_selectedBtn){
				_selectedBtn.selected = false;
			}
			_selectedBtn = btn;
			btn.selected = true;
		}
		
		public function get selectedBtn():NavigationBtn {
			return _selectedBtn;
		}
		
		public function get startPageBtn():NavigationBtn {
			return _startPageBtn;
		}
		
		public function get selectBaseBtn():NavigationBtn {
			return _selectBaseBtn;
		}
		
		public function get beadsPageBtn():NavigationBtn {
			return _beadsPageBtn;
		}
		
		public function get locksPageBtn():NavigationBtn {
			return _locksPageBtn;
		}
		
		public function get buyPageBtn():NavigationBtn {
			return _buyPageBtn;
		}
	}
}