set -ex
# check-in with neuron CI when updating
# https://github.com/neuronsimulator/nrn/blob/HEAD/.github/workflows/neuron-ci.yml

# cancel culling of unused libs
# it seems to cull libs that are actually used
export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"

if [[ "$target_platform" == osx-* ]]; then
  CMAKE_ARGS="$CMAKE_ARGS -DCURSES_NEED_NCURSES=ON"
else
  # force shortnames of compilers since package contains references to these
  export CC=$(basename $CC)
  export CXX=$(basename $CXX)
fi

# add -DIV_ENABLE_X11_DYNAMIC=ON to allow x dependencies to be optional?
# not sure there's a benefit to that, since x can just be a lightweight dependency

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  export OPAL_PREFIX=$PREFIX
  CMAKE_ARGS="-DNRN_ENABLE_MPI=ON $CMAKE_ARGS"
  export CC=mpicc
  export CXX=mpicxx
else
  CMAKE_ARGS="-DNRN_ENABLE_MPI=OFF $CMAKE_ARGS"
fi

mkdir build
cd build

cmake $CMAKE_ARGS \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DNRN_ENABLE_SHARED=ON \
  -DNRN_ENABLE_INTERVIEWS=ON \
  -DIV_ENABLE_SHARED=ON \
  -DNRN_ENABLE_PYTHON=ON \
  -DNRN_ENABLE_PYTHON_DYNAMIC=ON \
  -DPYTHON_EXECUTABLE=$PREFIX/bin/python \
  -DLINK_AGAINST_PYTHON=OFF \
  -DNRN_MODULE_INSTALL_OPTIONS= \
  ..

make install -j${CPU_COUNT:-1} VERBOSE=1

# remove some built files that shouldn't be installed
if [[ "${target_platform}" == *-64 ]]; then
  rm -rvf $PREFIX/share/nrn/demo/release/x86_64
elif [[ "${target_platform}" = *-aarch64 || "${target_platform}" = *-arm64 ]]; then
  rm -rvf $PREFIX/share/nrn/demo/release/arm64
fi

# remove some duplicate files installed in the wrong path
rm -rvf $PREFIX/lib/python

python -c 'import neuron.hoc'
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
