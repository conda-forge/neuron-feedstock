set -ex
# check-in with neuron CI when updating
# https://github.com/neuronsimulator/nrn/blob/HEAD/.github/workflows/neuron-ci.yml

# cancel culling of unused libs
# it seems to cull libs that are actually used
export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"

# force shortnames of compilers since package contains references to these
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")

CMAKE_ARGS="${CMAKE_ARGS:-}"

if  [[ "$target_platform" == osx-* ]]; then
  CMAKE_ARGS="$CMAKE_ARGS \
    -DCURSES_NEED_NCURSES=ON \
    -DHAVE_SYS_SELECT_H=1 \
    "
fi


if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  CMAKE_ARGS="-DNRN_ENABLE_MPI=ON $CMAKE_ARGS"
  export CC=mpicc
  export CXX=mpicxx
else
  CMAKE_ARGS="-DNRN_ENABLE_MPI=OFF $CMAKE_ARGS"
fi

# add -DIV_ENABLE_X11_DYNAMIC=ON to allow x dependencies to be optional?
# not sure there's a benefit to that, since x can just be a lightweight dependency

CMAKE_ARGS="$CMAKE_ARGS \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DPYTHON_EXECUTABLE=$PYTHON \
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

mkdir build
cd build
cmake $CMAKE_ARGS \
  ..
cmake --build . \
  --parallel ${CPU_COUNT:-1} \
  --verbose \
  --target install

# relocate python install from lib/python to site-packages
mv -v $PREFIX/lib/python/neuron $SP_DIR/neuron
rm -rvf $PREFIX/lib/python

if [ "$CONDA_BUILD_CROSS_COMPILATION" != '1' ]; then
  $PYTHON -c 'import neuron.hoc'
  $PYTHON -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
  $PYTHON -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
fi
