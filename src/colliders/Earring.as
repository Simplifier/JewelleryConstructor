package colliders{
	import beadParticles.Bead;
	import beadParticles.DeadSpace;
	import beadParticles.Lock;
	import beadParticles.Particle;
	import com.greensock.TweenLite;
	import events.LoadEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import models.CoresetData;
	import models.DeadSpaceData;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	public class Earring extends Collider {
		private var length:Number = 200;
		private var majorRadius:int = 190;
		private var minorRadius:int = 185;
		
		private var currentParticle:Particle;
		private var particleIsSnapped:Boolean;
		private var particles:Vector.<Particle> = new Vector.<Particle>;
		private var beads:Vector.<Bead> = new Vector.<Bead>;
		private var locks:Vector.<Particle> = new Vector.<Particle>;
		
		private var loadIndicator:Sprite;
		
		public function Earring(coresetData:CoresetData):void {
			super(coresetData);
			realWidth = 400;
			//graphics.lineStyle(2);
			//graphics.drawEllipse(-majorRadius, -minorRadius, 2 * majorRadius, 2 * minorRadius);
			
			straightHeight = coresetData.straightHeight;
			majorRadius = coresetData.majorRadius;
			minorRadius = coresetData.minorRadius;
			
			addEventListener(Event.ENTER_FRAME, updateFrame);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			addChild(loadIndicator);
			
			var loader:JewServerConnector = new JewServerConnector;
			loader.load('elementImages', {elementID: coresetData.id, photoTypeID:3}, false, URLLoaderDataFormat.BINARY);
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
		}
		
		private function onLoadComplete(e:LoadEvent):void {
			e.target.removeEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			var loader:Loader = new Loader;
			loader.loadBytes(ByteArray(e.data));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onParseComplete);
		}
		
		private function onParseComplete(e:Event):void {
			removeChild(loadIndicator);
			loadIndicator = null;
			
			var loader:Loader = e.target.loader as Loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			//loader.width = realWidth;
			//loader.scaleY = loader.scaleX;
			loader.x = -loader.width / 2;
			loader.y = -straightHeight;
			coresetData.bmd = Bitmap(loader.content).bitmapData;
			Bitmap(loader.content).smoothing = true;
			addChild(loader);
			
			addDeadSpace(new DeadSpace(10), 180);
			addDeadSpace(new DeadSpace(10), -180);
			addDeadSpace(new DeadSpace(22), 89.7);
			addDeadSpace(new DeadSpace(22), -90);
			
			coresetData.deadSpaces.push(new DeadSpaceData(22, 89.7));
			coresetData.deadSpaces.push(new DeadSpaceData(22, -90));
		}
		
		private function addDeadSpace(particle:DeadSpace, angle:Number):void {
			particle.initAngle(angle);
			updateParticlePosition(particle);
			particles.push(particle);
			locks.push(particle);
			//addChild(particle);
		}
		
		override public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, updateFrame);
		}
		
		/**returns point situated on the bracelet
		 * @param parameter the angle in degrees
		 * */
		public function parameterToCoords(parameter:Number):Point {
			return new Point(0, parameter * length / 360 + 180);
		}
		
		/**returns the angle in degrees*/
		public function coordsToParameter(x:Number, y:Number):Number {
			return y * 360 / length - 180;
		}
		
		override public function addBeadHandling(bead:Bead):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			bead.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			bead.x = mouseX;
			bead.y = mouseY;
			addChild(bead);
			this.currentParticle = bead;
		
		}
		
		override public function addLockHandling(lock:Lock):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			lock.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			lock.x = mouseX;
			lock.y = mouseY;
			addChild(lock);
			this.currentParticle = lock;
		}
		
		private function onBallMouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			currentParticle = e.target as Particle;
			addChild(currentParticle);
			var i:String;
			for (i in particles) {
				if (particles[i] == currentParticle) {
					particles.splice(int(i), 1);
					break;
				}
			}
			for (i in beads) {
				if (beads[i] == currentParticle) {
					beads.splice(int(i), 1);
					break;
				}
			}
			for (i in locks) {
				if (locks[i] == currentParticle) {
					locks.splice(int(i), 1);
					break;
				}
			}
		}
		
		private function hasFreePlace(particle:Particle, angle:Number):Boolean {
			beads = beads.sort(compareParticles);
			
			var occupiedPlace:Number = 0;
			for each(var bead:Particle in beads) {
				occupiedPlace += getRadianLength(bead);
			}
			
			if (length - occupiedPlace > getRadianLength(particle) + 1) {
				return true;
			} else {
				return false;
			}
		}
		
		private function onMouseMove(e:MouseEvent):void {
			currentParticle.angle = coordsToParameter(mouseX, mouseY);
			if (Math.abs(mouseX) < 50 && mouseY > 0 && mouseY <= length)
				particleIsSnapped = hasFreePlace(currentParticle, currentParticle.angle);
			else
				particleIsSnapped = false;
			
			if (particleIsSnapped) {
				currentParticle.alpha = 1;
				TweenLite.to(currentParticle, .1, {x: 0, y: mouseY});
			} else {
				currentParticle.alpha = .5;
				TweenLite.to(currentParticle, .1, {x: mouseX, y: mouseY});
			}
			e.updateAfterEvent();
		}
		
		private function onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (!currentParticle)
				return;
			
			releaseParticle(currentParticle, particleIsSnapped);
			currentParticle = null;
		}
		
		override public function releaseParticle(particle:Particle, particleIsSnapped:Boolean):void {
			if (particleIsSnapped) {
				particle.mouseEnabled = true;
				particle.mouseChildren = true;
				TweenLite.killTweensOf(particle, true);
				distributeFrom(particle);
				particles.push(particle);
				if (particle is Bead) {
					beads.push(Bead(particle));
				} else if (particle is Lock) {
					locks.push(Lock(particle));
				}
				particle.initAngle(coordsToParameter(mouseX, mouseY));
			} else {
				TweenLite.to(particle, .3, {rotation: "-90", scaleX: 0, scaleY: 0, onComplete: removeChild, onCompleteParams: [particle]});
				particle.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			}
		}
		
		private function distributeFrom(particle:Particle):void {
			var partA:Particle;
			var partB:Particle;
			var i:int;
			var partALength:Number;
			var partBLength:Number;
			var endIndex:int = (lastBeadIndex + 1 < particles.length)?lastBeadIndex + 1:0;
			trace('part',particle.angle)
			
			trace(locks[firstLockIndex].angle)
			if (moveApart(locks[firstLockIndex], particle, true)) {
				trace(11111111)
				
				partA = particle;
				for (i = firstBeadIndex; i != endIndex; i = (i + 1 < particles.length)?i + 1:0 ) {
					if (!beads.length) break;
				
					partB = particles[i];
					
					partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
					partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
					if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
						partB.angle = partA.angle +  (partALength +  partBLength) / 2;
						updateParticlePosition(partB);
					} else break;
					partA = partB;
				}
			}
			
			var firstIndex:int = (firstBeadIndex > 0)?firstBeadIndex - 1:particles.length - 1;
			if (moveApart(locks[lastLockIndex], particle, false)) {
				trace(222222)
				if (!beads.length) return;
				
				partA = particle;
				for (i = lastBeadIndex; i != firstIndex; i = (i > 0)?i - 1:particles.length - 1 ) {
					partB = particles[i];
					
					partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
					partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
					if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
						partB.angle = partA.angle - (partALength +  partBLength) / 2;
						updateParticlePosition(partB);
					} else break;
					partA = partB;
				}
			}
			
			var start:int = -1;
			var startfound:Boolean;
			var parts:Vector.<Particle> = new Vector.<Particle>;
			for (i = firstBeadIndex; i <= lastBeadIndex; i++ ) {
				if (particle.angle < particles[i].angle && !startfound) {
					start = i;
					startfound = true;
					parts.push(particle);
				}
				parts.push(particles[i]);
			}
			if (start != -1) start -= firstBeadIndex;
			else parts.push(particle);
			
			var lock:Particle = locks[lastLockIndex];
			var lockLength:Number = getIntervalLength(getAngleInterval(new Point(lock.x, lock.y), lock.angle, lock.radius));
			partA = particle;
			if (start != -1)
			for (i = start + 1; i < parts.length; i++ ) {
				partB = parts[i];
				
				partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
				partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
				if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
					partB.angle = partA.angle +  (partALength +  partBLength) / 2;
					updateParticlePosition(partB);
				} else break;
				
				if (partBLength / 2 + lockLength / 2 > Math.abs(partB.angle-lock.angle)) {
					partA = lock;
					
					for (i = parts.length - 1; i >= 0; i-- ) {
						partB = parts[i];
						
						partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
						partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
						if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
							partB.angle = partA.angle - (partALength +  partBLength) / 2;
							updateParticlePosition(partB);
						} else break;
						
						partA = partB;
					}
					break;
				}
				
				partA = partB;
			}
			
			lock = locks[firstLockIndex];
			lockLength = getIntervalLength(getAngleInterval(new Point(lock.x, lock.y), lock.angle, lock.radius));
			partA = particle;
			if (start == -1) start = parts.length - 1;
			for (i = start - 1; i >= 0; i-- ) {
				partB = parts[i];
				
				partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
				partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
				if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
					partB.angle = partA.angle -  (partALength +  partBLength) / 2;
					updateParticlePosition(partB);
				} else break;
				
				if (partBLength / 2 + lockLength / 2 > Math.abs(partB.angle-lock.angle)) {
					partA = lock;
					
					for (i = 0; i < parts.length; i++ ) {
						partB = parts[i];
						
						partALength = getIntervalLength(getAngleInterval(new Point(partA.x, partA.y), partA.angle, partA.radius));
						partBLength = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
						if (partALength / 2 +  partBLength / 2 > Math.abs(partB.angle-partA.angle)) {
							partB.angle = partA.angle + (partALength +  partBLength) / 2;
							updateParticlePosition(partB);
						} else break;
						
						partA = partB;
					}
					break;
				}
				
				partA = partB;
			}
		}
		
		private function moveApart(lock:Particle, partB:Particle, clockwise:Boolean):Boolean {
			var sign:int;
			var dist:Number;
			if (clockwise) {
				sign = 1;
				if (partB.angle > lock.angle) {
					dist = partB.angle-lock.angle;
				} else {
					dist = (180 - lock.angle) + (partB.angle + 180);
				}
			} else {
				sign = -1;
				if (partB.angle > lock.angle) {
					dist = (180 - partB.angle) + (lock.angle + 180);
				} else {
					dist = lock.angle-partB.angle;
				}
			}
			
			var partBLength:Number = getIntervalLength(getAngleInterval(new Point(partB.x, partB.y), partB.angle, partB.radius));
			var lockLength:Number = getIntervalLength(getAngleInterval(new Point(lock.x, lock.y), lock.angle, lock.radius));
			if (partBLength / 2 + lockLength / 2 > dist) {
				partB.angle = lock.angle + sign * (partBLength + lockLength) / 2;
				updateParticlePosition(partB);
				
				return true;
			}
			
			return false;
		}
		
		private function updateFrame(e:Event):void {
			if (!beads.length)
				return;
			
			beads = beads.sort(compareParticles);
			particles = particles.sort(compareParticles);
			
			for each (var b:Bead in beads) {
				applyGravity(b);
				b.velocityBeforeExchange = b.velocity;
			}
			handleCollisions();
		}
		
		private function handleCollisions():void {
			var bead1st:Particle;
			var bead2nd:Particle;
			var bead1Interval:Vector.<Number>;
			var bead2Interval:Vector.<Number>;
			var necklacePnt:Point;
			var tempv:Number;
			var i:int;
			var j:int;
			var collisionsAreDetected:Boolean = true;
			var roundCounter:int = 0;
			
			while (collisionsAreDetected) {
				collisionsAreDetected = false;
				for (i = 0; i < particles.length; i++) {
					bead1st = particles[i];
					bead1Interval = getRadianInterval(new Point(bead1st.x, bead1st.y), bead1st.angle, bead1st.radius);
					if (bead1st.velocityBeforeExchange > 0) {
						if (i >= particles.length - 1)
							continue;
						
						bead2nd = particles[i + 1];
						bead2Interval = getRadianInterval(new Point(bead2nd.x, bead2nd.y), bead2nd.angle, bead2nd.radius);
						
						if (bead1st.angle - bead2nd.angle > .01 || bead1Interval[1] - bead2Interval[0] > .01) {
							collisionsAreDetected = true;
							
							if (bead2nd.velocityBeforeExchange >= 0)
								bead1st.angle -= bead1Interval[1] - bead2Interval[0];
							else {
								bead1st.angle -= (bead1Interval[1] - bead2Interval[0]) * Math.abs(bead1st.velocityBeforeExchange) / (Math.abs(bead1st.velocityBeforeExchange) + Math.abs(bead2nd.velocityBeforeExchange));
								bead2nd.angle += (bead1Interval[1] - bead2Interval[0]) * Math.abs(bead2nd.velocityBeforeExchange) / (Math.abs(bead1st.velocityBeforeExchange) + Math.abs(bead2nd.velocityBeforeExchange));
							}
							//if (bead1st.angle < bead1st.prevAngle) bead1st.angle = bead1st.prevAngle;
							//if (bead2nd.angle > bead2nd.prevAngle) bead2nd.angle = bead2nd.prevAngle;
							
							updateParticlePosition(bead1st);
							updateParticlePosition(bead2nd);
							
							if (!roundCounter) {
								if (bead1st is Lock || bead1st is DeadSpace) {
									Bead(bead2nd).velocity *= -.5;
								} else if (bead2nd is Lock || bead2nd is DeadSpace) {
									Bead(bead1st).velocity *= -.5;
								} else {
									tempv = bead1st.velocity;
									Bead(bead1st).velocity = bead2nd.velocity * .9;
									Bead(bead2nd).velocity = tempv * .9;
								}
							}
						}
					} else if (bead1st.velocityBeforeExchange < 0) {
						if (i <= 0)
							continue;
						bead2nd = particles[i - 1];
						bead2Interval = getRadianInterval(new Point(bead2nd.x, bead2nd.y), bead2nd.angle, bead2nd.radius);
						
						if (bead1st.angle - bead2nd.angle < -.01 || bead1Interval[0] - bead2Interval[1] < -.01) {
							collisionsAreDetected = true;
							
							if (bead2nd.velocityBeforeExchange <= 0)
								bead1st.angle += bead2Interval[1] - bead1Interval[0];
							else {
								bead1st.angle += (bead2Interval[1] - bead1Interval[0]) * Math.abs(bead1st.velocityBeforeExchange) / (Math.abs(bead1st.velocityBeforeExchange) + Math.abs(bead2nd.velocityBeforeExchange));
								bead2nd.angle -= (bead2Interval[1] - bead1Interval[0]) * Math.abs(bead2nd.velocityBeforeExchange) / (Math.abs(bead1st.velocityBeforeExchange) + Math.abs(bead2nd.velocityBeforeExchange));
							}
							//if (bead1st.angle > bead1st.prevAngle) bead1st.angle = bead1st.prevAngle;
							//if (bead2nd.angle < bead2nd.prevAngle) bead2nd.angle = bead2nd.prevAngle;
							
							updateParticlePosition(bead1st);
							updateParticlePosition(bead2nd);
							
							if (!roundCounter) {
								if (bead1st is Lock || bead1st is DeadSpace) {
									Bead(bead2nd).velocity *= -.5;
								} else if (bead2nd is Lock || bead2nd is DeadSpace) {
									Bead(bead1st).velocity *= -.5;
								} else {
									tempv = bead1st.velocity;
									Bead(bead1st).velocity = bead2nd.velocity * .9;
									Bead(bead2nd).velocity = tempv * .9;
								}
							}
						}
					}
				}
				roundCounter++;
				if (roundCounter > 100)
					break;
			}
			
			var bead:Bead;
			for each (var part:Particle in beads) {
				bead = Bead(part);
				bead.prevAngle = bead.angle;
			}
		}
		
		private function updateParticlePosition(particle:Particle):void {
			var necklacePnt:Point = parameterToCoords(particle.angle);
			particle.x = necklacePnt.x;
			particle.y = necklacePnt.y;
		}
		
		private function getRadianInterval(pnt:Point, angle:Number, radius:Number):Vector.<Number> {
			return new <Number>[coordsToParameter(0, pnt.y-radius), coordsToParameter(0,pnt.y+radius)];
		}
		
		private function getRadianLength(particle:Particle):Vector.<Number> {
			return particle.radius * 360 / length;
		}
		
		private function applyGravity(bead:Bead):void {
			bead.velocity += bead.acceleration;
			bead.angle += bead.velocity;
			
			updateParticlePosition(bead);
		}
		
		private function compareParticles(a:Particle, b:Particle):Number {
			return a.angle - b.angle;
		}
		
		override public function get particlesData():Vector.<ParticleData> {
			var res:Vector.<ParticleData> = new Vector.<ParticleData>;
			for each (var part:Particle in particles) {
				if (part.particleData) {
					res.push(part.particleData);
					part.particleData.parameter = part.angle;
				}
			}
			return res;
		}
	}
}