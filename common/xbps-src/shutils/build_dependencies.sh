<<<<<<< HEAD
# vim: set ts=4 sw=4 et:
#
setup_pkg_depends() {
    local pkg="$1" out="$2" with_subpkgs="$3" j _rpkgname _depname _pkgname foo _deps collected

    if [[ $pkg ]]; then
        # subpkg
        if declare -f ${pkg}_package >/dev/null; then
            ${pkg}_package
        fi
    elif [[ $with_subpkgs ]]; then
        collected="${depends}"
        for pkg in $subpackages; do
            [[ $pkg ]] || continue
            ${pkg}_package
            collected+=" ${depends}"
        done
        depends="${collected}"
    fi

    for j in ${depends}; do
        _rpkgname="${j%\?*}"
        _depname="${j#*\?}"
        if [[ ${_rpkgname} == virtual ]]; then
            _pkgname=$(xbps-uhelper getpkgname $_depname 2>/dev/null)
            [ -z "$_pkgname" ] && _pkgname="$_depname"
            if [ -s ${XBPS_DISTDIR}/etc/virtual ]; then
                foo=$(grep -E "^${_pkgname}[[:blank:]]" ${XBPS_DISTDIR}/etc/virtual|cut -d ' ' -f2)
            elif [ -s ${XBPS_DISTDIR}/etc/defaults.virtual ]; then
                foo=$(grep -E "^${_pkgname}[[:blank:]]" ${XBPS_DISTDIR}/etc/defaults.virtual|cut -d ' ' -f2)
            fi
            if [ -z "$foo" ]; then
                msg_error "$pkgver: failed to resolve virtual dependency for '$j' (missing from etc/virtual)\n"
            fi
            [[ $out ]] && echo "$foo"
        else
            foo="$($XBPS_UHELPER_CMD getpkgdepname ${_depname} 2>/dev/null)"
            if [ -z "$foo" ]; then
                foo="$($XBPS_UHELPER_CMD getpkgname ${_depname} 2>/dev/null)"
                [ -z "$foo" ] && foo="${_depname}"
            fi
            [[ $out ]] && echo "$foo"
        fi
        run_depends+="${_depname} "
    done

    return 0
}

#
# Install required package dependencies, like:
#
#	xbps-install -Ay <pkgs>
#
#       -A automatic mode
#       -y yes
=======
# -*-* shell *-*-
#
# Install a required package dependency, like:
#
#	xbps-install -Ay <pkgname>
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
#
# Returns 0 if package already installed or installed successfully.
# Any other error number otherwise.
#
<<<<<<< HEAD
# SUCCESS  (0): package installed successfully.
# ENOENT   (2): package missing in repositories.
# ENXIO    (6): package depends on invalid dependencies.
# EAGAIN  (11): package conflicts.
# EBUSY   (16): package 'xbps' needs to be updated.
# EEXIST  (17): file conflicts in transaction (XBPS_FLAG_IGNORE_FILE_CONFLICTS unset)
# ENODEV  (19): package depends on missing dependencies.
# ENOTSUP (95): no repositories registered.
# -1     (255): unexpected error.

install_pkg_from_repos() {
    local cross="$1" target="$2" rval tmplogf cmd
    shift 2

    [ $# -eq 0 ] && return 0

    mkdir -p $XBPS_STATEDIR
    tmplogf=${XBPS_STATEDIR}/xbps_${XBPS_TARGET_MACHINE}_bdep_${pkg}.log

    cmd=$XBPS_INSTALL_CMD
    [[ $cross ]] && cmd=$XBPS_INSTALL_XCMD
    $cmd -Ay "$@" >$tmplogf 2>&1
    rval=$?

    case "$rval" in
        0) # success, check if there are errors.
           errortmpf=$(mktemp) || exit 1
           grep ^ERROR $tmplogf > $errortmpf
           [ -s $errortmpf ] && cat $errortmpf
           rm -f $errortmpf
           ;;
        *)
           [ -z "$XBPS_KEEP_ALL" ] && remove_pkg_autodeps
           msg_red "$pkgver: failed to install $target dependencies! (error $rval)\n"
           cat $tmplogf
           rm -f $tmplogf
           msg_error "Please see above for the real error, exiting...\n"
           ;;
    esac
    rm -f $tmplogf
    return $rval
}

#
# Returns 0 if pkgpattern in $1 is installed and greater than current
# installed package, otherwise 1.
#
check_installed_pkg() {
    local pkg="$1" cross="$2" uhelper= pkgn= iver=

    [ -z "$pkg" ] && return 2

    pkgn="$($XBPS_UHELPER_CMD getpkgname ${pkg})"
    [ -z "$pkgn" ] && return 2

    uhelper=$XBPS_UHELPER_CMD
    [[ $cross ]] && uhelper=$XBPS_UHELPER_XCMD
    iver="$($uhelper version $pkgn)"
    if [ $? -eq 0 -a -n "$iver" ]; then
        $XBPS_CMPVER_CMD "${pkgn}-${iver}" "${pkg}"
        [ $? -eq 0 -o $? -eq 1 ] && return 0
    fi

    return 1
}

#
# Return 0 if we will skip the check step
#
skip_check_step() {
    [ -z "$XBPS_CHECK_PKGS" ] ||
        [ "$XBPS_CROSS_BUILD" ] ||
        [ "$make_check" = ci-skip  -a "$XBPS_BUILD_ENVIRONMENT" = void-packages-ci ] ||
        [ "$make_check" = extended -a "$XBPS_CHECK_PKGS" != full ] ||
        [ "$make_check" = no ]
}

#
# Build all dependencies required to build and run.
#
install_pkg_deps() {
    local pkg="$1" targetpkg="$2" target="$3" cross="$4" cross_prepare="$5"
    local _vpkg curpkgdepname
    local i j found style
    local templates=""

    local -a host_binpkg_deps binpkg_deps
    local -a host_missing_deps missing_deps missing_rdeps

    [ -z "$pkgname" ] && return 2
    skip_check_step && unset checkdepends

    if [[ $build_style ]] || [[ $build_helper ]]; then
        style=" with"
    fi

    [[ $build_style ]] && style+=" [$build_style]"

    for s in $build_helper; do
        style+=" [$s]"
    done

    if [ "$pkg" != "$targetpkg" ]; then
        msg_normal "$pkgver: building${style} (dependency of $targetpkg) for $XBPS_TARGET_MACHINE...\n"
    else
        msg_normal "$pkgver: building${style} for $XBPS_TARGET_MACHINE...\n"
    fi

    #
    # Host build dependencies.
    #
    if [[ ${hostmakedepends} ]]; then
        templates=""
        # check validity
        for f in ${hostmakedepends}; do
            if [ -f $XBPS_SRCPKGDIR/$f/template ]; then
                templates+=" $f"
                continue
            fi
            local _repourl=$($XBPS_QUERY_CMD -R -prepository "$f" 2>/dev/null)
            if [ "$_repourl" ]; then
                echo "   [host] ${f}: found (${_repourl})"
                host_binpkg_deps+=("$f")
                continue
            fi
            msg_error "$pkgver: host dependency '$f' does not exist!\n"
        done
        while read -r _depname _deprepover _depver _subpkg _repourl; do
            _vpkg=${_subpkg}-${_depver}
            # binary package found in a repo
            if [[ ${_depver} == ${_deprepover} ]]; then
                echo "   [host] ${_vpkg}: found (${_repourl})"
                host_binpkg_deps+=("${_vpkg}")
                continue
            fi
            # binary package not found
            if [[ $_depname != $_subpkg ]]; then
                # subpkg, check if it's a subpkg of itself
                found=0
                for f in ${subpackages}; do
                    if [[ ${_subpkg} == ${f} ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 1 ]] && [[ -z "$cross" ]]; then
                    echo "   [host] ${_vpkg}: not found (subpkg, ignored)"
                else
                    echo "   [host] ${_vpkg}: not found"
                    host_missing_deps+=("$_vpkg")
                fi
            else
                echo "   [host] ${_vpkg}: not found"
                host_missing_deps+=("$_vpkg")
            fi
        done < <($XBPS_CHECKVERS_CMD -D $XBPS_DISTDIR -sm $templates)
    fi

    #
    # Host check dependencies.
    #
    if [[ ${checkdepends} ]]; then
        templates=""
        # check validity
        for f in ${checkdepends}; do
            if [ -f $XBPS_SRCPKGDIR/$f/template ]; then
                templates+=" $f"
                continue
            fi
            local _repourl=$($XBPS_QUERY_CMD -R -prepository "$f" 2>/dev/null)
            if [ "$_repourl" ]; then
                echo "   [host] ${f}: found (${_repourl})"
                host_binpkg_deps+=("$f")
                continue
            fi
            msg_error "$pkgver: check dependency '$f' does not exist!\n"
        done
        while read -r _depname _deprepover _depver _subpkg _repourl; do
            _vpkg=${_subpkg}-${_depver}
            # binary package found in a repo
            if [[ ${_depver} == ${_deprepover} ]]; then
                echo "   [check] ${_vpkg}: found (${_repourl})"
                host_binpkg_deps+=("${_vpkg}")
                continue
            fi
            # binary package not found
            if [[ $_depname != $_subpkg ]]; then
                # subpkg, check if it's a subpkg of itself
                found=0
                for f in ${subpackages}; do
                    if [[ ${_subpkg} == ${f} ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 1 ]]; then
                    echo "   [check] ${_vpkg}: not found (subpkg, ignored)"
                else
                    echo "   [check] ${_vpkg}: not found"
                    host_missing_deps+=("$_vpkg")
                fi
            else
                echo "   [check] ${_vpkg}: not found"
                host_missing_deps+=("$_vpkg")
            fi
        done < <($XBPS_CHECKVERS_CMD -D $XBPS_DISTDIR -sm ${templates})
    fi

    #
    # Target build dependencies.
    #
    if [[ ${makedepends} ]]; then
        templates=""
        # check validity
        for f in ${makedepends}; do
            if [ -f $XBPS_SRCPKGDIR/$f/template ]; then
                templates+=" $f"
                continue
            fi
            local _repourl=$($XBPS_QUERY_XCMD -R -prepository "$f" 2>/dev/null)
            if [ "$_repourl" ]; then
                echo "   [target] ${f}: found (${_repourl})"
                binpkg_deps+=("$f")
                continue
            fi
            msg_error "$pkgver: target dependency '$f' does not exist!\n"
        done
        while read -r _depname _deprepover _depver _subpkg _repourl; do
            _vpkg=${_subpkg}-${_depver}
            # binary package found in a repo
            if [[ ${_depver} == ${_deprepover} ]]; then
                echo "   [target] ${_vpkg}: found (${_repourl})"
                binpkg_deps+=("${_vpkg}")
                continue
            fi
            # binary package not found
            if [[ $_depname != $_subpkg ]]; then
                # subpkg, check if it's a subpkg of itself
                found=0
                for f in ${subpackages}; do
                    if [[ ${_subpkg} == ${f} ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 1 ]]; then
                    msg_error "[target] ${_vpkg}: target dependency '${_subpkg}' is a subpackage of $pkgname\n"
                else
                    echo "   [target] ${_vpkg}: not found"
                    missing_deps+=("$_vpkg")
                fi
            else
                echo "   [target] ${_vpkg}: not found"
                missing_deps+=("$_vpkg")
            fi
        done < <($XBPS_CHECKVERS_XCMD -D $XBPS_DISTDIR -sm $templates)
    fi

    #
    # Target run time dependencies
    #
    local _cleandeps=$(setup_pkg_depends "" 1 1) || exit 1
    if [[ ${_cleandeps} ]]; then
        templates=""
        for f in ${_cleandeps}; do
            if [ -f $XBPS_SRCPKGDIR/$f/template ]; then
                templates+=" $f"
                continue
            fi
            local _repourl=$($XBPS_QUERY_XCMD -R -prepository "$f" 2>/dev/null)
            if [ "$_repourl" ]; then
                echo "   [target] ${f}: found (${_repourl})"
                continue
            fi
            msg_error "$pkgver: target dependency '$f' does not exist!\n"
        done
        while read -r _depname _deprepover _depver _subpkg _repourl; do
            _vpkg=${_subpkg}-${_depver}
            # binary package found in a repo
            if [[ ${_depver} == ${_deprepover} ]]; then
                echo "   [runtime] ${_vpkg}: found (${_repourl})"
                continue
            fi
            # binary package not found
            if [[ $_depname != $_subpkg ]]; then
                # subpkg, check if it's a subpkg of itself
                found=0
                for f in ${subpackages}; do
                    if [[ ${_subpkg} == ${f} ]]; then
                        found=1
                        break
                    fi
                done
                if [[ $found -eq 1 ]]; then
                    echo "   [runtime] ${_vpkg}: not found (subpkg, ignored)"
                else
                    echo "   [runtime] ${_vpkg}: not found"
                    missing_rdeps+=("$_vpkg")
                fi
            elif [[ ${_depname} == ${pkgname} ]]; then
                    echo "   [runtime] ${_vpkg}: not found (self, ignored)"
            else
                echo "   [runtime] ${_vpkg}: not found"
                missing_rdeps+=("$_vpkg")
            fi
        done < <($XBPS_CHECKVERS_XCMD -D $XBPS_DISTDIR -sm $templates)
    fi

    if [ -n "$XBPS_BUILD_ONLY_ONE_PKG" ]; then
           for i in ${host_missing_deps[@]}; do
                   msg_error "dep ${i} not found: -1 passed: instructed not to build\n"
           done
           for i in ${missing_rdeps[@]}; do
                   msg_error "dep ${i} not found: -1 passed: instructed not to build\n"
           done
           for i in ${missing_deps[@]}; do
                   msg_error "dep ${i} not found: -1 passed: instructed not to build\n"
           done
    fi

    # Missing host dependencies, build from srcpkgs.
    for i in ${host_missing_deps[@]}; do
        # packages not found in repos, install from source.
        (
        curpkgdepname=$($XBPS_UHELPER_CMD getpkgname "$i" 2>/dev/null)
        setup_pkg $curpkgdepname
        # do not check when building dependencies, except for "full" (-K)
        [ "$XBPS_CHECK_PKGS" == full ] || unset XBPS_CHECK_PKGS
        exec env XBPS_DEPENDENCY=1 XBPS_BINPKG_EXISTS=1 XBPS_DEPENDS_CHAIN="$XBPS_DEPENDS_CHAIN, $sourcepkg(host)" \
            $XBPS_LIBEXECDIR/build.sh $sourcepkg $pkg $target $cross_prepare || exit $?
        ) || exit $?
        host_binpkg_deps+=("$i")
    done

    # Missing target dependencies, build from srcpkgs.
    for i in ${missing_deps[@]}; do
        # packages not found in repos, install from source.
        (

        curpkgdepname=$($XBPS_UHELPER_CMD getpkgname "$i" 2>/dev/null)
        setup_pkg $curpkgdepname $cross
        # do not check when building dependencies, except for "full" (-K)
        [ "$XBPS_CHECK_PKGS" == full ] || unset XBPS_CHECK_PKGS
        exec env XBPS_DEPENDENCY=1 XBPS_BINPKG_EXISTS=1 XBPS_DEPENDS_CHAIN="$XBPS_DEPENDS_CHAIN, $sourcepkg(${cross:-host})" \
            $XBPS_LIBEXECDIR/build.sh $sourcepkg $pkg $target $cross $cross_prepare || exit $?
        ) || exit $?
        binpkg_deps+=("$i")
    done

    # Target runtime missing dependencies, build from srcpkgs.
    for i in ${missing_rdeps[@]}; do
        # packages not found in repos, install from source.
        (
        curpkgdepname=$($XBPS_UHELPER_CMD getpkgdepname "$i" 2>/dev/null)
        if [ -z "$curpkgdepname" ]; then
            curpkgdepname=$($XBPS_UHELPER_CMD getpkgname "$i" 2>/dev/null)
            if [ -z "$curpkgdepname" ]; then
                curpkgdepname="$i"
            fi
        fi
        setup_pkg $curpkgdepname $cross
        # do not check when building dependencies, except for "full" (-K)
        [ "$XBPS_CHECK_PKGS" == full ] || unset XBPS_CHECK_PKGS
        exec env XBPS_DEPENDENCY=1 XBPS_BINPKG_EXISTS=1 XBPS_DEPENDS_CHAIN="$XBPS_DEPENDS_CHAIN, $sourcepkg(${cross:-host})" \
            $XBPS_LIBEXECDIR/build.sh $sourcepkg $pkg $target $cross $cross_prepare || exit $?
        ) || exit $?
    done

    if [[ ${host_binpkg_deps} ]]; then
        msg_normal "$pkgver: installing host dependencies: ${host_binpkg_deps[*]} ...\n"
        install_pkg_from_repos "" host "${host_binpkg_deps[@]}"
    fi

    if [[ ${binpkg_deps} ]]; then
        msg_normal "$pkgver: installing target dependencies: ${binpkg_deps[*]} ...\n"
        install_pkg_from_repos "$cross" target "${binpkg_deps[@]}"
    fi

    return 0
=======
install_pkg_from_repos() {
	local pkg="$1" cross="$2" rval= tmplogf=

	tmplogf=$(mktemp)
	if [ -n "$cross" ]; then
		$FAKEROOT_CMD $XBPS_INSTALL_XCMD -Ayd "$pkg" >$tmplogf 2>&1
	else
		$FAKEROOT_CMD $XBPS_INSTALL_CMD -Ayd "$pkg" >$tmplogf 2>&1
	fi
	rval=$?
	if [ $rval -ne 0 -a $rval -ne 17 ]; then
		# xbps-install can return:
		#
		#	SUCCESS  (0): package installed successfully.
		#	ENOENT   (2): package missing in repositories.
		#	EEXIST  (17): package already installed.
		#	ENODEV  (19): package depends on missing dependencies.
		#	ENOTSUP (95): no repositories registered.
		#
		[ -z "$XBPS_KEEP_ALL" ] && remove_pkg_autodeps
		msg_red "$pkgver: failed to install '$1' dependency! (error $rval)\n"
		cat $tmplogf && rm -f $tmplogf
		msg_error "Please see above for the real error, exiting...\n"
	fi
	rm -f $tmplogf
	[ $rval -eq 17 ] && rval=0
	return $rval
}

#
# Returns 0 if pkgpattern in $1 is matched against current installed
# package, 1 if no match and 2 if not installed.
#
check_pkgdep_matched() {
	local pkg="$1" cross="$2" uhelper= pkgn= iver=

	[ "$build_style" = "meta" ] && return 2
	[ -z "$pkg" ] && return 255

	pkgn="$($XBPS_UHELPER_CMD getpkgdepname ${pkg})"
	if [ -z "$pkgn" ]; then
		pkgn="$($XBPS_UHELPER_CMD getpkgname ${pkg})"
	fi
	[ -z "$pkgn" ] && return 255

	if [ -n "$cross" ]; then
		uhelper="$XBPS_UHELPER_XCMD"
	else
		uhelper="$XBPS_UHELPER_CMD"
	fi

	iver="$($uhelper version $pkgn)"
	if [ $? -eq 0 -a -n "$iver" ]; then
		$XBPS_UHELPER_CMD pkgmatch "${pkgn}-${iver}" "${pkg}"
		[ $? -eq 1 ] && return 0
	else
		return 2
	fi

	return 1
}

#
# Installs all dependencies required by a package.
#
install_pkg_deps() {
	local pkg="$1" cross="$2" i rval _realpkg curpkgdepname pkgn iver _props _exact

	local -a host_binpkg_deps binpkg_deps
	local -a host_missing_deps missing_deps

	[ -z "$pkgname" ] && return 2

	setup_pkg_depends

	if [ -z "$build_depends" -a -z "$host_build_depends" ]; then
		return 0
	fi

	msg_normal "$pkgver: required dependencies:\n"

	#
	# Host build dependencies.
	#
	for i in ${host_build_depends}; do
		_realpkg="${i%\?*}"
		pkgn=$($XBPS_UHELPER_CMD getpkgdepname "${_realpkg}")
		if [ -z "$pkgn" ]; then
			pkgn=$($XBPS_UHELPER_CMD getpkgname "${_realpkg}")
			if [ -z "$pkgn" ]; then
				msg_error "$pkgver: invalid build dependency: ${i}\n"
			fi
			_exact=1
		fi
		check_pkgdep_matched "${_realpkg}"
		local rval=$?
		if [ $rval -eq 0 ]; then
			iver=$($XBPS_UHELPER_CMD version "${pkgn}")
			if [ $? -eq 0 -a -n "$iver" ]; then
				echo "   [host] ${_realpkg}: found '$pkgn-$iver'."
				continue
			fi
		elif [ $rval -eq 1 ]; then
			iver=$($XBPS_UHELPER_CMD version "${pkgn}")
			if [ $? -eq 0 -a -n "$iver" ]; then
				echo "   [host] ${_realpkg}: installed ${iver} (unresolved) removing..."
				$FAKEROOT_CMD $XBPS_REMOVE_CMD -iyf $pkgn >/dev/null 2>&1
			fi
		else
			if [ -n "${_exact}" ]; then
				unset _exact
				_props=$($XBPS_QUERY_CMD -R -ppkgver,repository "${pkgn}" 2>/dev/null)
			else
				_props=$($XBPS_QUERY_CMD -R -ppkgver,repository "${_realpkg}" 2>/dev/null)
			fi
			if [ -n "${_props}" ]; then
				set -- ${_props}
				$XBPS_UHELPER_CMD pkgmatch ${1} "${_realpkg}"
				if [ $? -eq 1 ]; then
					echo "   [host] ${_realpkg}: found $1 in $2."
					host_binpkg_deps+=("$1")
					shift 2
					continue
				else
					echo "   [host] ${_realpkg}: not found."
				fi
				shift 2
			else
				echo "   [host] ${_realpkg}: not found."
			fi
		fi
		host_missing_deps+=("${_realpkg}")
	done

	#
	# Target build dependencies.
	#
	for i in ${build_depends}; do
		_realpkg="${i%\?*}"
		pkgn=$($XBPS_UHELPER_CMD getpkgdepname "${_realpkg}")
		if [ -z "$pkgn" ]; then
			pkgn=$($XBPS_UHELPER_CMD getpkgname "${_realpkg}")
			if [ -z "$pkgn" ]; then
				msg_error "$pkgver: invalid build dependency: ${_realpkg}\n"
			fi
			_exact=1
		fi
		check_pkgdep_matched "${_realpkg}" $cross
		local rval=$?
		if [ $rval -eq 0 ]; then
			iver=$($XBPS_UHELPER_XCMD version "${pkgn}")
			if [ $? -eq 0 -a -n "$iver" ]; then
				echo "   [target] ${_realpkg}: found '$pkgn-$iver'."
				continue
			fi
		elif [ $rval -eq 1 ]; then
			iver=$($XBPS_UHELPER_XCMD version "${pkgn}")
			if [ $? -eq 0 -a -n "$iver" ]; then
				echo "   [target] ${_realpkg}: installed ${iver} (unresolved) removing..."
				$XBPS_REMOVE_XCMD -iyf $pkgn >/dev/null 2>&1
			fi
		else
			if [ -n "${_exact}" ]; then
				unset _exact
				_props=$($XBPS_QUERY_XCMD -R -ppkgver,repository "${pkgn}" 2>/dev/null)
			else
				_props=$($XBPS_QUERY_XCMD -R -ppkgver,repository "${_realpkg}" 2>/dev/null)
			fi
			if [ -n "${_props}" ]; then
				set -- ${_props}
				$XBPS_UHELPER_CMD pkgmatch ${1} "${_realpkg}"
				if [ $? -eq 1 ]; then
					echo "   [target] ${_realpkg}: found $1 in $2."
					binpkg_deps+=("$1")
					shift 2
					continue
				else
					echo "   [target] ${_realpkg}: not found."
				fi
				shift 2
			else
				echo "   [target] ${_realpkg}: not found."
			fi
		fi
		missing_deps+=("${_realpkg}")
	done

	# Host missing dependencies, build from srcpkgs.
	for i in ${host_missing_deps[@]}; do
		curpkgdepname=$($XBPS_UHELPER_CMD getpkgdepname "$i")
		setup_pkg $curpkgdepname
		${XBPS_UHELPER_CMD} pkgmatch "$pkgver" "$i"
		if [ $? -eq 0 ]; then
			setup_pkg $XBPS_TARGET_PKG
			msg_error_nochroot "$pkgver: required host dependency '$i' cannot be resolved!\n"
		fi
		install_pkg full
		setup_pkg $XBPS_TARGET_PKG $XBPS_CROSS_BUILD
		install_pkg_deps $sourcepkg $XBPS_CROSS_BUILD
	done

	# Target missing dependencies, build from srcpkgs.
	for i in ${missing_deps[@]}; do
		# packages not found in repos, install from source.
		curpkgdepname=$($XBPS_UHELPER_CMD getpkgdepname "$i")
		setup_pkg $curpkgdepname $cross
		# Check if version in srcpkg satisfied required dependency,
		# and bail out if doesn't.
		$XBPS_UHELPER_CMD pkgmatch "$pkgver" "$i"
		if [ $? -eq 0 ]; then
			setup_pkg $XBPS_TARGET_PKG $cross
			msg_error_nochroot "$pkgver: required target dependency '$i' cannot be resolved!\n"
		fi
		install_pkg full $cross
		setup_pkg $XBPS_TARGET_PKG $XBPS_CROSS_BUILD
		install_pkg_deps $sourcepkg $XBPS_CROSS_BUILD
	done

	if [ "$TARGETPKG_PKGDEPS_DONE" ]; then
		return 0
	fi

	for i in ${host_binpkg_deps[@]}; do
		msg_normal "$pkgver: installing host dependency '$i' ...\n"
		install_pkg_from_repos "${i}"
	done

	for i in ${binpkg_deps[@]}; do
		if [ -n "$CHROOT_READY" -a "$build_style" = "meta" ]; then
			continue
		fi
		msg_normal "$pkgver: installing target dependency '$i' ...\n"
		install_pkg_from_repos "$i" $cross
	done

	if [ "$XBPS_TARGET_PKG" = "$sourcepkg" ]; then
		TARGETPKG_PKGDEPS_DONE=1
	fi
>>>>>>> 9e804ed8d18 (Merge xbps-src code to make it usable in a standalone mode.)
}
