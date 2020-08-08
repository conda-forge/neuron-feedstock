
if [ `uname` == Darwin ]; then
    if [ "$PY_VER" == "3.6" ]; then
        pip install https://files.pythonhosted.org/packages/37/28/01b62fa5af6fe38c55d7d216bfb688ff14f893178ec0ec97c2060d211613/NEURON-7.8.1.1-cp36-cp36m-macosx_10_9_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    elif [ "$PY_VER" == "3.7" ]; then
        pip install https://files.pythonhosted.org/packages/38/fc/7f93739773c262502cacc3a65f372f594ad86947eaa35c459ea1a62ffcd4/NEURON-7.8.1.1-cp37-cp37m-macosx_10_9_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    elif [ "$PY_VER" == "3.8" ]; then
        pip install https://files.pythonhosted.org/packages/3a/8a/ca66dc5cf5f49237ae2c854b4f5b179786a8e55c64aac4a757a2a13f3193/NEURON-7.8.1.1-cp38-cp38-macosx_10_9_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    else
        pip install NEURON --no-deps --ignore-installed --no-cache-dir -vvv
    fi
fi

if [ `uname` == Linux ]; then
    if [ "$PY_VER" == "3.6" ]; then
        pip install https://files.pythonhosted.org/packages/f5/b1/6522ae97751e4a3d53f7419122f10b859889fdff01119f839070840c56e3/NEURON-7.8.1.1-cp36-cp36m-manylinux1_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    elif [ "$PY_VER" == "3.7" ]; then
        pip install https://files.pythonhosted.org/packages/66/76/0de2b7d3778725b390fd9f11d9ef04a66aa50f36dfba01de36f1a6d1a1e9/NEURON-7.8.1.1-cp37-cp37m-manylinux1_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    elif [ "$PY_VER" == "3.8" ]; then
        pip install https://files.pythonhosted.org/packages/ef/73/2bda5b486fda5a8e437331bba76b431fd58c9cea5ff80e73e64646b45523/NEURON-7.8.1.1-cp38-cp38-manylinux1_x86_64.whl --no-deps --ignore-installed --no-cache-dir -vvv
    else
        pip install NEURON --no-deps --ignore-installed --no-cache-dir -vvv
    fi
fi

# test imports
python -c 'import neuron.hoc'
python -c "import neuron; assert neuron.h.load_file(neuron.h.neuronhome() + '/lib/hoc/stdlib.hoc')"
python -c "import neuron; assert neuron.h.load_file('stdlib.hoc')"
