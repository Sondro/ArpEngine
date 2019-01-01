package arpx.impl.flash.audio;

#if (arp_audio_backend_flash || arp_backend_display)

import flash.events.Event;
import flash.media.SoundChannel;

abstract AudioChannelImpl(SoundChannel) from SoundChannel {

	public var isPlaying(get, never):Bool;
	inline private function get_isPlaying():Float return false;

	public var position(get, never):Float;
	inline private function get_position():Float return this.position;

	public var volume(get, set):Float;
	inline private function get_volume():Float return this.soundTransform.volume;
	inline private function set_volume(value:Float):Float return this.soundTransform.volume = value;

	private var _onComplete:Void->Void;
	public var onComplete(get, set):Void->Void;
	inline private function get_onComplete():Void->Void return this._onComplete;
	inline public function set_onComplete(callback:Void->Void):Void->Void {
		if (this._onComplete != null) this.removeEventListener(Event.SOUND_COMPLETE, this._onComplete);
		this._onComplete = callback;
		if (this._onComplete != null) this.addEventListener(Event.SOUND_COMPLETE, this._onComplete);
		return callback;
	}

	inline public function new(channel:SoundChannel) this = channel;

	inline public function stop():Void this.stop();
}

#end
