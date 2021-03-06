"""
    StimulusInfo(image_path::String, image_shape::Tuple(Int, Int, Int))

The basic information of a stimulus, containing the path to the image
file (`image_path`) and the shape of the image (`image_shape`)
"""
struct StimulusInfo
    image_path::String
    image_shape::Tuple{Int, Int, Int}
end

"""
    Scanpath(fixations::Vector{CartesianIndex{2}}, subject_id::Int)

The basic structure for storing scanpaths. It consists of a Vector of fixations
(`fixations`) stored as CartesianIndex{2} and a subject identifier (`subject_id`)
"""
struct Scanpath
    fixations::Vector{CartesianIndex{2}}
    subject_id::Int
end

Base.length(scanpath::Scanpath) = length(scanpath.fixations)
Base.iterate(scanpath::Scanpath, s...) = iterate(scanpath.fixations, s...)

"""
    ExperimentStimulus(stim_info::StimulusInfo, scanpaths::Vector{Scanpath})

Structure for storing information gathered in a saliency experiment about a single
stimulus. The struct has two fields. First a stimulus info (`stim_info`) and second
a Vector of Scanpaths (`scanpaths`), one for every suject in the experiment.
"""
struct ExperimentStimulus
    stim_info::StimulusInfo
    scanpaths::Vector{Scanpath}
end

"""
    numsubjects(exp_stim::ExperimentStimulusthe given

returns the number of subjects (number of available scanpaths) of the given stimulus
"""
numsubjects(exp_stim::ExperimentStimulus) = length(exp_stim.scanpaths)

"""
    numfixations(exp_stim::ExperimentStimulus)

returns the total number of fixations made in the given stimulus
"""
numfixations(exp_stim::ExperimentStimulus) = sum(length.(exp_stim.scanpaths))

const DATASETS = [
    "MIT1003",
    "OSIE",
    "toronto"
]

"""
    load_dataset(dataset_name::String, location::AbstractString)

Loads the given dataset from the given location. This assumes a folder with name
`dataset_name` to be at `location`. If this is not the case the dataset will be downloaded
from the web and saved at `location`.
Returns a Vector of `ExperimentStimulus`.
"""
function load_dataset(dataset_name::String, location::AbstractString)
    @assert dataset_name in DATASETS "dataset_name has to be a valid dataset"
    if !(isdir(joinpath(location, dataset_name)))
        print("Downloading data set")
        return 
    end
    # first load stimulus infos from stimulus.hdf5
    stim_infos::Vector{StimulusInfo} = []
    h5open(joinpath(location, dataset_name, "stimuli.hdf5")) do stim_hdf5
        stim_paths = read(stim_hdf5, "filenames")
        stim_paths = map(p -> joinpath(location, dataset_name, p), stim_paths)
        stim_shapes = read(stim_hdf5, "shapes")
        stim_infos = [StimulusInfo(p, tuple(s...)) for (p, s) in zip(stim_paths, stim_shapes)]
    end
    # Then load all the scanpath informations from fixations.hdf5
    exp_stimuli::Vector{ExperimentStimulus} = []
    h5open(joinpath(location, dataset_name, "fixations.hdf5")) do fix_hdf5
        scan_stim_num = read(fix_hdf5, "train_ns")
        scan_subject = read(fix_hdf5, "train_subjects")
        scan_xs = read(fix_hdf5, "train_xs")
        scan_ys = read(fix_hdf5, "train_ys")

        # create the `ExperimentStimulus` for every stimulus in the data set
        sizehint!(exp_stimuli, length(stim_infos))
        for (stim_num, stim_info) in enumerate(stim_infos)
            # create all scanpaths for this stimuli
            scanpaths_for_stim = Vector{Scanpath}()
            for scanpath_id in findall(==(stim_num-1), scan_stim_num)
                subject_id = scan_subject[scanpath_id]
                scanpath_x = scan_xs[:, scanpath_id]
                scanpath_y = scan_ys[:, scanpath_id]
                scanpath_length = findfirst(isnan, scanpath_x)
                if scanpath_length === nothing
                    scanpath_length = length(scanpath_x) + 1
                end
                push!(scanpaths_for_stim, Scanpath([CartesianIndex(1+round(Int, y), 1+round(Int, x)) for (x,y)
                    in zip(scanpath_x[1:scanpath_length-1], scanpath_y[1:scanpath_length-1])], subject_id))
            end
            push!(exp_stimuli, ExperimentStimulus(stim_info, scanpaths_for_stim))
        end
    end
    exp_stimuli
end
