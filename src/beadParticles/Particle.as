package beadParticles {
	import events.LoadEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import interactive.InteractivePNGLite;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	public class Particle extends InteractivePNGLite {
		protected var _velocity:Number = 0;
		protected var _velocityBeforeExchange:Number = 0;
		protected var _prevAngle:Number;
		protected var _radius:Number;
		private var _angle:Number;
		
		private var _particleData:ParticleData;
		private var loadIndicator:Sprite;
		
		public function Particle(particleData:ParticleData = null):void {
			_particleData = particleData;
			init();
		}
		
		private function init():void {
			alphaTolerance = 0;
			exactShape = true;
			buttonMode = true;
			
			if (!_particleData)
				return;
			
			if (_particleData.bmd) {
				var skin:Bitmap = new Bitmap(_particleData.bmd);
				skin.x = -skin.width / 2;
				skin.y = -_particleData.centerFromTop;
				skin.smoothing = true;
				if (_particleData.isTransp)
					skin.blendMode = BlendMode.DARKEN;
				//skin.blendMode = BlendMode.MULTIPLY;
				setBitmap(skin);
			} else {
				loadSkin(_particleData.id);
			}
			_radius = _particleData.realWidth / 2;
		/*blendMode = BlendMode.DARKEN;
		   graphics.beginFill(0x99CCFF, .7);
		   graphics.drawCircle(0, 0, 40);
		 _radius = 40;*/
		}
		
		private function loadSkin(particleID:String):void {
			var loader:JewServerConnector = new JewServerConnector;
			loader.load('elementImages', {elementID: particleID, photoTypeID: 2}, false, URLLoaderDataFormat.BINARY);
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			loadIndicator.x = width / 2;
			loadIndicator.y = height / 2;
			loadIndicator.scaleX = loadIndicator.scaleY = .7;
			addChild(loadIndicator);
		}
		
		private function onLoadError(e:IOErrorEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			e.target.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			removeChild(loadIndicator);
			loadIndicator = null;
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			e.target.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			var loader:Loader = new Loader;
			loader.loadBytes(ByteArray(e.data));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
		}
		
		private function onParseComplete(e:Event):void {
			removeChild(loadIndicator);
			loadIndicator = null;
			
			mouseEnabled = true;
			var skin:Bitmap = Bitmap(e.target.content);
			_particleData.bmd = skin.bitmapData;
			skin.x = -skin.width / 2;
			skin.y = -_particleData.centerFromTop;
			skin.smoothing = true;
			if (_particleData.isTransp)
				skin.blendMode = BlendMode.DARKEN;
			setBitmap(skin);
		}
		
		public function initAngle(angle:Number):void {
			_angle = angle;
			_prevAngle = angle;
			_velocity = 0;
			_velocityBeforeExchange = 0;
		}
		
		public function get prevAngle():Number {
			return _prevAngle;
		}
		
		public function get velocity():Number {
			return _velocity;
		}
		
		public function get radius():Number {
			return _radius;
		}
		
		public function get angle():Number {
			return _angle;
		}
		
		public function set angle(value:Number):void {
			_angle = value;
		}
		
		public function get velocityBeforeExchange():Number {
			return _velocityBeforeExchange;
		}
		
		public function get particleData():ParticleData {
			return _particleData.clone();
		}
	}
}