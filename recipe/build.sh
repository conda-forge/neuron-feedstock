set -ex
# check-in with neuron CI when updating
# https://github.com/neuronsimulator/nrn/blob/HEAD/.github/workflows/neuron-ci.yml

# cancel culling of unused libs
# it seems to cull libs that are actually used
export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"

# force shortnames of compilers since package contains references to these

CMAKE_CONFIG=""

if [[ "$(uname)" == "Darwin" ]]; then
  export CC=clang
  export CXX=clang++
  # LDSHARED needed for Python (mac only, apparently)
  export LDSHARED="${LD:-$CXX} -bundle -undefined dynamic_lookup $LDFLAGS"
  CMAKE_CONFIG="$CMAKE_CONFIG -DCURSES_NEED_NCURSES=ON"
else
  export CC=$(basename $CC)
  export CXX=$(basename $CXX)
  # clear C++ compiler flags, which have been identified
  # as the culprit
  # export CPPFLAGS="-I$PREFIX/include"
  # export CXXFLAGS="-fPIC -I$PREFIX/include"
fi

# add -DIV_ENABLE_X11_DYNAMIC=ON to allow x dependencies to be optional?
# not sure there's a benefit to that, since x can just be a lightweight dependency

CMAKE_CONFIG="$CMAKE_CONFIG \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DNRN_ENABLE_SHARED=ON \
  -DNRN_ENABLE_INTERVIEWS=ON \
  -DIV_ENABLE_SHARED=ON \
  -DNRN_ENABLE_PYTHON=ON \
  -DNRN_ENABLE_PYTHON_DYNAMIC=ON \
  -DLINK_AGAINST_PYTHON=OFF \
  -DNRN_MODULE_INSTALL_OPTIONS= \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_CXX_COMPILER=$CXX \
"

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  CMAKE_CONFIG="-DNRN_ENABLE_MPI=ON $CMAKE_CONFIG"
else
  CMAKE_CONFIG="-DNRN_ENABLE_MPI=OFF $CMAKE_CONFIG"
fi

mkdir build
cd build
cmake $CMAKE_CONFIG ..
cmake --build . --parallel ${CPU_COUNT:-1} --target install

# relocate python install from lib/python to site-packages
mv -v $PREFIX/lib/python/neuron $SP_DIR/neuron
rm -rvf $PREFIX/lib/python

$PYTHON -c 'import neuron.hoc'
$PYTHON -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
$PYTHON -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
