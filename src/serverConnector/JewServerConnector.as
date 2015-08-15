package serverConnector {
	import by.blooddy.crypto.serialization.JSON;
	import events.LoadEvent;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import mpLoader.MultipartURLLoader;
	
	[Event(name="loadComplete",type="serverConnector.LoadEvent")]
	[Event(name="uploadComplete",type="serverConnector.LoadEvent")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	
	public class JewServerConnector extends EventDispatcher {
		private static var inited:Boolean;
		private static var url:String;
		
		public function JewServerConnector():void {
		
		}
		
		public static function init(url:String):void {
			JewServerConnector.url = (url.charAt(url.length - 1) == '/') ? url : url + '/';
			inited = true;
		}
		
		public function load(method:String, params:Object = null, decodeAnswer:Boolean = true, dataFormat:String = URLLoaderDataFormat.TEXT, requestMethod:String = URLRequestMethod.GET):void {
			if (!inited)
				throw new IllegalOperationError('Class isn`t initialized. Invoke the JewServerConnector.init() function at first.');
			
			var loader:MyURLLoader = new MyURLLoader;
			var vars:URLVariables = new URLVariables;
			var request:URLRequest = new URLRequest(url + method);
			request.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
			request.method = requestMethod;
			//var request:URLRequest = new URLRequest(url);
			
			//vars.method = method;
			for (var key:String in params) {
				vars[key] = params[key];
			}
			request.data = vars;
			
			loader.dataFormat = dataFormat;
			loader.decodeAnswer = decodeAnswer;
			
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.load(request);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			trace(e);
		}
		
		private function onLoadComplete(e:Event):void {
			MyURLLoader(e.target).removeEventListener(Event.COMPLETE, onLoadComplete);
			if(e.target.dataFormat == URLLoaderDataFormat.TEXT) trace(e.target.data);
			var event:LoadEvent = new LoadEvent(LoadEvent.LOAD_COMPLETE);
			if (e.target.decodeAnswer)
				event.data = JSON.decode(e.target.data);
			else
				event.data = e.target.data;
			dispatchEvent(event);
		}
		
		private function onLoadError(e:IOErrorEvent):void {
			MyURLLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			dispatchEvent(e);
		}
		
		public function uploadFiles(files:Array /*of ByteArray*/, method:String, params:Object = null):void {
			if (!inited)
				throw new IllegalOperationError('Class isn`t initialized. Invoke the JewServerConnector.init() function at first.');
			
			var loader:MultipartURLLoader = new MultipartURLLoader;
			
			//loader.addVariable('method', method);
			for (var key:String in params) {
				loader.addVariable(key, params[key]);
			}
			
			for (var index:String in files) {
				loader.addFile(files[index], 'image' + index + '.jpg', 'image' + index);
			}
			
			loader.addEventListener(Event.COMPLETE, onUploadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onUploadError);
			loader.load(url + method);
		}
		
		private function onUploadComplete(e:Event):void {
			MultipartURLLoader(e.target).removeEventListener(Event.COMPLETE, onUploadComplete);
			var event:LoadEvent = new LoadEvent(LoadEvent.UPLOAD_COMPLETE);
			event.data = e.target.loader.data;
			dispatchEvent(event);
		}
		
		private function onUploadError(e:IOErrorEvent):void {
			MultipartURLLoader(e.target).removeEventListener(IOErrorEvent.IO_ERROR, onUploadError);
			dispatchEvent(e);
		}
	}
}
import flash.net.URLLoader;
import flash.net.URLRequest;

class MyURLLoader extends URLLoader {
	public var decodeAnswer:Boolean;
	
	public function MyURLLoader(request:URLRequest = null):void {
		super(request);
	}
}