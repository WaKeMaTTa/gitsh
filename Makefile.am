AUTOMAKE_OPTIONS = foreign
EXTRA_DIST = \
						 LICENSE \
						 README.md \
						 INSTALL \
						 vendor/vendorize \
						 ext/gitsh/extconf.rb \
						 ext/gitsh/src/line_editor.c \
						 src/gitsh.rb.in \
						 lib/gitsh/version.rb.in

bin_PROGRAMS = gitsh
gitsh_SOURCES = src/gitsh.c
AM_CPPFLAGS = -DGITSH_RB_PATH="\"$(rubydir)/$(PACKAGE).rb\""

ruby_SCRIPTS = src/gitsh.rb
CLEANFILES = $(ruby_SCRIPTS) lib/gitsh/version.rb

edit = sed \
	-e 's|@RUBY[@]|$(RUBY)|g' \
	-e 's|@rubydir[@]|$(rubydir)|g' \
	-e 's|@gemsetuppath[@]|$(gemsetuppath)|g'

src/gitsh.rb: Makefile src/gitsh.rb.in
	$(edit) $(srcdir)/$@.in > $@
	chmod +x $@

pkgruby_DATA = lib/gitsh/version.rb
nobase_dist_pkgruby_DATA = $(libfiles)

replace_version = sed \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g'

lib/gitsh/version.rb: Makefile lib/gitsh/version.rb.in
	$(replace_version) $(srcdir)/$@.in > $@

all-local: 
	cd ext/gitsh && $(MAKE)

clean-local:
	cd ext/gitsh && $(MAKE) clean

nobase_dist_pkgdata_DATA = $(vendorfiles)
distclean-local:
	rm -rf vendor/gems
	rm -f ext/gitsh/Makefile

dist_man_MANS = man/man1/gitsh.1

TESTS = $(testfiles)
TEST_EXTENSIONS = .rb
RB_LOG_COMPILER = bundle exec rspec
AM_RB_LOG_FLAGS = -I $(abs_top_builddir)/spec -I $(abs_top_builddir)/lib

# Release

.PHONY: release \
	release_build release_push release_clean \
	release_build_tarball release_build_homebrew release_build_arch \
	release_push_tarball release_push_homebrew release_push_arch \
	release_clean_tarball release_clean_homebrew release_clean_arch

edit_package = sed \
	-e 's|@PACKAGE[@]|$(PACKAGE)|g' \
	-e 's|@PACKAGE_VERSION[@]|$(PACKAGE_VERSION)|g' \
	-e 's|@DIST_ARCHIVES[@]|$(DIST_ARCHIVES)|g' \
	-e 's|@DIST_SHA[@]|$(DIST_SHA)|g'

release: release_build release_push release_clean

release_build: release_build_tarball release_build_homebrew release_build_arch

release_push: release_push_tarball release_push_homebrew release_push_arch

release_clean: release_clean_tarball release_clean_homebrew release_clean_arch

release_build_tarball: Makefile distcheck
	git clone --branch gh-pages git@github.com:thoughtbot/gitsh.git gh-pages
	cp $(DIST_ARCHIVES) gh-pages
	cd gh-pages &&\
		git add $(DIST_ARCHIVES) &&\
		git commit -m "Release version $(PACKAGE_VERSION)"

release_push_tarball:
	cd gh-pages &&\
		git push

release_clean_tarball:
	rm -rf gh-pages

release_build_homebrew: DIST_SHA
	git clone git@github.com:thoughtbot/homebrew-formulae.git homebrew-formulae
	$(edit_package) homebrew/gitsh.rb.in > homebrew-formulae/Formula/gitsh.rb
	cd homebrew-formulae &&\
		git commit -am "gitsh: Release version $(PACKAGE_VERSION)"

release_push_homebrew:
	cd homebrew-formulae &&\
		git push

release_clean_homebrew:
	rm -rf homebrew-formulae

release_build_arch: DIST_SHA
	git clone --branch master git@github.com:thoughtbot/gitsh.git release-arch
	cd release-arch &&\
		$(edit_package) arch/PKGBUILD.in > arch/PKGBUILD &&\
		git commit -m "Arch package for version $(PACKAGE_VERSION)" -- arch/PKGBUILD &&\
		git tag v$(PACKAGE_VERSION)

release_push_arch:
	cd release-arch &&\
		git push --tags &&\
		git push

release_clean_arch:
	rm -rf release-arch

DIST_SHA: Makefile distcheck
	$(eval DIST_SHA := $(shell shasum $(srcdir)/$(DIST_ARCHIVES) | cut -d' ' -f1))
