package nt {
	/**
	 * ...
	 * @author Leo
	 */
	public class NumberText {
		private var nominativeSingular:String;
		private var genitiveSingular:String;
		private var genitivePlural:String;
		
		public function NumberText(nominativeSingular:String, genitiveSingular:String, genitivePlural:String) {
			this.nominativeSingular = nominativeSingular;
			this.genitiveSingular = genitiveSingular;
			this.genitivePlural = genitivePlural;
		}
		
		public function getCase(num:Number):String {
			if (int(num) != num) return  genitiveSingular;
			
			num = Math.abs(int(num)) % 100;
			var units:int = num % 10;
			
			if (num > 10 && num < 20) {
				return genitivePlural;
			}
			
			if (units == 1) {
				return nominativeSingular;
			}
			
			if (units >= 2 && units <= 4) {
				return genitiveSingular;
			}
			
			else return genitivePlural;
		}
	}
}