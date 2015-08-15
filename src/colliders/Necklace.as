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
	
	public class Necklace extends Collider {
		private var straightHeight:Number = 170;
		private var majorRadius:int = 190;
		private var minorRadius:int = 185;
		
		private var currentParticle:Particle;
		private var particleIsSnapped:Boolean;
		private var particles:Vector.<Particle> = new Vector.<Particle>;
		private var beads:Vector.<Bead> = new Vector.<Bead>;
		private var locks:Vector.<Particle> = new Vector.<Particle>;
		
		private var loadIndicator:Sprite;
		
		public function Necklace(coresetData:CoresetData):void {
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
			var res:Point = new Point;
			
			if (parameter >= 90) {
				res.x = -majorRadius;
				res.y = -(parameter - 90) / 90 * straightHeight;
			} else if (parameter < -90) {
				res.x = majorRadius;
				res.y = -(90 - (parameter + 180)) / 90 * straightHeight;
			} else {
				res.x = majorRadius * Math.cos(parameter * Math.PI / 180 + Math.PI / 2);
				res.y = minorRadius * Math.sin(parameter * Math.PI / 180 + Math.PI / 2);
			}
			return res;
		}
		
		/**returns the angle in degrees*/
		public function coordsToParameter(x:Number, y:Number):Number {
			if (y < 0) {
				if (x < 0) {
					return 90 - y / straightHeight * 90;
				} else {
					return -180 + (straightHeight + y) / straightHeight * 90;
				}
			} else
				return Math.atan2(y, x) * 180 / Math.PI - 90;
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
			locks = locks.sort(compareParticles);
			particles = particles.sort(compareParticles);
			
			var vector:Vector.<Number>;
			var i:String;
			var startAngle:Number;
			var endAngle:Number;
			var startLock:Particle;
			var endLock:Particle;
			var startIsFound:Boolean;
			var space:Number;
			var occupiedSpace:Number = 0;
			for (i in locks) {
				if (locks[i].angle > angle) {
					startLock = locks[int(i) - 1];
					endLock = locks[i];
					startAngle = getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius)[1];
					endAngle = getAngleInterval(new Point(endLock.x, endLock.y), endLock.angle, endLock.radius)[0];
					break;
				}
			}
			for (i in particles) {
				if (particles[i] == startLock) {
					startIsFound = true;
				} else if (particles[i] == endLock) {
					break;
				} else if (startIsFound) {
					vector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
					occupiedSpace += vector[1] - vector[0];
				}
			}
			space = endAngle - startAngle;
			vector = getAngleInterval(parameterToCoords(angle), angle, particle.radius);
			if (space - occupiedSpace > 2 + vector[1] - vector[0])
				return true;
			else
				return false;
		}
		
		private function onMouseMove(e:MouseEvent):void {
			var angle:Number = coordsToParameter(mouseX, mouseY);
			if (mouseY < 0) {
				if (Math.abs(majorRadius - Math.abs(mouseX)) < 50)
					particleIsSnapped = hasFreePlace(currentParticle, angle);
				else
					particleIsSnapped = false;
				if (mouseY < -straightHeight + 1)
					particleIsSnapped = false;
				
				//currentBead.rotation = (mouseX < 0) ? 90 : -90;
				TweenLite.to(currentParticle, .1, {rotation: (mouseX < 0) ? 90 : -90});
				if (particleIsSnapped) {
					currentParticle.alpha = 1;
					TweenLite.to(currentParticle, .1, {x: (mouseX < 0) ? -majorRadius : majorRadius, y: mouseY});
				} else {
					currentParticle.alpha = .5;
					TweenLite.to(currentParticle, .1, {x: mouseX, y: mouseY});
				}
			} else {
				//currentBead.rotation = angle * 180 / Math.PI - 90;
				TweenLite.to(currentParticle, .1, {rotation: angle});
				
				var dist:Number = Math.sqrt(mouseX * mouseX + mouseY * mouseY);
				var neclacePnt:Point = parameterToCoords(angle);
				var localRadius:Number = Math.sqrt(neclacePnt.x * neclacePnt.x + neclacePnt.y * neclacePnt.y);
				
				if (Math.abs(dist - localRadius) < 50)
					particleIsSnapped = hasFreePlace(currentParticle, angle);
				else
					particleIsSnapped = false;
				
				if (particleIsSnapped) {
					currentParticle.alpha = 1;
					TweenLite.to(currentParticle, .1, {x: neclacePnt.x, y: neclacePnt.y, overwrite: false});
				} else {
					currentParticle.alpha = .5;
					TweenLite.to(currentParticle, .1, {x: mouseX, y: mouseY, overwrite: false});
				}
			}
			//if (particleIsSnapped)trace(coordsToParameter(mouseX, mouseY))
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
				particles.push(particle);
				particle.initAngle(coordsToParameter(mouseX, mouseY));
				if (particle is Bead) {
					trace('init angle:', coordsToParameter(mouseX, mouseY))
					beads.push(Bead(particle));
				} else if (particle is Lock) {
					locks.push(Lock(particle));
				}
			} else {
				TweenLite.to(particle, .3, {rotation: "-90", scaleX: 0, scaleY: 0, onComplete: removeChild, onCompleteParams: [particle]});
				particle.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			}
		}
		
		private function updateFrame(e:Event):void {
			if (!beads.length)
				return;
			
			beads = beads.sort(compareParticles);
			particles = particles.sort(compareParticles);
			
			var b:Bead;
			for each (b in beads) {
				applyGravity(b);
				b.velocityBeforeExchange = b.velocity;
			}
			//trace(particles)
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
					bead1Interval = getAngleInterval(new Point(bead1st.x, bead1st.y), bead1st.angle, bead1st.radius);
					if (bead1st.velocityBeforeExchange > 0) {
						if (i >= particles.length - 1)
							continue;
						
						bead2nd = particles[i + 1];
						bead2Interval = getAngleInterval(new Point(bead2nd.x, bead2nd.y), bead2nd.angle, bead2nd.radius);
						
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
						bead2Interval = getAngleInterval(new Point(bead2nd.x, bead2nd.y), bead2nd.angle, bead2nd.radius);
						
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
			//trace(roundCounter);
			
			i = 0;
			var part:Particle;
			var bead:Bead;
			for each (part in particles) {
				if (part is Bead) {
					bead = Bead(part);
					if (bead.angle < 0)
						bead.acceleration = Math.abs(bead.acceleration);
					else
						bead.acceleration = -Math.abs(bead.acceleration);
					bead.prevAngle = bead.angle;
				}
			}
			//trace(beads[0].angle)
		}
		
		private function updateParticlePosition(particle:Particle):void {
			var necklacePnt:Point = parameterToCoords(particle.angle);
			particle.x = necklacePnt.x;
			particle.y = necklacePnt.y;
			
			if (particle.y < 0) {
				particle.rotation = (particle.x < 0) ? 90 : -90;
			} else {
				particle.rotation = particle.angle;
			}
		}
		
		private function getAngleInterval(pnt:Point, angle:Number, radius:Number):Vector.<Number> {
			//var pnt:Point = parameterToCoords(angle);
			var topPnt:Point;
			var botPnt:Point;
			if (angle <= -90) {
				topPnt = new Point(pnt.x, pnt.y - radius);
				botPnt = new Point(pnt.x, pnt.y + radius);
				return new <Number>[coordsToParameter(topPnt.x, topPnt.y), coordsToParameter(botPnt.x, botPnt.y)];
			} else if (angle >= 90) {
				topPnt = new Point(pnt.x, pnt.y - radius);
				botPnt = new Point(pnt.x, pnt.y + radius);
				return new <Number>[coordsToParameter(botPnt.x, botPnt.y), coordsToParameter(topPnt.x, topPnt.y)];
			} else {
				var pnt1:Point = new Point(10, minorRadius * minorRadius / pnt.y * (1 - pnt.x / majorRadius / majorRadius * (pnt.x + 10)) - pnt.y);
				var pnt2:Point = new Point(-10, minorRadius * minorRadius / pnt.y * (1 - pnt.x / majorRadius / majorRadius * (pnt.x - 10)) - pnt.y);
				
				var length:Number = Math.sqrt(pnt1.x * pnt1.x + pnt1.y * pnt1.y);
				
				var leftAngle:Number = coordsToParameter(pnt.x + pnt1.x / length * radius, pnt.y + pnt1.y / length * radius);
				var rightAngle:Number = coordsToParameter(pnt.x + pnt2.x / length * radius, pnt.y + pnt2.y / length * radius);
				
				return new <Number>[Math.min(leftAngle, rightAngle), Math.max(leftAngle, rightAngle)];
			}
		}
		
		private function applyGravity(bead:Bead):void {
			var necklacePnt:Point;
			if (bead.y < 0) {
				if (bead.y < -straightHeight) {
					bead.y = -straightHeight;
					bead.velocity *= -1;
				}
				bead.x = (bead.x < 0) ? -majorRadius : majorRadius;
				bead.velocity += bead.acceleration;
				bead.angle += bead.velocity;
				
				necklacePnt = parameterToCoords(bead.angle);
				
				bead.x = necklacePnt.x;
				bead.y = necklacePnt.y;
				
				//if(bead.x < 0)bead.y -= bead.velocity*Math.PI*(majorRadius+minorRadius)/360;/*multiply the velocity by a lenght of 1 degree*/
				//else bead.y += bead.velocity*Math.PI*(majorRadius+minorRadius)/360;
				bead.rotation = (bead.x < 0) ? 90 : -90;
			} else {
				var slideAngle:Number = bead.angle;
				if (slideAngle > 90)
					slideAngle -= 180;
				else if (slideAngle < -90)
					slideAngle += 180;
				slideAngle = Math.abs(slideAngle);
				
				bead.velocity += bead.acceleration * Math.sin(slideAngle * Math.PI / 180);
				var friction:Number = ((bead.velocity > 0) ? 1 : -1) * Math.abs(bead.acceleration) * Math.cos(slideAngle * Math.PI / 180) * .3;
				bead.velocity = (Math.abs(bead.velocity) - Math.abs(friction)) > 0 ? bead.velocity - friction : 0;
				bead.angle += bead.velocity;
				
				necklacePnt = parameterToCoords(bead.angle);
				
				bead.x = necklacePnt.x;
				bead.y = necklacePnt.y;
				bead.rotation = bead.angle;
				
				/*if ((bead.angle > 0 && bead.angle < 90 && bead.prevAngle < 0 && bead.prevAngle > -90) || (bead.angle < 0 && bead.angle > -90 && bead.prevAngle > 0 && bead.prevAngle < 90)) {
				   bead.acceleration *= -1;
				 }*/
			}
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