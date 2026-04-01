# Linux Mint 22.3 (latest as of early 2026)
ISO_FILENAME=$(basename "$ISO_URL")

wget -q "$ISO_URL" -O "$ISO_FILENAME"
wget -q "$CHECKSUM_URL" -O sha256sum.txt

# Verify checksum
sha256sum --check --ignore-missing sha256sum.txt