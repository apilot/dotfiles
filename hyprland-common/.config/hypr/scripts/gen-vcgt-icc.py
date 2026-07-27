#!/usr/bin/env python3
"""Graft a gamma-correcting VCGT (video card gamma table) onto the factory
PL2493H.icc so Hyprland can actually correct the monitor's gamma response.

The factory profile has matrix primaries but no VCGT (Hyprland logs "ICC profile
has no VCGT data"), so gamma is uncorrected -> over-bright highlights.
This rebuilds the ICC with an added 'vcgt' tag containing a pure-power gamma
curve (output = input**gamma). gamma > 1 darkens midtones/highlights.

Usage: gen_vcgt_icc.py [gamma]   (default 2.2)
"""
import struct, sys, os

SRC = os.path.expanduser("~/.local/share/icc/PL2493H.icc")
DST = os.path.expanduser("~/.local/share/icc/PL2493H-vcgt.icc")
GAMMA = float(sys.argv[1]) if len(sys.argv) > 1 else 2.2

d = open(SRC, "rb").read()
header = bytearray(d[:128])
count = struct.unpack(">I", d[128:132])[0]

# Parse existing tag entries: (signature, raw_data, size, pad_to_4)
entries = []
for i in range(count):
    e = 132 + i * 12
    sig = d[e:e + 4]
    off, sz = struct.unpack(">II", d[e + 4:e + 12])
    raw = d[off:off + sz]
    pad = (4 - sz % 4) % 4
    entries.append((sig, raw, sz, pad))

# Build VCGT tag data: type 'vcgt' + reserved(4) + u32(0) + channels(2)+entries(2)+bpe(2) + LUT
NCH, NEN, BPE = 3, 256, 2
lut = bytearray()
for _c in range(NCH):
    for i in range(NEN):
        v = int(round((i / 255.0) ** GAMMA * 65535))
        lut += struct.pack(">H", v)
vcgt = b"vcgt" + struct.pack(">I", 0) + struct.pack(">I", 0) + struct.pack(">HHH", NCH, NEN, BPE) + bytes(lut)

# Rebuild: header + new count + entries + data blocks (offsets recomputed)
new_count = count + 1
table_end = 128 + 4 + new_count * 12
cur = table_end
offsets = []
for (_s, _r, sz, pad) in entries:
    offsets.append(cur)
    cur += sz + pad
vcgt_sz = len(vcgt)
vcgt_pad = (4 - vcgt_sz % 4) % 4
vcgt_off = cur

out = bytearray(header)
out += struct.pack(">I", new_count)
for i, (sig, _r, sz, _p) in enumerate(entries):
    out += sig + struct.pack(">II", offsets[i], sz)
out += b"vcgt" + struct.pack(">II", vcgt_off, vcgt_sz)
for (_s, raw, _sz, pad) in entries:
    out += raw + (b"\x00" * pad)
out += vcgt + (b"\x00" * vcgt_pad)

struct.pack_into(">I", out, 0, len(out))  # update profile size
open(DST, "wb").write(out)
print(f"wrote {DST} ({len(out)} bytes) gamma={GAMMA} (tags: {count}+vcgt)")
