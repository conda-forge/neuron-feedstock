aclocal -Im4
automake
autoconf
./configure \
    --without-x \
    --with-nrnpython=$PYTHON \
    --prefix=$PREFIX \
    --exec-prefix=$PREFIX

make -j ${NUM_CPUS:-1}
make install

# make install copies a bunch of intermediate files that shouldn't be installed
rm -f "${PREFIX}/lib/*.la"
rm -f "${PREFIX}/lib/*.o"

# redo Python binding installation
# since package installs in lib/python instead of proper site-packages
rm -rf $PREFIX/lib/python
cd src/nrnpython
python setup.py install
