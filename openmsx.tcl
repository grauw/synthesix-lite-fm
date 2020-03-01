ext debugdevice
set debugoutput stdout
debug set_watchpoint read_io 0x2E
#debug set_watchpoint write_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}
#debug set_watchpoint read_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}

diskmanipulator create /tmp/synthesix-lite-fm.dsk 32M
virtual_drive /tmp/synthesix-lite-fm.dsk
diskmanipulator format virtual_drive
diskmanipulator import virtual_drive bin/
virtual_drive eject
hda /tmp/synthesix-lite-fm.dsk

plug msx-midi-in Virtual\ IN

set maxframeskip 100
set throttle off
after time 12 "set throttle on"
