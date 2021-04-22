set -ex
# check-in with neuron CI when updating
# https://github.com/neuronsimulator/nrn/blob/HEAD/.github/workflows/neuron-ci.yml

# cancel culling of unused libs
# it seems to cull libs that are actually used
export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"

# force shortnames of compilers since package contains references to these

CMAKE_CONFIG=${CMAKE_ARGS}

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
"

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  CMAKE_CONFIG="-DNRN_ENABLE_MPI=ON $CMAKE_CONFIG"
else
  CMAKE_CONFIG="-DNRN_ENABLE_MPI=OFF $CMAKE_CONFIG"
fi

mkdir build
cd build
cmake $CMAKE_CONFIG ..
cmake --build . -- -j ${CPU_COUNT:-1}

make -j ${CPU_COUNT:-1}
make install

# remove some built files that shouldn't be installed
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
  rm -rvf $PREFIX/share/nrn/demo/release/x86_64
elif [ "${arch_name}" = "arm64" ]; then
  rm -rvf $PREFIX/share/nrn/demo/release/arm64
fi

# remove some duplicate files installed in the wrong path
rm -rvf $PREFIX/lib/python

python -c 'import neuron.hoc'
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
