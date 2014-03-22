#!/bin/bash
#
<<<<<<< HEAD
# vim: set ts=4 sw=4 et:
#
=======
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
# Passed arguments:
# 	$1 - pkgname [REQUIRED]
#	$2 - cross target [OPTIONAL]

if [ $# -lt 1 -o $# -gt 2 ]; then
<<<<<<< HEAD
    echo "${0##*/}: invalid number of arguments: pkgname [cross-target]"
    exit 1
=======
	echo "$(basename $0): invalid number of arguments: pkgname [cross-target]"
	exit 1
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

PKGNAME="$1"
XBPS_CROSS_BUILD="$2"

<<<<<<< HEAD
for f in $XBPS_SHUTILSDIR/*.sh; do
    . $f
=======
. $XBPS_SHUTILSDIR/common.sh

for f in $XBPS_COMMONDIR/helpers/*.sh; do
	source_file "$f"
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
done

setup_pkg "$PKGNAME" $XBPS_CROSS_BUILD

for f in $XBPS_COMMONDIR/environment/fetch/*.sh; do
<<<<<<< HEAD
    source_file "$f"
done

XBPS_FETCH_DONE="${XBPS_STATEDIR}/${sourcepkg}_${XBPS_CROSS_BUILD}_fetch_done"

if [ -f "$XBPS_FETCH_DONE" ]; then
    exit 0
=======
	source_file "$f"
done

XBPS_FETCH_DONE="$wrksrc/.xbps_fetch_done"

if [ -f "$XBPS_FETCH_DONE" ]; then
	exit 0
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# Run pre-fetch hooks.
run_pkg_hooks pre-fetch

# If template defines pre_fetch(), use it.
if declare -f pre_fetch >/dev/null; then
<<<<<<< HEAD
    run_func pre_fetch
=======
	run_func pre_fetch
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# If template defines do_fetch(), use it rather than the hooks.
if declare -f do_fetch >/dev/null; then
<<<<<<< HEAD
    cd ${XBPS_BUILDDIR}
    [ -n "$build_wrksrc" ] && mkdir -p "$wrksrc"
    run_func do_fetch
else
    # Run do-fetch hooks.
    run_pkg_hooks "do-fetch"
fi

cd ${XBPS_BUILDDIR} || msg_error "$pkgver: cannot access wrksrc directory [$wrksrc]\n"
# if templates defines post_fetch(), use it.
if declare -f post_fetch >/dev/null; then
    run_func post_fetch
=======
	cd ${XBPS_BUILDDIR}
	[ -n "$build_wrksrc" ] && mkdir -p "$wrksrc"
	run_func do_fetch
	touch -f $XBPS_FETCH_DONE
else
	# Run do-fetch hooks.
	run_pkg_hooks "do-fetch"
fi

# if templates defines post_fetch(), use it.
if declare -f post_fetch >/dev/null; then
	run_func post_fetch
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# Run post-fetch hooks.
run_pkg_hooks post-fetch

<<<<<<< HEAD
touch -f $XBPS_FETCH_DONE

=======
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
exit 0
