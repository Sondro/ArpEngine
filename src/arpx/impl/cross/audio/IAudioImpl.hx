package arpx.impl.cross.audio;

import arp.impl.IArpObjectImpl;

interface IAudioImpl extends IArpObjectImpl {
	function play(context:AudioContext, loop:Bool, volume:Float):AudioChannel;
}
