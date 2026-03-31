#!/bin/bash
# convert-to-vhd.sh

RAW="output-linuxmint/packer-linuxmint"
VHD="linuxmint-azure.vhd"

MB=$((1024 * 1024))
size=$(qemu-img info -f raw --output json "$RAW" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['virtual-size'])")
rounded=$(( (($size + $MB - 1) / $MB) * $MB ))

echo "Resizing to $rounded bytes..."
qemu-img resize -f raw "$RAW" $rounded

# Convert to fixed VHD
# Note: use qemu-img 2.6+ to avoid the known VHD formatting bug
qemu-img convert -f raw -O vpc -o subformat=fixed,force_size "$RAW" "$VHD"

echo "Done: $VHD"