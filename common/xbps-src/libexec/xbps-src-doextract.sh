#!/bin/bash
#
<<<<<<< HEAD
# vim: set ts=4 sw=4 et:
#
=======
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
# Passed arguments:
#	$1 - pkgname [REQUIRED]
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

for f in $XBPS_COMMONDIR/environment/extract/*.sh; do
<<<<<<< HEAD
    source_file "$f"
done

XBPS_EXTRACT_DONE="${XBPS_STATEDIR}/${sourcepkg}_${XBPS_CROSS_BUILD}_extract_done"

if [ -f $XBPS_EXTRACT_DONE ]; then
    exit 0
=======
	source_file "$f"
done

XBPS_EXTRACT_DONE="$wrksrc/.xbps_extract_done"

if [ -f $XBPS_EXTRACT_DONE ]; then
	exit 0
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# Run pre-extract hooks
run_pkg_hooks pre-extract

# If template defines pre_extract(), use it.
if declare -f pre_extract >/dev/null; then
<<<<<<< HEAD
    run_func pre_extract
=======
	run_func pre_extract
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# If template defines do_extract() use it rather than the hooks.
if declare -f do_extract >/dev/null; then
<<<<<<< HEAD
    [ ! -d "$wrksrc" ] && mkdir -p "$wrksrc"
    cd "$wrksrc"
    run_func do_extract
else
    if [ -n "$build_style" ]; then
        if [ ! -r $XBPS_BUILDSTYLEDIR/${build_style}.sh ]; then
            msg_error "$pkgver: cannot find build helper $XBPS_BUILDSTYLEDIR/${build_style}.sh!\n"
        fi
        . $XBPS_BUILDSTYLEDIR/${build_style}.sh
    fi
    # If the build_style script declares do_extract(), use it rather than hooks.
    if declare -f do_extract >/dev/null; then
        run_func do_extract
    else
        # Run do-extract hooks
        run_pkg_hooks "do-extract"
    fi
fi


[ -d "$wrksrc" ] && cd "$wrksrc"

# If template defines post_extract(), use it.
if declare -f post_extract >/dev/null; then
    run_func post_extract
=======
	[ ! -d "$wrksrc" ] && mkdir -p $wrksrc
	cd $wrksrc
	run_func do_extract
else
	# Run do-extract hooks
	run_pkg_hooks "do-extract"
fi

touch -f $XBPS_EXTRACT_DONE

# If template defines post_extract(), use it.
if declare -f post_extract >/dev/null; then
	run_func post_extract
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
fi

# Run post-extract hooks
run_pkg_hooks post-extract

<<<<<<< HEAD
touch -f $XBPS_EXTRACT_DONE

=======
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
exit 0
