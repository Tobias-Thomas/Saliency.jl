module Saliency
    export load_dataset, numfixations, numsubjects
    export ExperimentStimulus, Scanpath, StimulusInfo
    export saliency_map, metrics_per_img
    export SaliencyModelFromDirectory, SaliencyModelFromExperiment
    export z_standardize!

    include("dataset.jl")
    include("saliencymodel.jl")
    include("utils.jl")
end