DATE = $(shell date --utc +'%Y-%m-%dt%H-%M')

build-openbsd:
	make clean && \
		packer build -on-error=ask -var-file=variables.pkr.hcl -var "image_date=$(DATE)" openbsd.pkr.hcl
debug-build-openbsd:
	make clean && PACKER_LOG=1 \
		time packer build -on-error=ask -var-file=variables.pkr.hcl -var "image_date=$(DATE)" openbsd.pkr.hcl
build-netbsd:
	make clean && \
		packer build -on-error=ask -var-file=variables.pkr.hcl -var "image_date=$(DATE)" netbsd.pkr.hcl
debug-build-netbsd:
	make clean && PACKER_LOG=1 \
		time packer build -on-error=ask -var-file=variables.pkr.hcl -var "image_date=$(DATE)" netbsd.pkr.hcl
clean:
	rm -rf output*
