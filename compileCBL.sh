cd CBL
git pull

echo "======== compiling CBL for k=21 =============="
RUSTFLAGS="-C target-cpu=native" K=21 PREFIX_BITS=28 cargo +nightly build --release --examples --target-dir target.k_21

