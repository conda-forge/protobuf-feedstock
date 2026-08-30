import importlib.util
import platform
import struct
from pathlib import Path


machine = platform.machine().lower()
assert machine in {"arm64", "aarch64"}, machine

spec = importlib.util.find_spec("google._upb._message")
assert spec is not None and spec.origin is not None
extension = Path(spec.origin)

with extension.open("rb") as stream:
    assert stream.read(2) == b"MZ"
    stream.seek(0x3C)
    pe_offset = struct.unpack("<I", stream.read(4))[0]
    stream.seek(pe_offset)
    assert stream.read(4) == b"PE\0\0"
    pe_machine = struct.unpack("<H", stream.read(2))[0]

assert pe_machine == 0xAA64, f"{extension} has PE machine 0x{pe_machine:04X}"
