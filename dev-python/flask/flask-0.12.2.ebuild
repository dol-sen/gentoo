# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy{,3} )

inherit distutils-r1

DESCRIPTION="A microframework based on Werkzeug, Jinja2 and good intentions"
HOMEPAGE="https://github.com/pallets/flask/"
MY_PN="Flask"
MY_P="${MY_PN}-${PV}"
if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/mitsuhiko/flask.git"
	inherit git-r3
else
	SRC_URI="mirror://pypi/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"
	KEYWORDS="amd64 arm ~arm64 ppc ppc64 x86 ~amd64-linux ~x86-linux"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="BSD"
SLOT="0"
IUSE="doc examples test"

RDEPEND=">=dev-python/click-2[${PYTHON_USEDEP}]
	>=dev-python/blinker-1[${PYTHON_USEDEP}]
	>=dev-python/itsdangerous-0.21[${PYTHON_USEDEP}]
	>=dev-python/jinja-2.4[${PYTHON_USEDEP}]
	>=dev-python/werkzeug-0.7[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )"

python_prepare_all() {
	# Prevent un-needed d'loading
	sed -e "s/ 'sphinx.ext.intersphinx',//" -i docs/conf.py || die
	# DeprecationWarning: Flags not at the start of the expression
	sed -e "s/r'\(.*\)\((?.*)\)'/r'\2\1'/" -i tests/test_basic.py || die
	# issubclass(ModuleNotFoundError, ImportError)
	sed -e 's/\(excinfo.type\) is \(ImportError\)/issubclass(\1, \2)/' \
		-i tests/test_ext.py || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	PYTHONPATH=${S}/examples/flaskr:${S}/examples/minitwit${PYTHONPATH:+:${PYTHONPATH}} \
		py.test -v || die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	use examples && dodoc -r examples
	use doc && HTML_DOCS=( docs/_build/html/. )

	distutils-r1_python_install_all
}
