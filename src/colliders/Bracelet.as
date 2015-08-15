package colliders{
	import beadParticles.Bead;
	import beadParticles.DeadSpace;
	import beadParticles.Lock;
	import beadParticles.Particle;
	import beadParticles.StaticBead;
	import com.greensock.TweenLite;
	import events.ColliderEvent;
	import events.LoadEvent;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoaderDataFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import models.CoresetData;
	import models.DeadSpaceData;
	import models.ParticleData;
	import serverConnector.JewServerConnector;
	
	public class Bracelet extends Collider {
		private var majorRadius:int;
		private var minorRadius:int;
		private var claspInterval:Vector.<Number>;
		
		private var currentParticle:Particle;
		private var particleIsSnapped:Boolean;
		private var particles:Vector.<Particle> = new Vector.<Particle>;
		private var beads:Vector.<Bead> = new Vector.<Bead>;
		private var locks:Vector.<Particle> = new Vector.<Particle>;
		private var loadIndicator:Sprite;
		
		private var debugField:TextField = new TextField;
		private var tformat:TextFormat = new TextFormat('Arial', 14);
		
		public function Bracelet(coresetData:CoresetData):void {
			super(coresetData);
			init();
		}
		
		private function init():void {
			realWidth = 300;
			//graphics.lineStyle(2);
			//graphics.drawEllipse(-majorRadius, -minorRadius, 2 * majorRadius, 2 * minorRadius);
			
			coresetData.claspWidth = 80;
			majorRadius = coresetData.majorRadius;
			minorRadius = coresetData.minorRadius;
			claspInterval = getAngleInterval(new Point(0, -minorRadius), -180, coresetData.claspWidth / 2);
			//graphics.lineStyle(2);
			//graphics.drawCircle(0, -minorRadius, coresetData.claspWidth/2);
			
			addEventListener(Event.ENTER_FRAME, updateFrame);
			
			loadIndicator = new CircleLoadIndicator;
			loadIndicator.mouseEnabled = false;
			addChild(loadIndicator);
			
			var claspLength:Number = getIntervalLength(claspInterval);
			var claspDiam:Number = Point.distance(parameterToCoords(178 - (claspLength - 4) / 2), parameterToCoords(178));
			addDeadSpace(new DeadSpace(claspDiam), -178 + (claspLength - 4) / 4);
			addDeadSpace(new DeadSpace(claspDiam), 178 - (claspLength - 4) / 4);
			for each(var deadSpace:DeadSpaceData in coresetData.deadSpaces) {
				//addDeadSpace(new DeadSpace(deadSpace.width), deadSpace.parameter);
			}
			
			var loader:JewServerConnector = new JewServerConnector;
			loader.load('elementImages', {elementID: coresetData.id, photoTypeID:3}, false, URLLoaderDataFormat.BINARY);
			loader.addEventListener(LoadEvent.LOAD_COMPLETE, onLoadComplete);
			
			debugField.defaultTextFormat = tformat;
			debugField.textColor = 0x666666;
			debugField.autoSize = TextFieldAutoSize.LEFT;
			debugField.x = 80;
			debugField.y = 230;
			addChild(debugField);
			//addEventListener(Event.ENTER_FRAME, updateDebugInfo);
		}
		
		private function updateDebugInfo(e:Event):void {
			debugField.text = '[' + mouseX + ', ' + mouseY + '] ' +int(100 * coordsToParameter(mouseX, mouseY)) / 100 + '°';
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
			loader.x = -loader.width / 2;
			loader.y = -loader.height / 2;
			coresetData.bmd = Bitmap(loader.content).bitmapData;
			addChild(loader);
			
			for each(var particle:Particle in particles) {
				addChild(particle);
			}
			//addDeadSpace(new DeadSpace(76), 70);
		}
		
		private function addDeadSpace(particle:DeadSpace, angle:Number):void {
			particle.initAngle(angle);
			updateParticlePosition(particle);
			particles.push(particle);
			locks.push(particle);
			addChild(particle);
		}
		
		override public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, updateFrame);
		}
		
		/**returns point situated on the bracelet
		 * @param parameter the angle in degrees
		 * */
		public function parameterToCoords(parameter:Number):Point {
			var res:Point = new Point;
			
			res.x = majorRadius * Math.cos(parameter * Math.PI / 180 + Math.PI / 2);
			res.y = minorRadius * Math.sin(parameter * Math.PI / 180 + Math.PI / 2);
			return res;
		}
		
		/**returns the angle in degrees*/
		public function coordsToParameter(x:Number, y:Number):Number {
			var res:Number = Math.atan2(y, x) * 180 / Math.PI - 90;
			if (res < -180)
				res += 360;
			return res;
		}
		
		override public function addBeadHandling(bead:Bead):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			bead.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			bead.mouseEnabled = false;
			bead.mouseChildren = false;
			bead.x = mouseX;
			bead.y = mouseY;
			addChild(bead);
			currentParticle = bead;
		}
		
		override public function addLockHandling(lock:Lock):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			lock.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			lock.mouseEnabled = false;
			lock.mouseChildren = false;
			lock.x = mouseX;
			lock.y = mouseY;
			addChild(lock);
			currentParticle = lock;
		}
		
		override public function threadBead(bead:Bead, parameter:Number = NaN):void {
			bead.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			if (isNaN(parameter)) {
				var placefound:Boolean;
				locks = locks.sort(compareParticles);
				var beadLength:Number = getIntervalLength(getAngleInterval(new Point(0, minorRadius), 0, bead.radius));
				for (var i:int = 0; i < locks.length - 1; i++ ) {
					var cpartLength:Number = getIntervalLength(getAngleInterval(new Point(locks[i].x, locks[i].y), locks[i].angle, locks[i].radius));
					bead.angle = locks[i].angle + (cpartLength + beadLength) / 2;
					updateParticlePosition(bead);
					
					if (hasFreeSpace(bead, bead.angle)) {
						releaseParticle(bead, true);
						addChild(bead);
						placefound = true;
						return;
					}
				}
				if (!placefound) {
					bead.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
					trace('места не найдено');
				}
			} else {
				bead.rotation = parameter;
				bead.angle = parameter;
				bead.x = parameterToCoords(parameter).x;
				bead.y = parameterToCoords(parameter).y;
				addChild(bead);
				
				releaseParticle(bead, true);
			}
		}
		
		override public function threadLock(lock:Lock, parameter:Number = NaN):void {
			lock.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			
			if (isNaN(parameter)) {
				var placefound:Boolean;
				locks = locks.sort(compareParticles);
				var lockLength:Number = getIntervalLength(getAngleInterval(new Point(0, minorRadius), 0, lock.radius));
				for (var i:int = 0; i < locks.length - 1; i++ ) {
					var cpartLength:Number = getIntervalLength(getAngleInterval(new Point(locks[i].x, locks[i].y), locks[i].angle, locks[i].radius));
					lock.angle = locks[i].angle + (cpartLength + lockLength) / 2;
					updateParticlePosition(lock);
					
					if (hasFreeSpace(lock, lock.angle)) {
						releaseParticle(lock, true);
						addChild(lock);
						placefound = true;
						return;
					}
				}
				if (!placefound) {
					lock.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
					trace('места не найдено');
				}
			} else {
				lock.rotation = parameter;
				lock.x = parameterToCoords(parameter).x;
				lock.y = parameterToCoords(parameter).y;
				addChild(lock);
				
				releaseParticle(lock, true);
			}
		}
		
		private function onBallMouseDown(e:MouseEvent):void {
			particleIsSnapped = true;
			
			if (shiftPressed) {
				if (e.target is Bead) {
					addBeadHandling(new Bead(Bead(e.target).particleData));
				} else if (e.target is Lock) {
					addLockHandling(new Lock(Lock(e.target).particleData));
				}
			} else {
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
				
				dispatchEvent(new ColliderEvent(ColliderEvent.ELEMENT_REMOVED, currentParticle));
			}
		}
		
		private var firstLockIndex:int;
		private var lastLockIndex:int;
		private var firstBeadIndex:int;
		private var lastBeadIndex:int;
		
		private function hasFreeSpace(particle:Particle, angle:Number):Boolean {
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
			//trace(locks.length,particles.length);
			if (locks.length == 0) {
				space = 360;
				for (i in particles) {
					tempVector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
					occupiedSpace += getIntervalLength(tempVector);
				}
			} else if (locks.length == 1) {
				tempVector = getAngleInterval(new Point(locks[0].x, locks[0].y), locks[0].angle, locks[0].radius);
				space = 360 - getIntervalLength(tempVector);
				for (i in particles) {
					if (particles[i] is Bead) {
						tempVector = getAngleInterval(new Point(particles[i].x, particles[i].y), particles[i].angle, particles[i].radius);
						occupiedSpace += getIntervalLength(tempVector);
					} else {
						//trace('i',i)
						firstBeadIndex = (int(i) == particles.length - 1)?0:int(i) + 1;
						lastBeadIndex = (int(i) == 0)?particles.length - 1:int(i) - 1;
					}
				}
				
				firstLockIndex = lastLockIndex = 0;
			} else {
				for (i in locks) {
					if (locks[i].angle > angle) {
						if (int(i) == 0) {
							firstLockIndex = locks.length - 1;
							lastLockIndex = 0;
						} else {
							firstLockIndex = int(i) - 1;
							lastLockIndex = int(i);
						}
						
						startLock = locks[firstLockIndex];
						endLock = locks[lastLockIndex];
						break;
					}
				}
				if (!startLock) {
					startLock = locks[locks.length - 1];
					endLock = locks[0];
					
					firstLockIndex = locks.length - 1;
					lastLockIndex = 0;
				}
				
				startAngle = getAngleInterval(new Point(startLock.x, startLock.y), startLock.angle, startLock.radius)[1];
				endAngle = getAngleInterval(new Point(endLock.x, endLock.y), endLock.angle, endLock.radius)[0];
				
				if (startAngle > endAngle)
					space = (180 - startAngle) + (endAngle + 180);
				else space = endAngle - startAngle;
				
				for (i in particles) {//найдем начало
					if (particles[i] == startLock) {
						break;
					}
				}
				
				var j:int = (int(i) + 1 > particles.length - 1)?0:int(i) + 1;
				firstBeadIndex = j;
				while (particles[j] != endLock) {//и переберем все до конца
					tempVector = getAngleInterval(new Point(particles[j].x, particles[j].y), particles[j].angle, particles[j].radius);
					occupiedSpace += getIntervalLength(tempVector);
					
					j++;
					if (j > particles.length - 1) j = 0;
				}
				lastBeadIndex = (j == 0)?particles.length - 1:j - 1;
			}
			//trace('fl',firstBeadIndex,lastBeadIndex)
			//trace(space, occupiedSpace, getIntervalLength(particleInterval));
			if (space - occupiedSpace > 2 + getIntervalLength(particleInterval))
				return true;
			else
				return false;
		}
		
		private function getIntervalLength(interval:Vector.<Number>):Number {
			if (interval[0] > interval[1]) {
				return (180 - interval[0]) + (interval[1] + 180);
			} else {
				return interval[1] - interval[0];
			}
		}
		
		private function onMouseMove(e:MouseEvent):void {
			var angle:Number = coordsToParameter(mouseX, mouseY);
			//currentParticle.angle = coordsToParameter(currentParticle.x, currentParticle.y);
			currentParticle.angle = angle;
			//currentBead.rotation = angle * 180 / Math.PI - 90;
			TweenLite.to(currentParticle, .1, {shortRotation:{rotation: angle}});
			
			var dist:Number = Math.sqrt(mouseX * mouseX + mouseY * mouseY);
			var necklacePnt:Point = parameterToCoords(angle);
			var localRadius:Number = Math.sqrt(necklacePnt.x * necklacePnt.x + necklacePnt.y * necklacePnt.y);
			
			if (Math.abs(dist - localRadius) < 50)
				//particleIsSnapped = hasFreePlace(currentParticle, angle);
				particleIsSnapped = hasFreeSpace(currentParticle, currentParticle.angle);
			else
				particleIsSnapped = false;
			
			if (particleIsSnapped) {
				currentParticle.alpha = 1;
				TweenLite.to(currentParticle, .1, { x: necklacePnt.x, y: necklacePnt.y, overwrite: false} );
				//currentParticle.x = necklacePnt.x;
				//currentParticle.y = necklacePnt.y;
				//trace(getAngleInterval(new Point(necklacePnt.x, necklacePnt.y), angle, currentParticle.radius));
			} else {
				currentParticle.alpha = .5;
				TweenLite.to(currentParticle, .1, {x: mouseX, y: mouseY, overwrite: false});
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
				particle.initAngle(coordsToParameter(particle.x, particle.y));
				
				dispatchEvent(new ColliderEvent(ColliderEvent.ELEMENT_ADDED, particle));
			} else {
				TweenLite.to(particle, .3, {rotation: "-90", scaleX: 0, scaleY: 0, onComplete: removeChild, onCompleteParams: [particle]});
				particle.removeEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDown);
			}
			particleIsSnapped = false;
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
				b.setLastPosition(b.x, b.y);
				applyGravity(b);
				b.velocityBeforeExchange = b.velocity;
			}
			handleCollisions();
		}
		
		private function findFirstCollision():void {
			var firstBead:Particle;
			var secondBead:Particle;
			var minTime:Number;
			var time:Number;
			/*for (var i:int = 0; i < particles.length; i++) {
				firstBead = particles[i];
				if (firstBead is StaticBead) continue;
				
				
				if (firstBead.velocityBeforeExchange > 0) {
					if (i >= particles.length - 1)
						continue;
					
					secondBead = particles[i + 1];
					bead2Interval = getAngleInterval(new Point(secondBead.x, secondBead.y), secondBead.angle, secondBead.radius);
					
					if (firstBead.angle - secondBead.angle > .01 || bead1Interval[1] - bead2Interval[0] > .01) {
						collisionIsDetected = true;
					}
				} else if (firstBead.velocityBeforeExchange < 0) {
					if (i == 0)
						continue;
					
					secondBead = particles[i - 1];
					bead2Interval = getAngleInterval(new Point(secondBead.x, secondBead.y), secondBead.angle, secondBead.radius);
					
					if (firstBead.angle - secondBead.angle < -.01 || bead1Interval[0] - bead2Interval[1] < -.01) {
						collisionIsDetected = true;
					}
				}
			}*/
		}
		
		private function handleCollisions():void {
			var firstBead:Particle;
			var secondBead:Particle;
			var bead1Interval:Vector.<Number>;
			var bead2Interval:Vector.<Number>;
			var tempv:Number;
			var i:int;
			var j:int;
			var collisionIsDetected:Boolean = true;
			var roundCounter:int = 0;
			
			while (collisionIsDetected) {
				collisionIsDetected = false;
				for (i = 0; i < particles.length; i++) {
					firstBead = particles[i];
					bead1Interval = getAngleInterval(new Point(firstBead.x, firstBead.y), firstBead.angle, firstBead.radius);
					if (firstBead.velocityBeforeExchange > 0) {
						if (i >= particles.length - 1)
							continue;
						
						secondBead = particles[i + 1];
						bead2Interval = getAngleInterval(new Point(secondBead.x, secondBead.y), secondBead.angle, secondBead.radius);
						
						if (firstBead.angle - secondBead.angle > .01 || bead1Interval[1] - bead2Interval[0] > .01) {
							collisionIsDetected = true;
							
							if (secondBead.velocityBeforeExchange >= 0)
								firstBead.angle -= bead1Interval[1] - bead2Interval[0];
							else {
								firstBead.angle -= (bead1Interval[1] - bead2Interval[0]) * Math.abs(firstBead.velocityBeforeExchange) / (Math.abs(firstBead.velocityBeforeExchange) + Math.abs(secondBead.velocityBeforeExchange));
								secondBead.angle += (bead1Interval[1] - bead2Interval[0]) * Math.abs(secondBead.velocityBeforeExchange) / (Math.abs(firstBead.velocityBeforeExchange) + Math.abs(secondBead.velocityBeforeExchange));
							}
							//if (bead1st.angle < bead1st.prevAngle) bead1st.angle = bead1st.prevAngle;
							//if (bead2nd.angle > bead2nd.prevAngle) bead2nd.angle = bead2nd.prevAngle;
							
							updateParticlePosition(firstBead);
							updateParticlePosition(secondBead);
							
							if (!roundCounter) {
								if (firstBead is StaticBead) {
									Bead(secondBead).velocity *= -.5;
								} else if (secondBead is StaticBead) {
									Bead(firstBead).velocity *= -.5;
								} else {
									tempv = firstBead.velocity;
									Bead(firstBead).velocity = secondBead.velocity * .9;
									Bead(secondBead).velocity = tempv * .9;
								}
							}
						}
					} else if (firstBead.velocityBeforeExchange < 0) {
						if (i == 0)
							continue;
						secondBead = particles[i - 1];
						bead2Interval = getAngleInterval(new Point(secondBead.x, secondBead.y), secondBead.angle, secondBead.radius);
						
						if (firstBead.angle - secondBead.angle < -.01 || bead1Interval[0] - bead2Interval[1] < -.01) {
							collisionIsDetected = true;
							
							if (secondBead.velocityBeforeExchange <= 0)
								firstBead.angle += bead2Interval[1] - bead1Interval[0];
							else {
								firstBead.angle += (bead2Interval[1] - bead1Interval[0]) * Math.abs(firstBead.velocityBeforeExchange) / (Math.abs(firstBead.velocityBeforeExchange) + Math.abs(secondBead.velocityBeforeExchange));
								secondBead.angle -= (bead2Interval[1] - bead1Interval[0]) * Math.abs(secondBead.velocityBeforeExchange) / (Math.abs(firstBead.velocityBeforeExchange) + Math.abs(secondBead.velocityBeforeExchange));
							}
							//if (bead1st.angle > bead1st.prevAngle) bead1st.angle = bead1st.prevAngle;
							//if (bead2nd.angle < bead2nd.prevAngle) bead2nd.angle = bead2nd.prevAngle;
							
							updateParticlePosition(firstBead);
							updateParticlePosition(secondBead);
							
							if (!roundCounter) {
								if (firstBead is StaticBead) {
									Bead(secondBead).velocity *= -.5;
								} else if (secondBead is StaticBead) {
									Bead(firstBead).velocity *= -.5;
								} else {
									tempv = firstBead.velocity;
									Bead(firstBead).velocity = secondBead.velocity * .9;
									Bead(secondBead).velocity = tempv * .9;
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
					//bead.suppressShivering();
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
			
			particle.rotation = particle.angle;
		}
		
		/**возвращает диапазон углов, который занимает на браслете данная бусина*/ 
		private function getAngleInterval(pnt:Point, angle:Number, radius:Number):Vector.<Number> {
			var pnt1:Point = new Point(10, minorRadius * minorRadius / pnt.y * (1 - pnt.x / majorRadius / majorRadius * (pnt.x + 10)) - pnt.y);
			var pnt2:Point = new Point(-10, minorRadius * minorRadius / pnt.y * (1 - pnt.x / majorRadius / majorRadius * (pnt.x - 10)) - pnt.y);
			
			var length:Number = Math.sqrt(pnt1.x * pnt1.x + pnt1.y * pnt1.y);
			
			var leftAngle:Number = coordsToParameter(pnt.x + pnt1.x / length * radius, pnt.y + pnt1.y / length * radius);
			var rightAngle:Number = coordsToParameter(pnt.x + pnt2.x / length * radius, pnt.y + pnt2.y / length * radius);
			
			if (leftAngle > rightAngle) {
				var tangle:Number = leftAngle;
				leftAngle = rightAngle;
				rightAngle = tangle;
			}
			
			if (angle > rightAngle || angle < leftAngle) {//точка совпадения начала и конца браслета внутри бусины
				tangle = leftAngle;
				leftAngle = rightAngle;
				rightAngle = tangle;
			}
			
			return new <Number>[leftAngle, rightAngle];
		}
		
		private function applyGravity(bead:Bead):void {
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
			
			updateParticlePosition(bead);
		}
		
		private function compareParticles(a:Particle, b:Particle):Number {
			return a.angle - b.angle;
		}
		
		override public function get particlesData():Vector.<ParticleData> {
			var res:Vector.<ParticleData> = new Vector.<ParticleData>;
			var partData:ParticleData;
			for each (var part:Particle in particles) {
				if (!(part is DeadSpace)) {
					partData = part.particleData;
					partData.parameter = part.angle;
					res.push(partData);
				}
			}
			return res;
		}
	}
}

class AngleInterval {
	public var startAngle:Number;
	public var endAngle:Number;
}