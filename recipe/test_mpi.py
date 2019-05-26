from neuron import h

h.nrnmpi_init()
pc = h.ParallelContext()

nhost = int(pc.nhost())
assert nhost == 3, nhost
