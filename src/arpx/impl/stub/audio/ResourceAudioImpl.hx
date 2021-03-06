package arpx.impl.stub.audio;

#if (arp_audio_backend_stub || arp_backend_display)

import arpx.audio.ResourceAudio;
import arpx.impl.cross.audio.AudioChannel;
import arpx.impl.cross.audio.AudioContext;
import arpx.impl.cross.audio.IAudioImpl;

class ResourceAudioImpl extends ArpObjectImplBase implements IAudioImpl {

	private var audio:ResourceAudio;

	public function new(audio:ResourceAudio) {
		super();
		this.audio = audio;
	}

	public function play(context:AudioContext, loop:Bool, volume:Float):AudioChannel return new AudioChannelImpl(volume);
}

#end
