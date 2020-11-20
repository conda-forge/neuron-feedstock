# # substitute missing files from yale release with those from the github archive
# #cp -fR yale/* github/
# #cd github
#
#
# # # cancel culling of unused libs
# # # it seems to cull libs that are actually used
# # export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs}"
# # export LDFLAGS="${LDFLAGS/-Wl,--as-needed}"
#
# # force shortnames of compilers since package contains references to these
# if [[ "$(uname)" == "Darwin" ]]; then
#   export CC=clang
#   export CXX=clang++
#   # LDSHARED needed for Python (mac only, apparently)
# #   export LDSHARED="${LD:-$CXX} -bundle -undefined dynamic_lookup $LDFLAGS"
# else
#   export CC=$(basename $CC)
#   export CXX=$(basename $CXX)
#   # clear C++ compiler flags, which have been identified
# #   # as the culprit
# #   export CPPFLAGS="-I$PREFIX/include"
# #   export CXXFLAGS="-fPIC -I$PREFIX/include"
# fi
#
#
# # force cython recompile by removing cython-generated sources
# find share/lib/python -name "*.cpp" -exec rm {} \;
#
# ENABLE_MPI="OFF"
# if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
#   ENABLE_MPI="ON"
# fi
#
#
# mkdir build
# cd build
# cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
#     -DCMAKE_C_COMPILER=$CC \
#     -DCMAKE_CXX_COMPILER=$CXX \
#     -DNRN_ENABLE_INTERVIEWS=ON \
#     -DNRN_ENABLE_MPI=$ENABLE_MPI \
#     -DNRN_ENABLE_THREADS=ON \
#     -DNRN_ENABLE_RX3D=ON \
#     -DNRN_ENABLE_PYTHON_DYNAMIC=ON \
#     ..
# make install
#
#
# # make install copies a bunch of intermediate files that shouldn't be installed
# # rm -f "${PREFIX}/lib/"*.la
# # rm -f "${PREFIX}/lib/"*.o
#
# # redo Python binding installation
# # since package installs in lib/python instead of proper site-packages
# cd src/nrnpython
# $PREFIX/bin/python setup.py install
# rm -rf $PREFIX/lib/python/neurons
# rm -f $PREFIX/lib/python/NEURON-*
# rmdir $PREFIX/lib/python || true
# # rm -rf $PREFIX/share/nrn/lib/python
#
# # leave build directory
# cd ../../..

# install using pip from the whl file provided by Google

if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "3.8" ]; then
        pip install https://files.pythonhosted.org/packages/3a/8a/ca66dc5cf5f49237ae2c854b4f5b179786a8e55c64aac4a757a2a13f3193/NEURON-7.8.1.1-cp38-cp38-macosx_10_9_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    else
        pip install NEURON --no-deps -vs
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "3.8" ]; then
        pip install https://files.pythonhosted.org/packages/ef/73/2bda5b486fda5a8e437331bba76b431fd58c9cea5ff80e73e64646b45523/NEURON-7.8.1.1-cp38-cp38-manylinux1_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    else
        pip install NEURON --no-deps -v
    fi
fi

# test imports
python -c 'import neuron.hoc'
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
