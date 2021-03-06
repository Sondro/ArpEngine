package arpx.motionTween;

import arpx.structs.ArpCurve;
import arpx.structs.ArpParams;
import arpx.structs.ArpPosition;

@:arpType("motionTween", "target")
class TargetMotionTween extends MotionTween {

	@:arpField public var curve:ArpCurve;
	@:arpField public var position:ArpPosition;
	@:arpField public var absolute:Bool;

	public function new() super();

	override public function update(position:ArpPosition, target:ArpPosition, params:ArpParams, oldTime:Float, newTime:Float):Void {
		var t0:Float = oldTime - time.minValue;
		var t1:Float = newTime - time.minValue;
		var factor:Float = this.curve.accumulateByRatio(t0, t1);
		var dPosX:Float;
		var dPosY:Float;
		var dPosZ:Float;
		if (absolute) {
			dPosX = (this.position.x - position.x) * factor;
			dPosY = (this.position.y - position.y) * factor;
			dPosZ = (this.position.z - position.z) * factor;
		} else {
			dPosX = (target.x - position.x) * factor;
			dPosY = (target.y - position.y) * factor;
			dPosZ = (target.z - position.z) * factor;
		}
		position.x += dPosX;
		position.y += dPosY;
		position.z += dPosZ;
	}
}
