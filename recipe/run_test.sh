set -ex

nrnivmodl
./x86_64/special --version

python -c "import neuron; neuron.test()"
python -c "import neuron; neuron.h.load_file('stdlib.hoc')"

conda env export -p $CONDA_PREFIX

python -c "import neuron; neuron.h.load_file(neuron.h.neuronhome() + '/stdlib.hoc')"

