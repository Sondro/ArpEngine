package arpx.file;

import arp.domain.IArpObject;
import arpx.impl.cross.file.IFileImpl;

@:arpType("file", "null")
class File implements IFileImpl implements IArpObject {

	@:arpImpl private var arpImpl:IFileImpl;

	public function new () {
	}
}
