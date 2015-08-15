package models {
	import flash.display.BitmapData;
	
	public class ParticleData {
		private var _name:String;
		private var _price:Number;
		private var _id:String;
		private var _realWidth:Number;
		private var _isTransp:Boolean;
		private var _centerFromTop:Number;
		private var _article:String;
		public var bmd:BitmapData;
		private var _parameter:Number;
		private var _type:String;
		
		public function ParticleData(name:String, price:Number, id:String, type:String, article:String, realWidth:Number, isTransp:Boolean, centerFromTop:Number):void {
			_type = type;
			_article = article;
			_name = name;
			_price = price;
			_id = id;
			_realWidth = realWidth;
			_isTransp = isTransp;
			_centerFromTop = centerFromTop;
		}
		
		public function toString():String {
			return parameter + ' ' + name;
		}
		
		public function clone():ParticleData {
			var res:ParticleData = new ParticleData(name, price, id, type, article, realWidth, isTransp, centerFromTop);
			res.bmd = bmd;
			res.parameter = parameter;
			return res;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get price():Number {
			return _price;
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get centerFromTop():Number {
			return _centerFromTop;
		}
		
		public function get isTransp():Boolean {
			return _isTransp;
		}
		
		public function get realWidth():Number {
			return _realWidth;
		}
		
		public function get article():String {
			return _article;
		}
		
		public function get parameter():Number {
			return _parameter;
		}
		
		public function set parameter(value:Number):void {
			_parameter = value;
		}
		
		public function get type():String {
			return _type;
		}
	}
}