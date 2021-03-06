package arpx.impl.stub.audio;

#if (arp_audio_backend_stub || arp_backend_display)

import arpx.audio.UrlAudio;
import arpx.impl.cross.audio.AudioChannel;
import arpx.impl.cross.audio.AudioContext;
import arpx.impl.cross.audio.IAudioImpl;

class UrlAudioImpl extends ArpObjectImplBase implements IAudioImpl {

	private var audio:UrlAudio;

	public function new(audio:UrlAudio) {
		super();
		this.audio = audio;
	}

	public function play(context:AudioContext, loop:Bool, volume:Float):AudioChannel return new AudioChannelImpl(volume);
}

#end
