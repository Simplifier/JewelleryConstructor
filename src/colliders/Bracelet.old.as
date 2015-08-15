package {
	import com.greensock.TweenLite;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	public class Bracelet extends Collider {
		private var majorRadius:int = 150;
		private var minorRadius:int = 150;
		
		private var currentBead:Bead;
		private var beadIsSnapped:Boolean;
		private var beads:Vector.<Bead> = new Vector.<Bead>;
		
		private var currentLock:Lock;
		
		private var side:String;
		private const LEFT_SIDE:String = 'leftSide';
		private const RIGHT_SIDE:String = 'rightSide';
		
		public function Bracelet(url:String):void {
			realWidth = 300;
			//graphics.lineStyle(2);
			//graphics.drawEllipse(-majorRadius, -minorRadius, 2 * majorRadius, 2 * minorRadius);
			var loader:Loader = new Loader;
			loader.load(new URLRequest('pics/brclt.png'));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			
			addEventListener(Event.ENTER_FRAME, checkCollisions);
		}
		
		private function onLoadComplete(e:Event):void {
			var loader:Loader = e.target.loader as Loader;
			loader.x = -loader.width / 2;
			loader.y = -loader.height / 2;
			addChild(loader);
		}
		
		/**returns point situated on the bracelet
		 * @param parameter the angle in degrees
		 * */
		public function parameterToCoords(parameter:Number):Point {
			var res:Point = new Point;
			res.x = majorRadius * Math.cos(parameter * Math.PI / 180);
			res.y = minorRadius * Math.sin(parameter * Math.PI / 180);
			return res;
		}
		
		/**returns the angle in degrees*/
		public function coordsToParameter(x:Number, y:Number):Number {
			return Math.atan2(y, x) * 180 / Math.PI;
		}
		
		override public function addBeadHandling(bead:Bead):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			bead.x = mouseX;
			bead.y = mouseY;
			addChild(bead);
			this.currentBead = bead;
		}
		
		override public function addLockHandling(lock:Lock):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			//this.currentBead = lock;
		}
		
		private function onMouseMove(e:MouseEvent):void {
			var angle:Number = Math.atan2(mouseY, mouseX);
			currentBead.rotation = angle * 180 / Math.PI - 90;
			
			var dist:Number = Math.sqrt(mouseX * mouseX + mouseY * mouseY);
			var ellipseX:Number = majorRadius * Math.cos(angle);
			var ellipseY:Number = minorRadius * Math.sin(angle);
			var localRadius:Number = Math.sqrt(ellipseX * ellipseX + ellipseY * ellipseY);
			
			if (Math.abs(dist - localRadius) < 50)
				beadIsSnapped = true;
			else
				beadIsSnapped = false;
			
			if (beadIsSnapped) {
				currentBead.alpha = 1;
				TweenLite.to(currentBead, .1, {x: ellipseX, y: ellipseY});
			} else {
				currentBead.alpha = .5;
				TweenLite.to(currentBead, .1, {x: mouseX, y: mouseY});
			}
			
			e.updateAfterEvent();
		}
		
		private function onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (!currentBead)
				return;
			
			if (beadIsSnapped) {
				currentBead.initAngle(coordsToParameter(mouseX, mouseY));
				beads.push(currentBead);
				
				if (normalizeAngle(currentBead.angle - 270) < 180) {
					side = RIGHT_SIDE;
				} else {
					side = LEFT_SIDE;
				}
			} else {
				TweenLite.to(currentBead, .3, {rotation: "-90", scaleX: 0, scaleY: 0, onComplete: removeChild, onCompleteParams: [currentBead]});
			}
			currentBead = null;
		}
		
		private function checkCollisions(e:Event):void {
			if (!beads.length)
				return;
			
			beads = beads.sort(compareBeads);
			if (side == RIGHT_SIDE)
				beads.reverse();
			
			var bead1:Bead;
			var bead2:Bead;
			var tempv:Number;
			for each(var b:Bead in beads)applyGravity(b);
			for (var i:int = 0; i < beads.length - 1; i++) {
				
				for (var j:int = i + 1; j < beads.length; j++) {
					bead1 = beads[i];
					bead2 = beads[j];
					
					if ((bead1.x - bead2.x) * (bead1.x - bead2.x) + (bead1.y - bead2.y) * (bead1.y - bead2.y) < (bead1.radius + bead2.radius) * (bead1.radius + bead2.radius)) {
						var c:int = 0;
						while ((bead1.x - bead2.x) * (bead1.x - bead2.x) + (bead1.y - bead2.y) * (bead1.y - bead2.y) < (bead1.radius + bead2.radius) * (bead1.radius + bead2.radius)) {
							if (++c > 100)
								break;
							
							if (side == LEFT_SIDE) {
								if (normalizeAngle(bead1.angle - 270) < normalizeAngle(bead2.angle - 270)) {
									bead2.angle += .1;
								} else {
									bead1.angle += .1;
								}
							} else {
								if (normalizeAngle(bead1.angle - 270) < normalizeAngle(bead2.angle - 270)) {
									bead1.angle -= .1;
								} else {
									bead2.angle -= .1;
								}
							}
							
							bead1.x = majorRadius * Math.cos(bead1.angle * Math.PI / 180);
							bead1.y = minorRadius * Math.sin(bead1.angle * Math.PI / 180);
							bead2.x = majorRadius * Math.cos(bead2.angle * Math.PI / 180);
							bead2.y = minorRadius * Math.sin(bead2.angle * Math.PI / 180);
						}
						tempv = bead1.velocity;
						bead1.velocity = bead2.velocity * .9;
						bead2.velocity = tempv * .9;
						
						bead1.rotation = bead1.angle - 90;
						bead2.rotation = bead2.angle - 90;
					}
				}
			}
		}
		
		private function applyGravity(bead:Bead):void {
			var slideAngle:Number = normalizeAngle(bead.angle);
			if (slideAngle > 180)
				slideAngle -= 180;
			slideAngle = Math.abs(slideAngle - 90);
			trace(slideAngle<90);
			
			bead.velocity += bead.acceleration * Math.sin(slideAngle * Math.PI / 180);
			var friction:Number = ((bead.velocity > 0) ? 1 : -1) * Math.abs(bead.acceleration) * Math.cos(slideAngle * Math.PI / 180) * .3;
			bead.velocity = (Math.abs(bead.velocity) - Math.abs(friction)) > 0 ? bead.velocity - friction : 0;
			bead.angle += bead.velocity;
			
			var ellipsePnt:Point = parameterToCoords(bead.angle);
			
			bead.x = ellipsePnt.x;
			bead.y = ellipsePnt.y;
			bead.rotation = bead.angle - 90;
			
			var normAngle:Number = normalizeAngle(bead.angle);
			var prevNormAngle:Number = normalizeAngle(bead.prevAngle);
			
			if ((normAngle > 90 && normAngle < 180 && prevNormAngle < 90 && prevNormAngle > 0) || (normAngle < 90 && normAngle > 0 && prevNormAngle > 90 && prevNormAngle < 180) || (normAngle > 270 && normAngle < 360 && prevNormAngle < 270 && prevNormAngle > 180) || (normAngle < 270 && normAngle > 180 && prevNormAngle > 270 && prevNormAngle < 360)) {
				bead.acceleration *= -1;
			}
			
			bead.prevAngle = bead.angle;
		}
		
		private function normalizeAngle(degAngle:Number):Number {
			var res:Number = degAngle % 360;
			if (res < 0)
				res += 360;
			return res;
		}
		
		private function compareBeads(a:Bead, b:Bead):Number {
			return normalizeAngle(a.angle - 270) - normalizeAngle(b.angle - 270);
		}
	}
}
/*		private function checkCollisions(e:Event):void {
			if (!beads.length)
				return;
			
			beads = beads.sort(compareBeads);
			if (side == RIGHT_SIDE)
				beads.reverse();
			
			var bead1:Bead;
			var bead2:Bead;
			var tempv:Number;
			for each (var b:Bead in beads)
				applyGravity(b);
			for (var i:int = 0; i < beads.length - 1; i++) {
				
				for (var j:int = i + 1; j < beads.length; j++) {
					bead1 = beads[i];
					bead2 = beads[j];
					
					if ((bead1.x - bead2.x) * (bead1.x - bead2.x) + (bead1.y - bead2.y) * (bead1.y - bead2.y) < (bead1.radius + bead2.radius) * (bead1.radius + bead2.radius)) {
						var c:int = 0;
						while ((bead1.x - bead2.x) * (bead1.x - bead2.x) + (bead1.y - bead2.y) * (bead1.y - bead2.y) < (bead1.radius + bead2.radius) * (bead1.radius + bead2.radius)) {
							if (++c > 100)
								break;
							
							if (side == LEFT_SIDE) {
								if (normalizeAngle(bead1.angle - 270) < normalizeAngle(bead2.angle - 270)) {
									bead2.angle += .1;
								} else {
									bead1.angle += .1;
								}
							} else {
								if (normalizeAngle(bead1.angle - 270) < normalizeAngle(bead2.angle - 270)) {
									bead1.angle -= .1;
								} else {
									bead2.angle -= .1;
								}
							}
							
							bead1.x = majorRadius * Math.cos(bead1.angle * Math.PI / 180);
							bead1.y = minorRadius * Math.sin(bead1.angle * Math.PI / 180);
							bead2.x = majorRadius * Math.cos(bead2.angle * Math.PI / 180);
							bead2.y = minorRadius * Math.sin(bead2.angle * Math.PI / 180);
						}
						tempv = bead1.velocity;
						bead1.velocity = bead2.velocity * .9;
						bead2.velocity = tempv * .9;
						
						bead1.rotation = bead1.angle - 90;
						bead2.rotation = bead2.angle - 90;
					}
				}
			}
		}*/
		/*private function checkCollisions(e:Event):void {
			if (!beads.length)
				return;
			
			var bead1:Bead;
			var bead2:Bead;
			var bead1Interval:Vector.<Number>;
			var bead2Interval:Vector.<Number>;
			//var startIntersection:Number;
			//var endIntersection:Number;
			var necklacePnt:Point;
			var tempv:Number;
			for each (var b:Bead in beads)
				applyGravity(b);
			
			beads = beads.sort(compareBeads);
			if (side == RIGHT_SIDE)
				beads.reverse();
			
			for (var i:int = 0; i < beads.length - 1; i++) {
				
				for (var j:int = i + 1; j < beads.length; j++) {
					bead1 = beads[i];
					bead2 = beads[j];
					bead1Interval = getAngleInterval(bead1.angle, bead1.radius);
					bead2Interval = getAngleInterval(bead2.angle, bead2.radius);
					if (side == LEFT_SIDE) {
						if (bead1Interval[1] > bead2Interval[0]) {
							/*startIntersection = (bead1Interval[0] > bead2Interval[0] && bead1Interval[0] < bead2Interval[1])?bead1Interval[0]:bead2Interval[0];
							   endIntersection = (bead1Interval[1] > bead2Interval[0] && bead1Interval[1] < bead2Interval[1])?bead1Interval[1]:bead2Interval[1];
							   if (bead1Interval[0] > bead2Interval[0]) {
							   bead1.angle += endIntersection - startIntersection;
							   }else {
							   bead2.angle += endIntersection - startIntersection;
							 }*/
							bead2.angle = bead1Interval[1] + bead2.angle - bead2Interval[0];
							
							necklacePnt = parameterToCoords(bead1.angle);
							bead1.x = necklacePnt.x;
							bead1.y = necklacePnt.y;
							
							necklacePnt = parameterToCoords(bead2.angle);
							bead2.x = necklacePnt.x;
							bead2.y = necklacePnt.y;
							
							if (bead1.y < 0) {
								bead1.rotation = (bead1.x < 0) ? 90 : -90;
							} else {
								bead1.rotation = bead1.angle;
							}
							if (bead2.y < 0) {
								bead2.rotation = (bead2.x < 0) ? 90 : -90;
							} else {
								bead2.rotation = bead2.angle;
							}
							
							tempv = bead1.velocity;
							bead1.velocity = bead2.velocity * .9;
							bead2.velocity = tempv * .9;
							//bead1.velocity = (bead1.velocity+bead2.velocity)/2;
							//bead2.velocity = bead1.velocity;
							//tempv = bead2.velocity;
							//bead2.velocity = (bead1.velocity + bead2.velocity + .5 * (bead1.velocity - bead2.velocity)) / 2;
							//bead1.velocity = bead2.velocity - .5 * (bead1.velocity - tempv);
						}
					}else {
						if (bead1Interval[0] < bead2Interval[1]) {
							bead2.angle = bead1Interval[0] + bead2.angle - bead2Interval[1];
							
							necklacePnt = parameterToCoords(bead1.angle);
							bead1.x = necklacePnt.x;
							bead1.y = necklacePnt.y;
							
							necklacePnt = parameterToCoords(bead2.angle);
							bead2.x = necklacePnt.x;
							bead2.y = necklacePnt.y;
							
							if (bead1.y < 0) {
								bead1.rotation = (bead1.x < 0) ? 90 : -90;
							} else {
								bead1.rotation = bead1.angle;
							}
							if (bead2.y < 0) {
								bead2.rotation = (bead2.x < 0) ? 90 : -90;
							} else {
								bead2.rotation = bead2.angle;
							}
							
							tempv = bead1.velocity;
							bead1.velocity = bead2.velocity * .9;
							bead2.velocity = tempv * .9;
							//bead1.velocity = (bead1.velocity+bead2.velocity)/2;
							//bead2.velocity = bead1.velocity;
							//tempv = bead2.velocity;
							//bead2.velocity = (bead1.velocity + bead2.velocity + .5 * (bead1.velocity - bead2.velocity)) / 2;
							//bead1.velocity = bead2.velocity - .5 * (bead1.velocity - tempv);
						}
					}
				}
			}
		}*/
		/*private function hasFreePlace(particle:Particle, angle:Number):Boolean {
			locks = locks.sort(compareParticles);
			particles = particles.sort(compareParticles);
			
			var tempVector:Vector.<Number>;
			var particleInterval:Vector.<Number> = getAngleInterval(parameterToCoords(angle), angle, particle.radius);
			var i:String;
			var startAngle:Number;
			var endAngle:Number;
			var startLock:Particle;
			var endLock:Particle;
			var startIsFound:Boolean;
			var space:Number;
			var occupiedSpace:Number = 0;
			trace(locks.length);
			if (locks.length == 0) {
				space = 360;
				for (i in particles) {
					tempVector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
					occupiedSpace += getVerifiedIntervalLength(particles[i].angle, tempVector);
				}
			} else if (locks.length == 1) {
				tempVector = getAngleInterval(new Point(locks[0].x, locks[0].y), locks[0].angle, locks[0].radius);
				space = 360 - getVerifiedIntervalLength(locks[0].angle, tempVector);
				for (i in particles) {
					if (particles[i] is Bead) {
						tempVector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
						occupiedSpace += getVerifiedIntervalLength(particles[i].angle, tempVector);
					}
				}
			} else {
				for (i in locks) {
					if (locks[i].angle > angle) {
						if (int(i) == 0) {
							startLock = locks[locks.length - 1];
							endLock = locks[i];
							startAngle = getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius)[1];
							endAngle = getAngleInterval(new Point(endLock.x, endLock.y), endLock.angle, endLock.radius)[0];
							//trace(1, startAngle, endAngle, startLock, endLock, getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius));
							space = (180 - startAngle) + (endAngle + 180);
						} else {
							startLock = locks[int(i) - 1];
							endLock = locks[i];
							startAngle = getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius)[1];
							endAngle = getAngleInterval(new Point(endLock.x, endLock.y), endLock.angle, endLock.radius)[0];
							space = endAngle - startAngle;
						}
						break;
					}
				}
				if (!startLock) {
					startLock = locks[locks.length - 1];
					endLock = locks[0];
					startAngle = getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius)[1];
					endAngle = getAngleInterval(new Point(endLock.x, endLock.y), endLock.angle, endLock.radius)[0];
					//trace(1, startAngle, endAngle, startLock, endLock, getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius));
					space = (180 - startAngle) + (endAngle + 180);
				}
				for (i in particles) {
					if (particles[i] == startLock) {
						startIsFound = true;
					} else if (particles[i] == endLock) {
						break;
					} else if (startIsFound) {
						tempVector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
						occupiedSpace += getVerifiedIntervalLength(particles[i].angle, tempVector);
					}
				}
				trace(space, occupiedSpace);
			}
			if (space - occupiedSpace > 2 + getVerifiedIntervalLength(angle, particleInterval))
				return true;
			else
				return false;
		}*/