set -ex

nrnivmodl
./x86_64/special --version

conda env export -p $CONDA_PREFIX

python -c "import neuron; neuron.test()"
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"



# test with OpenMPI
export OMPI_MCA_plm=isolated
export OMPI_MCA_rmaps_base_oversubscribe=yes
export OMPI_MCA_btl_vader_single_copy_mechanism=none
mpiexec="mpiexec --allow-run-as-root"

$mpiexec -n 3 python test_mpi.py 2>&1 | cat
