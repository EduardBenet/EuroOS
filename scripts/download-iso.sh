# Linux Mint 22.3 (latest as of early 2026)
ISO_URL="https://mirrors.univ-reims.fr/IMAGES/mint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso"
CHECKSUM_URL="https://mirrors.kernel.org/linuxmint/stable/22.3/sha256sum.txt"

wget -q "$ISO_URL" -O linuxmint.iso
wget -q "$CHECKSUM_URL" -O sha256sum.txt

# Verify checksum
sha256sum --check --ignore-missing sha256sum.txt