package vk {
	import by.blooddy.crypto.serialization.JSON;
	import events.LoadEvent;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import mpLoader.MultipartURLLoader;
	
	[Event(name="uploadComplete", type="events.LoadEvent")]
	public class VKApiWrapper extends EventDispatcher {
		public static const SERVER_GOT:String = 'serverGot';
		public static const SELF_UID:int = -1;
		
		private var connector:APIConnection;
		
		private static var _wallUploadServer:String;
		private static var wallPostSuccessCallbackIsAdded:Boolean;
		private var wallMessage:String;
		private var uid:int;
		
		public function VKApiWrapper(connector:APIConnection):void {
			this.connector = connector;
		}
		
		public function getSelfWallUploadServer():void {
			connector.api('photos.getWallUploadServer', {}, saveWallUploadServer, onApiRequestFail);
		}
		
		public function getWallUploadServer(uid:int):void {
			connector.api('photos.getWallUploadServer', {uid: uid}, saveWallUploadServer, onApiRequestFail);
		}
		
		private function saveWallUploadServer(data:Object):void {
			_wallUploadServer = data.upload_url;
			trace('server is got');
			dispatchEvent(new Event(SERVER_GOT));
		}
		
		public function uploadImage(image:ByteArray, targetUID:int = SELF_UID):void {
			if (!wallUploadServer)
				throw new IllegalOperationError('A server for uploading wasn`t got');
			this.wallMessage = wallMessage;
			uid = targetUID;
			
			var loader:MultipartURLLoader = new MultipartURLLoader;
			loader.addFile(image, 'photo.jpg', 'photo');
			loader.load(wallUploadServer);
			loader.addEventListener(Event.COMPLETE, dispatchUploadToWallAlbumComplete);
		}
		
		private function dispatchUploadToWallAlbumComplete(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, onUploadToWallAlbum);
			trace('photo data: ', e.target.loader.data);
			var ev:LoadEvent = new LoadEvent(LoadEvent.UPLOAD_COMPLETE);
			ev.data = JSON.decode(e.target.loader.data);
			dispatchEvent(ev);
		}
		
		public function saveImageOnWall(image:ByteArray, wallMessage:String = null, targetUID:int = SELF_UID):void {
			if (!wallUploadServer)
				throw new IllegalOperationError('A server for uploading wasn`t got');
			this.wallMessage = wallMessage;
			uid = targetUID;
			
			var loader:MultipartURLLoader = new MultipartURLLoader;
			loader.addFile(image, 'photo.jpg', 'photo');
			loader.load(wallUploadServer);
			loader.addEventListener(Event.COMPLETE, onUploadToWallAlbum);
		}
		
		private function onUploadToWallAlbum(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, onUploadToWallAlbum);
			
			var data:Object = JSON.decode(e.target.loader.data);
			trace('photo data: ', e.target.loader.data);
			saveWallPhoto(data);
		}
		
		public function saveWallPhoto(uploadedImageData:Object, message:String = null):void {
			if (message) wallMessage = message;
			
			if (uid == SELF_UID)
				connector.api('photos.saveWallPhoto', {server: uploadedImageData.server, photo: uploadedImageData.photo, hash: uploadedImageData.hash}, wallPost, onApiRequestFail);
			else
				connector.api('photos.saveWallPhoto', {server: uploadedImageData.server, photo: uploadedImageData.photo, hash: uploadedImageData.hash, uid: uid}, wallPost, onApiRequestFail);
		}
		
		private function wallPost(data:Object):void {
			if (!wallPostSuccessCallbackIsAdded) {
				wallPostSuccessCallbackIsAdded = true;
				ExternalInterface.addCallback('wallPostSuccess', wallPostSuccess);
			}
			if (uid == SELF_UID)
				ExternalInterface.call('wallPost', wallMessage, data[0].id);
			else
				ExternalInterface.call('wallPost', wallMessage, data[0].id, uid);
		}
		
		private function wallPostSuccess(data:Object):void {
			if(data)trace("Success wall.post post_id: " + data.post_id);
		}
		
		private function onApiRequestFail(data:Object):void {
			trace('vk error:', data.error_msg);
		}
		
		static public function get wallUploadServer():String {
			return _wallUploadServer;
		}
	}
}