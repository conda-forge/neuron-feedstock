# cancel culling of unused libs
# it seems to cull libs that are actually used
export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"

# force shortnames of compilers since package contains references to these
if [[ "$(uname)" == "Darwin" ]]; then
  export CC=clang
  export CXX=clang++
  # LDSHARED needed for Python (mac only, apparently)
  export LDSHARED="${LD:-$CXX} -bundle -undefined dynamic_lookup $LDFLAGS"
else
  export CC=$(basename $CC)
  export CXX=$(basename $CXX)
  # clear C++ compiler flags, which have been identified
  # as the culprit
  export CPPFLAGS="-I$PREFIX/include"
  export CXXFLAGS="-fPIC -I$PREFIX/include"
fi


# force cython recompile by removing cython-generated sources
find share/lib/python -name "*.cpp" -exec rm {} \;

aclocal -Im4
automake
autoconf

EXTRA_CONFIG=""
if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  EXTRA_CONFIG="--with-mpi $EXTRA_CONFIG"
fi


./configure \
    --without-x \
    --with-nrnpython=$PYTHON \
    --prefix=$PREFIX \
    --exec-prefix=$PREFIX \
    $EXTRA_CONFIG

make -j ${NUM_CPUS:-1}
make install

# make install copies a bunch of intermediate files that shouldn't be installed
rm -f "${PREFIX}/lib/*.la"
rm -f "${PREFIX}/lib/*.o"

# redo Python binding installation
# since package installs in lib/python instead of proper site-packages
cd src/nrnpython
python setup.py install
rm -rf $PREFIX/lib/python/neuron
rm -rf $PREFIX/share/neuron/lib/python

python -c 'import neuron.hoc'
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"

