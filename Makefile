build-openbsd:
	mkdir -p output && packer build -on-error=ask -var-file=vars.hcl openbsd.pkr.hcl
debug-build-openbsd:
	mkdir -p output && PACKER_LOG=1 packer build -on-error=ask -var-file=vars.hcl openbsd.pkr.hcl
build-netbsd:
	mkdir -p output && packer build -on-error=ask -var-file=variables.pkr.hcl netbsd.pkr.hcl
debug-build-netbsd:
	mkdir -p output && PACKER_LOG=1 packer build -on-error=ask -var-file=variables.pkr.hcl netbsd.pkr.hcl
clean:
	rm -rf output* packer_cache
