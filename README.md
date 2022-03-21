# GrowClust3D
Julia implementation of the GrowClust program for relative relocation of earthquake hypocenters based on waveform cross-correlation data. This is a testing version before later public release as a registered package. The longterm vision is to provide more flexibility and 3D velocity model capabilities than the original Fortran90 source code.

 Apologies for the sparse readme; more to come. The test version of the package can be installed using the Julia Pkg manager:

` pkg> add https://github.com/dttrugman/GrowClust3D`

[Note, to download a local copy of this repository, try `git clone https://github.com/dttrugman/GrowClust3D`.]

The examples/ directory has four different julia scripts. Two of the scripts are simple examples of serial programming without bootstrapping for uncertainty quantification. One of these emulates the classic Fortran90 implementation with 1D layered velocity models, and can be used with either internal ray tracing or with pre-computed NonLinLoc travel time grids. These two example cases can be run using the commands:

`julia run_growclust_classic1D.jl example.trace1D.inp`

or

`julia run_growclust_classic1D.jl example.grid1D.inp`.

In addition, there are two parallelized examples with 100 bootstrap resamples: multithreaded and multiprocessing. To run these two examples:

`julia -t8 run_growclust_multithread.jl example.multithread.inp`

or

`julia -p8 run_growclust_multiprocess.jl example.multiprocess.inp`

or


In the multithreaded example, I specified the use of 8 threads, while the multiprocessing example uses 8 processors. Generally, if sufficient resources are available, multiprocessing will be faster than multithreading (especially for large datasets) due to memory considerations. For most use cases, the computational overhead in transfering data to the additional processors is negligible compared to additional compute power. Note that these two parallelized versions are written for 1D velocity models but it is straightforward to convert them to 3D travel time grids using the `run_growclust_nllgrid3D.jl` as a guide.
