package models{
	import flash.display.BitmapData;
	
	public class CoresetData {
		private var _name:String;
		private var _id:String;
		private var _type:String;
		private var _price:Number;
		public var article:String;
		public var dontBuyBase:Boolean;
		public var size:String;
		public var bmd:BitmapData;
		
		public var straightHeight:Number;
		public var majorRadius:int;
		public var minorRadius:int;
		public var deadSpaces:Vector.<DeadSpaceData> = new Vector.<DeadSpaceData>;
		public var claspWidth:Number;
		
		public function CoresetData(type:String, name:String = null, id:String = null):void {
			_name = name;
			_id = id;
			_type = type;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get price():Number {
			return _price;
		}
		
		public function set price(value:Number):void {
			_price = value;
		}
		
		public function get type():String {
			return _type;
		}
	}
}