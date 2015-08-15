package models{
	public class OrderData {
		public var productName:String;
		public var customer:CustomerData = new CustomerData;
		
		public function OrderData():void {
			
		}
	}
}

class CustomerData {
	public var address:String;
	public var email:String;
	public var phone:String;
	public var name:String;
	
	public function CustomerData():void {
		
	}
}