package beadParticles{
	
	public class DeadSpace extends Particle implements StaticBead {
		
		public function DeadSpace(width:Number):void {
			//graphics.beginFill(0xaaaaaa, .7);
			//graphics.beginFill(0xff0000, .3);
			graphics.drawCircle(0, 0, width/2);
			_radius = width/2;
		}
	}
}