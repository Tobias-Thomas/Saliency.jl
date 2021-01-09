struct SaliencyModelFromDirectory
    location:: String
    file_extension::String
end

SaliencyModelFromDirectory(location::String) = SaliencyModelFromDirectory(location, ".npy")

struct SaliencyModelFromExperiment
    σ::Float64
end

const AVAIL_METRICS = [
    "NSS",
    "CC"
]

const FIX_BASED_METRICS = [
    "NSS"
]


function saliency_map(saliency_model::SaliencyModelFromDirectory, stimulus::ExperimentStimulus)
    image_name, _ = splitext(stimulus.stim_info.image_path)
    image_name = basename(image_name)

    saliency_map_path = joinpath(saliency_model.location, image_name*saliency_model.file_extension)
    if saliency_model.file_extension == ".npy"
        return npzread(saliency_map_path)
    else
        error("this file extension is currently not supoorted")
    end
end

function saliency_map(saliency_model::SaliencyModelFromExperiment, stimulus::ExperimentStimulus)
    sal_map = zeros(stimulus.stim_info.image_shape[1:2])
    for scanpath in stimulus.scanpaths
        sal_map[scanpath.fixations] .= 1
    end
    imfilter(sal_map, Kernel.gaussian(saliency_model.σ))
end

function nss(saliency_map, scanpaths::Vector{Scanpath})
    nss_values::Vector{Float64} = []
    for scanpath in scanpaths
        if length(scanpath) == 0 continue end
        append!(nss_values, saliency_map[scanpath.fixations])
    end
    nss_values
end

cc(saliency_map, reference_map) = cor(vec(saliency_map), vec(reference_map))

const METRIC_FUNCS = Dict(
    "NSS"=>nss,
    "CC"=>cc
)

"""
    calc_metrics(saliency_model, dataset, metrics)

Calculates all asked metrics for the given saliency model on the dataset.  
This function can be used with an arbitrary saliency model, it only has to implement the
`saliency_map` function
"""
function calc_metrics(saliency_model, dataset::Vector{ExperimentStimulus}, metrics::Vector{String})
    @assert metrics ⊆ AVAIL_METRICS "All metrics have to be in the list of available metrics"
    metric_values = [Vector{Float64}() for _ in eachindex(metrics)]
    gold_model = SaliencyModelFromExperiment(35)
    for (stim_num, stimulus) in enumerate(dataset)
        gold_map = z_standardize(saliency_map(gold_model, stimulus))
        predicted_map = z_standardize(saliency_map(saliency_model, stimulus))
        for (met_num, metric) in enumerate(metrics)
            if metric in FIX_BASED_METRICS
                append!(metric_values[met_num], METRIC_FUNCS[metric](predicted_map, stimulus.scanpaths))
            else
                push!(metric_values[met_num], METRIC_FUNCS[metric](predicted_map, gold_map))
            end
        end
    end
    metric_values
end

calc_metrics(saliency_model, dataset::Vector{ExperimentStimulus}, metrics::String) = calc_metrics(saliency_model, dataset, [metrics])