# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} pypy pypy3 )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Code coverage measurement for Python"
HOMEPAGE="http://nedbatchelder.com/code/coverage/ https://pypi.python.org/pypi/coverage"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND=""
DEPEND="
	>=dev-python/setuptools-18.4[${PYTHON_USEDEP}]
	test? (
		dev-python/PyContracts[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}]
		>=dev-python/mock-2.0.0[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/gevent[${PYTHON_USEDEP}]' python2_7)
		$(python_gen_cond_dep 'dev-python/eventlet[${PYTHON_USEDEP}]' python2_7)
		dev-python/greenlet[${PYTHON_USEDEP}]
		dev-python/unittest-mixins[${PYTHON_USEDEP}]
		dev-python/pyenchant[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	#"${FILESDIR}/test_process.patch"
	"${FILESDIR}/disable-test_egg.patch"
)

python_compile() {
	if [[ ${EPYTHON} == python2.7 ]]; then
		local CFLAGS="${CFLAGS} -fno-strict-aliasing"
		export CFLAGS
	fi

	distutils-r1_python_compile
}

python_test() {
	# add a ${BUILD_DIR}/test.pth file for the egg test to find a usable place to use
	echo "foo" > ${BUILD_DIR}/test.pth
	touch ${BUILD_DIR}/__init__.py
	cd ${S}
	export WRITABLE_TESTPATH="${BUILD_DIR}"
	export PYTHONPATH="${BUILD_DIR}/lib:${PYTHONPATH}"
	[[ "${PYTHON}" =~ pypy ]] && export COVERAGE_NO_EXTENSION=no
	${PYTHON} "${S}"/igor.py zip_mods install_egg || die "Failed to create tests/zip_mods.zip"
	# Remove the C extension so that we can test the PyTracer
	${PYTHON} "${S}"/igor.py remove_extension || die "Failed to remove the C extension"
	${PYTHON} "${S}"/igor.py test_with_tracer py || die "Failed tests with the python tracer"
	${PYTHON} "${S}"/igor.py test_with_tracer c || die "Failed tests with the python tracer"
}
