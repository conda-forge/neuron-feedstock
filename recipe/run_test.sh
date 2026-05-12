set -ex

if [[ "$target_platform" = "osx-64" ]]; then
  arch="x86_64"
else
  arch="$(arch)"
fi

nrnivmodl

./$arch/special --version

conda env export -p $CONDA_PREFIX

python -c "import neuron; neuron.test()"
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"

# if not mpi, we are done here
if [ "${mpi}" == "nompi" ]; then
  exit 0
fi

$mpiexec -n 3 python test_mpi.py 2>&1 | cat
