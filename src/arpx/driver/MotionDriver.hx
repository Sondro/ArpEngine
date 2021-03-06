package arpx.driver;

import arp.ds.IList;
import arp.task.Heartbeat;
import arpx.field.Field;
import arpx.mortal.Mortal;
import arpx.motion.Motion;
import arpx.motionFrame.MotionFrame;
import arpx.motionSet.MotionSet;
import arpx.reactFrame.ReactFrame;
import arpx.structs.ArpPosition;
import arpx.structs.ArpRange;

@:arpType("driver", "motion")
class MotionDriver extends Driver {

	@:arpField public var motionSpeed:Float = 1;
	@:arpBarrier @:arpField public var motionSet:MotionSet;
	@:arpField(false) public var nowMotion:Motion;
	@:arpField public var nowTime:Float;
	@:arpField public var target:ArpPosition;

	@:arpField private var willReact:Bool;
	@:arpField(false) private var reactQueue:IList<ReactFrame>;

	public function new() super();

	private function reset():Void {
		this.nowMotion = this.motionSet.initMotion;
		this.nowTime = 0;
	}

	private function startMotion(mortal:Mortal, motion:Motion, restart:Bool):Bool {
		if (motion == null) return false;
		if (!restart && this.nowMotion == motion) return false;

		this.nowMotion = motion;
		this.nowTime = 0;

		var motionFrame:MotionFrame = motion.motionFrames.first();
		if (motionFrame != null && motionFrame.time == 0) mortal.params.merge(motionFrame.params);

		if (this.willReact) {
			var reactFrame:ReactFrame = this.nowMotion.reactFrames.first();
			if (reactFrame != null && reactFrame.time == 0) reactQueue.push(reactFrame);
		}
		return true;
	}

	override public function startAction(mortal:Mortal, actionName:String, restart:Bool = false):Bool {
		if (this.nowMotion == null) this.reset();
		var newMotion:Motion = this.nowMotion.nextMotion(actionName, this.nowTime);
		if (newMotion == null) {
			newMotion = this.motionSet.nextMotion(actionName, this.nowTime);
		}
		if (newMotion == null) {
			return false;
		}
		if (this.startMotion(mortal, newMotion, restart)) {
			mortal.onStartAction(actionName, newMotion);
		}
		return true;
	}

	private function flushReactQueue(field:Field, mortal:Mortal):Void {
		if (!reactQueue.isEmpty()) {
			for (reactFrame in reactQueue) field.dispatchReactFrame(mortal, reactFrame, 0);
			reactQueue.clear();
		}
	}

	private static var _workPos:ArpPosition = new ArpPosition();
	override public function tick(field:Field, mortal:Mortal):Heartbeat {
		this.flushReactQueue(field, mortal);

		if (this.nowMotion == null) this.reset();
		var nowMotion:Motion = this.nowMotion;
		if (nowMotion != null) {
			var oldTime:Float = this.nowTime;
			var newTime:Float = this.nowTime + this.motionSpeed;
			var time:Float;
			var nextTime:Float = nowMotion.time;

			var motionFrame:MotionFrame = null;
			for (frame in this.nowMotion.motionFrames) {
				time = frame.time;
				if (time < oldTime) {
					// last frame has already been ended
					motionFrame = frame;
				} else if (time < newTime) {
					// last frame has just ended
					if (motionFrame != null) mortal.params.merge(motionFrame.params);
					motionFrame = frame;
				} else {
					// last frame has not ended
					break;
				}
			}
			if (motionFrame != null) {
				mortal.params.merge(motionFrame.params);
				mortal.hitFrames.clear();
				for (hitFrame in motionFrame.hitFrames) mortal.hitFrames.add(hitFrame);
			}

			_workPos.copyFrom(mortal.position);
			var moved:Bool = false;
			for (tween in this.nowMotion.motionTweens) {
				var timeRange:ArpRange = tween.time;
				if (timeRange.minValue > newTime || timeRange.maxValue < newTime) {
					// tween is out of range
				} else {
					var tweenMin:Float = if (oldTime > timeRange.minValue) oldTime else timeRange.minValue;
					var tweenMax:Float = if (newTime < timeRange.maxValue) newTime else timeRange.maxValue;
					tween.update(_workPos, this.target, mortal.params, tweenMin, tweenMax);
					moved = true;
				}
			}
			if (moved) {
				mortal.moveWithHit(field, _workPos.x, _workPos.y, _workPos.z, this.dHitType);
			} else {
				mortal.stayWithHit(field, this.dHitType);
			}

			if (this.willReact) {
				for (reactFrame in this.nowMotion.reactFrames) {
					time = reactFrame.time;

					if (time + reactFrame.duration < newTime) {
						// reaction range has just ended
					} else if (time < newTime) {
						if (oldTime <= time) {
							// reaction has just started
							field.dispatchReactFrame(mortal, reactFrame, 0);
						} else {
							// reaction range has been started
							field.dispatchReactFrame(mortal, reactFrame, newTime - time);
						}
					} else {
						// reaction range has not started
					}
				}
			}

			if (newTime >= nowMotion.time) {
				if (!this.startAction(mortal, nowMotion.loopAction, true)) {
					this.startMotion(mortal, nowMotion, true);
				}
				this.flushReactQueue(field, mortal);
			} else {
				this.nowTime = newTime;
			}
		}
		return Heartbeat.Keep;
	}
}
