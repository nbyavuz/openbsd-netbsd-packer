build:
	mkdir -p output && packer build -on-error=ask openbsd.pkr.hcl
debug-build:
	mkdir -p output && PACKER_LOG=1 packer build -on-error=ask openbsd.pkr.hcl
clean:
	rm -rf output* packer_cache
