package arpx.mortal;

import arp.domain.ArpDirectory;
import arp.domain.IArpObject;
import arp.ds.impl.ArraySet;
import arp.ds.ISet;
import arp.hit.fields.HitObject;
import arp.hit.structs.HitGeneric;
import arp.task.Heartbeat;
import arp.task.ITickableChild;
import arpx.driver.Driver;
import arpx.field.Field;
import arpx.hitFrame.HitFrame;
import arpx.impl.cross.mortal.IMortalImpl;
import arpx.motion.Motion;
import arpx.reactFrame.ReactFrame;
import arpx.structs.ArpParams;
import arpx.structs.ArpPosition;

@:arpType("mortal", "null")
class Mortal implements IArpObject implements ITickableChild<Field> implements IMortalImpl {

	@:arpBarrier @:arpDeepCopy @:arpField public var driver:Driver;
	@:arpField public var position:ArpPosition;
	@:arpField public var visible:Bool = true;
	@:arpField public var params:ArpParams;
	@:arpBarrier @:arpField(true) public var hitFrames:ISet<HitFrame>;

	private var hitMortals:Map<String, HitMortal>;
	private var reactRecord:ISet<String>;
	private var lastReactRecord:ISet<String>;

	@:arpImpl private var arpImpl:IMortalImpl;

	public function new() {
		hitMortals = new Map<String, HitMortal>();
		reactRecord = new ArraySet<String>();
		lastReactRecord = new ArraySet<String>();
	}

	private var isComplex(get, never):Bool;
	private function get_isComplex():Bool return false;

	public function asHitType(hitType:String):HitMortal {
		if (hitMortals.exists(hitType)) return hitMortals.get(hitType);
		var hitMortal:HitMortal = new HitMortal(this, hitType, this.isComplex);
		hitMortals.set(hitType, hitMortal);
		return hitMortal;
	}

	public function tickChild(timeslice:Float, field:Field):Heartbeat {
		var result:Heartbeat = Heartbeat.Keep;
		if (this.driver != null) {
			result = this.driver.tick(field, this);
		} else {
			refreshHitMortals(field);
		}

		var rr = this.lastReactRecord;
		if (!rr.isEmpty()) rr.clear();
		this.lastReactRecord = reactRecord;
		this.reactRecord = rr;
		return result;
	}

	public var driverTime(get, never):Float;
	public function get_driverTime():Float {
		if (this.driver == null) return 0;
		return this.driver.time;
	}

	public function toward(time:Float, x:Float, y:Float, z:Float = 0, gridSize:Float = 1.0):Bool {
		if (this.driver == null) return false;
		var position:ArpPosition = this.position;
		return this.driver.towardD(this, time, x * gridSize - position.x, y * gridSize - position.y, z * gridSize - position.z);
	}

	public function towardD(time:Float, x:Float = 0, y:Float = 0, z:Float = 0, gridSize:Float = 1.0):Bool {
		if (this.driver == null) return false;
		return this.driver.towardD(this, time, x * gridSize, y * gridSize, z * gridSize);
	}

	public function startAction(actionName:String, restart:Bool = false):Bool {
		if (this.driver != null) return this.driver.startAction(this, actionName, restart);
		return false;
	}

	public function onStartAction(actionName:String, newMotion:Motion):Void {

	}

	public function react(field:Field, source:Mortal, reactFrame:ReactFrame, delay:Float):Void {
		var reactionName:String = source.arpSlot.sid + ArpDirectory.PATH_DELIMITER + reactFrame.arpSlot.sid;
		if (!this.lastReactRecord.hasValue(reactionName)) {
			this.onReact(field, source, reactFrame, delay);
		}
		this.reactRecord.add(reactionName);
		this.lastReactRecord.add(reactionName);
	}

	public function onReact(field:Field, source:Mortal, reactFrame:ReactFrame, delay:Float):Void {

	}

	public function collide(field:Field, source:Mortal):Void {
		var reactionName:String = source.arpSlot.sid.toString();
		if (!this.lastReactRecord.hasValue(reactionName)) {
			this.onCollide(field, source);
		}
		this.reactRecord.add(reactionName);
		this.lastReactRecord.add(reactionName);
	}

	public function onCollide(field:Field, source:Mortal):Void {

	}

	private function refreshHitMortals(field:Field):Void {
		for (hitFrame in this.hitFrames) hitFrame.updateHitMortal(field, this);
	}

	public function moveWithHit(field:Field, x:Float, y:Float, z:Float, dHitType:String):Void {
		if (dHitType == null) {
			this.position.x = x;
			this.position.y = y;
			this.position.z = z;
			return;
		}

		var hit:HitGeneric = field.findHit(this, dHitType);
		var p:Float;

		p = this.position.x;
		this.position.x = x;
		this.refreshHitMortals(field);
		field.hitRaw(hit, dHitType, function(other:HitMortal):Bool {
			this.collide(field, other.mortal);
			this.position.x = p;
			return true;
		});

		p = this.position.y;
		this.position.y = y;
		this.refreshHitMortals(field);
		field.hitRaw(hit, dHitType, function(other:HitMortal):Bool {
			this.collide(field, other.mortal);
			this.position.y = p;
			return true;
		});

		p = this.position.z;
		this.position.z = z;
		this.refreshHitMortals(field);
		field.hitRaw(hit, dHitType, function(other:HitMortal):Bool {
			this.collide(field, other.mortal);
			this.position.z = p;
			this.refreshHitMortals(field);
			return true;
		});
	}

	public function moveDWithHit(field:Field, dX:Float, dY:Float, dZ:Float, dHitType:String):Void {
		this.moveWithHit(
			field,
			this.position.x + dX,
			this.position.y + dY,
			this.position.z + dZ,
			dHitType
		);
	}

	public function stayWithHit(field:Field, dHitType:String):Void {
		this.refreshHitMortals(field);
	}

	public function complexHitTest(self:HitGeneric, other:HitGeneric):Bool {
		return true;
	}
}

class HitMortal extends HitObject<HitGeneric> {

	public var mortal:Mortal;
	public var hitType:String;
	public var isComplex:Bool;

	public function new(mortal:Mortal, hitType:String, isComplex:Bool) {
		super();
		this.mortal = mortal;
		this.hitType = hitType;
		this.isComplex = isComplex;
	}
}
