package arpx.inputAxis;

import arp.task.Heartbeat;
import arpx.input.Input;
import arpx.proc.Proc;

@:arpType("inputAxis", "trigger")
class TriggerInputAxis extends InputAxis {

	@:arpField(true) public var onDown:Proc;
	@:arpField public var onUp:Proc;

	public function new() super();

	override public function tickChild(timeslice:Float, parent:Input):Heartbeat {
		super.tickChild(timeslice, parent);
		if (this.isTriggerDown && this.onDown != null) this.onDown.execute();
		if (this.isTriggerUp && this.onUp != null) this.onUp.execute();
		return Heartbeat.Keep;
	}
}
