<<<<<<< HEAD
#!/bin/bash
#
# vim: set ts=4 sw=4 et:
#
# Passed arguments:
# 	$1 - pkgname [REQUIRED]
#	$2 - path to local repository [REQUIRED]
# 	$3 - cross-target [OPTIONAL]

if [ $# -lt 2 -o $# -gt 3 ]; then
    echo "${0##*/}: invalid number of arguments: pkgname repository [cross-target]"
    exit 1
fi

PKGNAME="$1"
XBPS_REPOSITORY="$2"
XBPS_CROSS_BUILD="$3"

for f in $XBPS_SHUTILSDIR/*.sh; do
    . $f
=======
#!//bin/bash
#
# Passed arguments:
#	$1 - pkgname [REQUIRED]
#	$2 - cross target [OPTIONAL]

if [ $# -lt 1 -o $# -gt 2 ]; then
	echo "$(basename $0): invalid number of arguments: pkgname [cross-target]"
	exit 1
fi

PKGNAME="$1"
XBPS_CROSS_BUILD="$2"

. $XBPS_SHUTILSDIR/common.sh

for f in $XBPS_COMMONDIR/helpers/*.sh; do
	source_file "$f"
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
done

setup_pkg "$PKGNAME" $XBPS_CROSS_BUILD

<<<<<<< HEAD
for f in $XBPS_COMMONDIR/environment/pkg/*.sh; do
    source_file "$f"
done

if [ "$sourcepkg" != "$PKGNAME" ]; then
    # Source all subpkg environment setup snippets.
    for f in ${XBPS_COMMONDIR}/environment/setup-subpkg/*.sh; do
        source_file "$f"
    done

    ${PKGNAME}_package
    pkgname=$PKGNAME
fi

if [ -s $XBPS_MASTERDIR/.xbps_chroot_init ]; then
    export XBPS_ARCH=$(<$XBPS_MASTERDIR/.xbps_chroot_init)
fi

# Run do-pkg hooks.
run_pkg_hooks "do-pkg"

# Run post-pkg hooks.
run_pkg_hooks post-pkg
=======
for f in $XBPS_COMMONDIR/environment/install/*.sh; do
	source_file "$f"
done

XBPS_PKG_DONE="$wrksrc/.xbps_${PKGNAME}_${XBPS_CROSS_BUILD}_pkg_done"

if [ -f $XBPS_PKG_DONE ]; then
	exit 0
fi

#
# Always remove metadata files generated in a previous installation.
#
for f in INSTALL REMOVE files.plist props.plist rdeps shlib-provides shlib-requires; do
	[ -f ${PKGDESTDIR}/${f} ] && rm -f ${PKGDESTDIR}/${f}
done

# If it's a subpkg execute the pkg_install() function.
if [ "$sourcepkg" != "$PKGNAME" ]; then
	# Source all subpkg environment setup snippets.
	for f in ${XBPS_COMMONDIR}/environment/setup-subpkg/*.sh; do
		source_file "$f"
	done
	${PKGNAME}_package
	pkgname=$PKGNAME

	install -d $PKGDESTDIR
	if declare -f pkg_install >/dev/null; then
		export XBPS_PKGDESTDIR=1
		run_func pkg_install
	fi
fi

setup_pkg_depends $pkgname

run_pkg_hooks post-install

touch -f $XBPS_PKG_DONE
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)

exit 0
