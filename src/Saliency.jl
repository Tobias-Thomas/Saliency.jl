module Saliency
    using NPZ
    using Images, FileIO
    using ImageFiltering
    using Statistics
    using HDF5

    export load_dataset, numfixations, numsubjects
    export ExperimentStimulus, Scanpath, StimulusInfo
    export saliency_map, calc_metrics
    export SaliencyModelFromDirectory, SaliencyModelFromExperiment
    export z_standardize

    include("dataset.jl")
    include("saliencymodel.jl")
    include("utils.jl")
end