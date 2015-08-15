package beadParticles{
	import flash.display.Bitmap;
	import models.ParticleData;
	
	public class Lock extends Particle implements StaticBead {
		
		public function Lock(particleData:ParticleData):void {
			super(particleData);
			/*graphics.beginFill(0x99FFCC, .7);
			graphics.drawCircle(0, 0, 25);*/
			//_radius = 22;
		}
	}
}