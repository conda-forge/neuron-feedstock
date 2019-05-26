set -ex

nrnivmodl
./x86_64/special --version

conda env export -p $CONDA_PREFIX

python -c "import neuron; neuron.test()"
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"

