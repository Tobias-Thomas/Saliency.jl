using Saliency
using NPZ
using Images
using FileIO

struct SaliencyModelFromDirectory
    location:: String
    file_extension::String
end

struct SaliencyModelFromExperiment
    σ::Float64
end

const AVAIL_METRICS = [
    "NSS"
]

const FIX_BASED_METRICS = [
    "NSS"
]


function saliency_map(saliency_model::SaliencyModelFromDirectory, stim_info::StimulusInfo)
    image_name, _ = splitext(stim_info.image_path)
    image_name = basename(image_name)

    saliency_map_path = joinpath(saliency_model.location, image_name*saliency_model.file_extension)
    if saliency_model.file_extension == ".npy"
        return z_standardize!(npzread(saliency_map_path))
    else
        error("this file extension is currently not supoorted")
    end
end

function saliency_map(saliency_model::SaliencyModelFromExperiment, stimulus::ExperimentStimulus)

end

function nss(saliency_map, scanpaths::Vector{Scanpath})
    nss_values::Vector{Float64} = []
    for scanpath in scanpaths
        if length(scanpath) == 0 continue end
        idxs = CartesianIndex.(scanpath)
        append!(nss_values, saliency_map[idxs])
    end
    nss_values
end

const METRIC_FUNCS = Dict(
    "NSS"=>nss
)

"""
    metrics_per_img(saliency_model, dataset, metrics)

Calculates all asked metrics for the given saliency model on the dataset.  
This function can be used with an arbitrary saliency model, it only has to implement the
`saliency_map` function
"""
function metrics_per_img(saliency_model, dataset::Vector{ExperimentStimulus}, metrics::Vector{String})
    @assert metrics ⊆ AVAIL_METRICS "All metrics have to be in the list of available metrics"
    metric_values = [Vector{Float64}() for _ in eachindex(metrics)]
    for (stim_num, stimulus) in enumerate(dataset)
        predicted_map = saliency_map(saliency_model, stimulus.stim_info)
        for (met_num, metric) in enumerate(metrics)
            append!(metric_values[met_num], METRIC_FUNCS[metric](predicted_map, stimulus.scanpaths))
        end
    end
    metric_values
end

metrics_per_img(saliency_model, dataset::Vector{ExperimentStimulus}, metrics::String) = metrics_per_img(saliency_model, dataset, [metrics])