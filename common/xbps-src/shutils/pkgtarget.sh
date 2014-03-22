<<<<<<< HEAD
# vim: set ts=4 sw=4 et:

check_existing_pkg() {
    local arch= curpkg=
    if [ -z "$XBPS_PRESERVE_PKGS" ] || [ "$XBPS_BUILD_FORCEMODE" ]; then
        return
    fi
    arch=$XBPS_TARGET_MACHINE
    curpkg=$XBPS_REPOSITORY/$repository/$pkgver.$arch.xbps
    if [ -e $curpkg ]; then
        msg_warn "$pkgver: skipping build due to existing $curpkg\n"
        exit 0
    fi
}

check_pkg_arch() {
    local cross="$1" _arch f match nonegation

    if [ -n "$archs" ]; then
        if [ -n "$cross" ]; then
            _arch="$XBPS_TARGET_MACHINE"
        elif [ -n "$XBPS_ARCH" ]; then
            _arch="$XBPS_ARCH"
        else
            _arch="$XBPS_MACHINE"
        fi
        set -f
        for f in ${archs}; do
            set +f
            nonegation=${f##\~*}
            f=${f#\~}
            case "${_arch}" in
                $f) match=1; break ;;
            esac
        done
        if [ -z "$nonegation" -a -n "$match" ] || [ -n "$nonegation" -a -z "$match" ]; then
            report_broken "${pkgname}-${version}_${revision}: this package cannot be built for ${_arch}.\n"
        fi
    fi
}

# Returns 1 if pkg is available in xbps repositories, 0 otherwise.
pkg_available() {
    local pkg="$1" cross="$2" pkgver

    if [ -n "$cross" ]; then
        pkgver=$($XBPS_QUERY_XCMD -R -ppkgver "${pkg}" 2>/dev/null)
    else
        pkgver=$($XBPS_QUERY_CMD -R -ppkgver "${pkg}" 2>/dev/null)
    fi

    if [ -z "$pkgver" ]; then
        return 0
    fi
    return 1
}

remove_pkg_autodeps() {
    local rval= tmplogf= errlogf= prevs=

    cd $XBPS_MASTERDIR || return 1
    msg_normal "${pkgver:-xbps-src}: removing autodeps, please wait...\n"
    tmplogf=$(mktemp) || exit 1
    errlogf=$(mktemp) || exit 1

    remove_pkg_cross_deps
    $XBPS_RECONFIGURE_CMD -a >> $tmplogf 2>&1
    prevs=$(stat_size $tmplogf)
    echo yes | $XBPS_REMOVE_CMD -Ryod 2>> $errlogf 1>> $tmplogf
    rval=$?
    while [ $rval -eq 0 ]; do
        local curs=$(stat_size $tmplogf)
        if [ $curs -eq $prevs ]; then
            break
        fi
        prevs=$curs
        echo yes | $XBPS_REMOVE_CMD -Ryod 2>> $errlogf 1>> $tmplogf
        rval=$?
    done

    if [ $rval -ne 0 ]; then
        msg_red "${pkgver:-xbps-src}: failed to remove autodeps: (returned $rval)\n"
        cat $tmplogf && rm -f $tmplogf
        cat $errlogf && rm -f $errlogf
        msg_error "${pkgver:-xbps-src}: cannot continue!\n"
    fi
    rm -f $tmplogf
    rm -f $errlogf
}

remove_pkg_wrksrc() {
    if [ -d "$wrksrc" ]; then
        msg_normal "$pkgver: cleaning build directory...\n"
        rm -rf "$wrksrc" 2>/dev/null || chmod -R +wX "$wrksrc" # Needed to delete Go Modules
        rm -rf "$wrksrc"
    fi
}

remove_pkg_statedir() {
    if [ -d "$XBPS_STATEDIR" ]; then
        rm -rf "$XBPS_STATEDIR"
    fi
}

remove_pkg() {
    local cross="$1" _destdir f

    [ -z $pkgname ] && msg_error "nonexistent package, aborting.\n"

    if [ -n "$cross" ]; then
        _destdir="$XBPS_DESTDIR/$XBPS_CROSS_TRIPLET"
    else
        _destdir="$XBPS_DESTDIR"
    fi

    [ ! -d ${_destdir} ] && return

    for f in ${sourcepkg} ${subpackages}; do
        if [ -d "${_destdir}/${f}-${version}" ]; then
            msg_normal "$f: removing files from destdir...\n"
            rm -rf ${_destdir}/${f}-${version}
        fi
        if [ -d "${_destdir}/${f}-dbg-${version}" ]; then
            msg_normal "$f: removing dbg files from destdir...\n"
            rm -rf ${_destdir}/${f}-dbg-${version}
        fi
        if [ -d "${_destdir}/${f}-32bit-${version}" ]; then
            msg_normal "$f: removing 32bit files from destdir...\n"
            rm -rf ${_destdir}/${f}-32bit-${version}
        fi
        rm -f ${XBPS_STATEDIR}/${f}_${cross}_subpkg_install_done
        rm -f ${XBPS_STATEDIR}/${f}_${cross}_prepkg_done
    done
    rm -f ${XBPS_STATEDIR}/${sourcepkg}_${cross}_install_done
    rm -f ${XBPS_STATEDIR}/${sourcepkg}_${cross}_pre_install_done
    rm -f ${XBPS_STATEDIR}/${sourcepkg}_${cross}_post_install_done
=======
# -*-* shell *-*-

show_build_options() {
	local f opt desc

	[ -z "$PKG_BUILD_OPTIONS" ] && return 0

	msg_normal "$pkgver: the following build options are set:\n"
	for f in ${PKG_BUILD_OPTIONS}; do
		opt="${f#\~}"
		eval desc="\${desc_option_${opt}}"
		if [[ ${f:0:1} == '~' ]]; then
			echo "    $opt: $desc (OFF)"
		else
			printf "    "
			msg_normal_append "$opt: "
			printf "$desc (ON)\n"
		fi
	done
}

check_pkg_arch() {
	local cross="$1"

	if [ -n "$BEGIN_INSTALL" -a -n "$only_for_archs" ]; then
		if [ -n "$cross" ]; then
			_arch="$XBPS_TARGET_MACHINE"
		elif [ -n "$XBPS_ARCH" ]; then
			_arch="$XBPS_ARCH"
		else
			_arch="$XBPS_MACHINE"
		fi
		for f in ${only_for_archs}; do
			if [ "$f" = "${_arch}" ]; then
				found=1
				break
			fi
		done
		if [ -z "$found" ]; then
			msg_red "$pkgname: this package cannot be built for ${_arch}.\n"
			exit 0
		fi
	fi
}

install_pkg() {
	local target="$1" cross="$2" lrepo subpkg opkg

	[ -z "$pkgname" ] && return 1

	show_build_options
	check_pkg_arch $cross
	install_cross_pkg $cross

	if [ -z "$XBPS_SKIP_DEPS" ]; then
		install_pkg_deps $sourcepkg $cross || return 1
		if [ "$TARGETPKG_PKGDEPS_DONE" ]; then
			setup_pkg $XBPS_TARGET_PKG $cross
			unset TARGETPKG_PKGDEPS_DONE
			install_cross_pkg $cross
		fi
	fi

	# Fetch distfiles after installing required dependencies,
	# because some of them might be required for do_fetch().
	$XBPS_LIBEXECDIR/xbps-src-dofetch.sh $sourcepkg $cross || exit 1
	[ "$target" = "fetch" ] && return 0

	# Fetch, extract, build and install into the destination directory.
	$XBPS_LIBEXECDIR/xbps-src-doextract.sh $sourcepkg $cross || exit 1
	[ "$target" = "extract" ] && return 0

	# Run configure phase
	$XBPS_LIBEXECDIR/xbps-src-doconfigure.sh $sourcepkg $cross || exit 1
	[ "$target" = "configure" ] && return 0

	# Run build phase
	$XBPS_LIBEXECDIR/xbps-src-dobuild.sh $sourcepkg $cross || exit 1
	[ "$target" = "build" ] && return 0

	# Install sourcepkg into destdir.
	$FAKEROOT_CMD $XBPS_LIBEXECDIR/xbps-src-doinstall.sh $sourcepkg $cross || exit 1

	for subpkg in ${subpackages} ${sourcepkg}; do
		# Run subpkg pkg_install func.
		$FAKEROOT_CMD $XBPS_LIBEXECDIR/xbps-src-dopkg.sh $subpkg $cross || exit 1
	done

	if [ "$XBPS_TARGET_PKG" = "$sourcepkg" ]; then
		[ "$target" = "install-destdir" ] && return 0
	fi

	# If install went ok generate the binpkgs.
	for subpkg in ${sourcepkg} ${subpackages}; do
		$FAKEROOT_CMD $XBPS_LIBEXECDIR/xbps-src-genpkg.sh $subpkg "$XBPS_REPOSITORY" "$cross" || exit 1
	done

	# pkg cleanup
	if declare -f do_clean >/dev/null; then
		run_func do_clean
	fi

	opkg=$pkgver
	if [ -z "$XBPS_KEEP_ALL" ]; then
		remove_pkg_autodeps
		remove_pkg_wrksrc
		setup_pkg $sourcepkg $cross
		remove_pkg $cross
	fi

	# If base-chroot not installed, install binpkg into masterdir
	# from local repository.
	if [ -z "$CHROOT_READY" ]; then
		msg_normal "Installing $opkg into masterdir...\n"
		local _log=$(mktemp --tmpdir|| exit 1)
		if [ -n "$XBPS_BUILD_FORCEMODE" ]; then
			local _flags="-f"
		fi
		$XBPS_INSTALL_CMD ${_flags} -y $opkg >${_log} 2>&1
		if [ $? -ne 0 ]; then
			msg_red "Failed to install $opkg into masterdir, see below for errors:\n"
			cat ${_log}
			rm -f ${_log}
			msg_error "Cannot continue!"
		fi
		rm -f ${_log}
	fi

	if [ "$XBPS_TARGET_PKG" = "$sourcepkg" ]; then
		# Package built successfully. Exit directly due to nested install_pkg
		# and install_pkg_deps functions.
		remove_cross_pkg $cross
		exit 0
	fi
}

remove_pkg_wrksrc() {
	if [ -d "$wrksrc" ]; then
		msg_normal "$pkgver: cleaning build directory...\n"
		rm -rf $wrksrc
	fi
}

remove_pkg() {
	local cross="$1" _destdir f

	[ -z $pkgname ] && msg_error "unexistent package, aborting.\n"

	if [ -n "$cross" ]; then
		_destdir="$XBPS_DESTDIR/$XBPS_CROSS_TRIPLET"
	else
		_destdir="$XBPS_DESTDIR"
	fi

	for f in ${sourcepkg} ${subpackages}; do
		if [ -d "${_destdir}/${f}-${version}" ]; then
			msg_normal "$f: removing files from destdir...\n"
			rm -rf ${_destdir}/${f}-${version}
		fi
		if [ -d "${_destdir}/${f}-dbg-${version}" ]; then
			msg_normal "$f: removing dbg files from destdir...\n"
			rm -rf ${_destdir}/${f}-dbg-${version}
		fi
		if [ -d "${_destdir}/${f}-32bit-${version}" ]; then
			msg_normal "$f: removing 32bit files from destdir...\n"
			rm -rf ${_destdir}/${f}-32bit-${version}
		fi
		rm -f $wrksrc/.xbps_${f}_${cross}_pre_install_done
		rm -f $wrksrc/.xbps_${f}_${cross}_install_done
		rm -f $wrksrc/.xbps_${f}_${cross}_post_install_done
		rm -f $wrksrc/.xbps_${f}_${cross}_pkg_done
		rm -f $wrksrc/.xbps_${f}_${cross}_strip_done
	done
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
}
