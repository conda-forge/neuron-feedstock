set -ex

nrnivmodl
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
  ./x86_64/special --version
elif [ "${arch_name}" = "arm64" ]; then
  ./arm64/special --version
fi

conda env export -p $CONDA_PREFIX

python -c "import neuron; neuron.test()"
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"

# if not mpi, we are done here
if [ "${mpi}" == "nompi" ]; then
  exit 0
fi

if [ "${mpi}" == "mpich" ]; then
  export HYDRA_LAUNCHER=fork
  mpiexec="mpiexec"
elif [ "${mpi}" == "openmpi" ]; then
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_rmaps_base_oversubscribe=yes
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
  mpiexec="mpiexec --allow-run-as-root"
fi

$mpiexec -n 3 python test_mpi.py 2>&1 | cat
