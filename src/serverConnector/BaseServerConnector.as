package serverConnector {
	import by.blooddy.crypto.serialization.JSON;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	import mpLoader.MultipartURLLoader;
	
	public dynamic class BaseServerConnector extends Proxy implements IEventDispatcher {
		private var dispatcher:EventDispatcher;
		
		private static var inited:Boolean;
		private static var url:String;
		
		public function BaseServerConnector():void {
			dispatcher = new EventDispatcher(this);
		}
		
		public static function init(url:String):void {
			BaseServerConnector.url = url;
			inited = true;
			trace('url of the server:', url);
		}

		override flash_proxy function callProperty(methodName:*, ... args):* {
			var params:Object = { };
			var i:String;
			var prop:String;
			if (methodName.toString().substr(0, 3) == 'get') {
				for (i in args ) {
					for (prop in args[i]) {
						//здесь имя единственного свойства объекта args[i] записалось в prop
					}
					params[prop] = args[i][prop];
				}
				download.apply(this, [methodName, params]);
			}else if(methodName.toString().substr(0, 4) == 'send'){
				for (i in args ) {
					for (prop in args[i]) {
						//здесь имя единственного свойства объекта args[i] записалось в prop
					}
					params[prop] = args[i][prop];
				}
				upload.apply(this, [methodName, params]);
			}
		}
		
		public function download(method:String, params:Object = null):void {
			if (!inited) throw new IllegalOperationError('Class isn`t initialized. Invoke the BaseServerConnector.init() function at first.');
			
			var loader:URLLoader = new URLLoader;
			var vars:URLVariables = new URLVariables;
			var request:URLRequest = new URLRequest(url);
			
			vars.method = method;
			for (var key:String in params) {
				vars[key] = params[key];
			}
			request.data = vars;
			
			loader.addEventListener(Event.COMPLETE, onDownloadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			loader.load(request);
		}
		
		private function onDownloadComplete(e:Event):void {
			var event:LoadEvent = new LoadEvent(LoadEvent.DOWNLOAD_COMPLETE);
			event.data = JSON.decode(e.target.data);
			dispatchEvent(event);
		}
		
		private function onDownloadError(e:Event):void {
			dispatchEvent(e);
		}
		
		public function upload(files:Array/*of ByteArray*/, method:String, params:Object=null):void {
			if (!inited) throw new IllegalOperationError('Class isn`t initialized. Invoke the BaseServerConnector.init() function at first.');
			
			var loader:MultipartURLLoader = new MultipartURLLoader;
			
			loader.addVariable('method', method);
			for (var key:String in params) {
				loader.addVariable(key, params[key]);
			}
			
			for (var index:String in files) {
				loader.addFile(files[index], 'image' + index + '.png', 'image' + index);
			}
			
			loader.addEventListener(Event.COMPLETE, onUploadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onUploadError);
			loader.load(url);
		}
		
		private function onUploadComplete(e:Event):void {
			var event:LoadEvent = new LoadEvent(LoadEvent.UPLOAD_COMPLETE);
			event.data = e.target.loader.data;
			dispatchEvent(event);
		}
		
		private function onUploadError(e:Event):void {
			dispatchEvent(e);
		}
        
		//--------------------------------------
		//event dispatcher`s methods
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
	}
}