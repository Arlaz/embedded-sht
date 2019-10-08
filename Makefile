drivers=sht3x shtc1
sample-projects=shtc3-stm32-uvision
clean_drivers=$(foreach d, $(drivers), clean_$(d))
release_drivers=$(foreach d, $(drivers), release/$(d))
release_sample_projects=$(foreach s, $(sample-projects), release/$(s))

.PHONY: FORCE all $(release_drivers) $(clean_drivers) style-check style-fix

all: prepare $(drivers)

prepare: sht-common/sht_git_version.c

$(drivers): prepare
	cd $@ && $(MAKE) $(MFLAGS)

sht-common/sht_git_version.c: FORCE
	git describe --always --dirty | \
		awk 'BEGIN \
		{print "/* THIS FILE IS AUTOGENERATED */"} \
		{print "#include \"sht_git_version.h\""} \
		{print "const char * SHT_DRV_VERSION_STR = \"" $$0"\";"} \
		END {}' > $@ || echo "Can't update version, not a git repository"


$(release_drivers): sht-common/sht_git_version.c
	export rel=$@ && \
	export driver=$${rel#release/} && \
	export tag="$$(git describe --always --dirty)" && \
	export pkgname="$${driver}-$${tag}" && \
	export pkgdir="release/$${pkgname}" && \
	rm -rf "$${pkgdir}" && mkdir -p "$${pkgdir}" && \
	cp -r embedded-common/* "$${pkgdir}" && \
	cp -r sht-common/* "$${pkgdir}" && \
	cp -r $${driver}/* "$${pkgdir}" && \
	cp CHANGELOG.md LICENSE "$${pkgdir}" && \
	echo 'sensirion_common_dir = .' >> $${pkgdir}/user_config.inc && \
	echo 'sht_common_dir = .' >> $${pkgdir}/user_config.inc && \
	echo 'sht3x_dir = .' >> $${pkgdir}/user_config.inc && \
	echo 'shtc1_dir = .' >> $${pkgdir}/user_config.inc && \
	cd "$${pkgdir}" && $(MAKE) $(MFLAGS) && $(MAKE) clean $(MFLAGS) && cd - && \
	cd release && zip -r "$${pkgname}.zip" "$${pkgname}" && cd - && \
	ln -sfn $${pkgname} $@

$(release_sample_projects):
	export rel=$@ && \
	export sample_project=$${rel#release/} && \
	cd sample-projects/$${sample_project}/ && ./copy_shtc1_driver.sh && cd - && \
	export tag="$$(git describe --always --dirty)" && \
	export pkgname="$${sample_project}-sample-project-$${tag}" && \
	export pkgdir="release/$${pkgname}" && \
	rm -rf "$${pkgdir}" && mkdir -p "$${pkgdir}" && \
	cp -r sample-projects/$${sample_project}/* "$${pkgdir}" && \
	cd release && zip -r "$${pkgname}.zip" "$${pkgname}" && cd - && \
	ln -sfn $${pkgname} release/$${sample_project}

release: clean $(release_drivers) $(release_sample_projects)

$(clean_drivers):
	export rel=$@ && \
	export driver=$${rel#clean_} && \
	cd $${driver} && $(MAKE) clean $(MFLAGS) && cd -

clean: $(clean_drivers)
	rm -rf release sht-common/sht_git_version.c

style-fix:
	@if [ $$(git status --porcelain -uno 2> /dev/null | wc -l) -gt "0" ]; \
	then \
		echo "Refusing to run on dirty git state. Commit your changes first."; \
		exit 1; \
	fi; \
	git ls-files | grep -e '\.\(c\|h\|cpp\)$$' | xargs clang-format -i -style=file;

style-check: style-fix
	@if [ $$(git status --porcelain -uno 2> /dev/null | wc -l) -gt "0" ]; \
	then \
		echo "Style check failed:"; \
		git diff; \
		git checkout -f; \
		exit 1; \
	fi;
