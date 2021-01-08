# Saliency.jl
A julia package for image saliency modeling. Functionality wise this package is oriented to the python package [pysaliency](https://github.com/matthias-k/pysaliency)  
Primary focus in terms of functionality will be loading datasets aswell as different type of saliency models and calculate metrics on them.  
## State of the project
The project is in quite early state, therefore you can currently **not** install it with Pkg.
## Quickstart
```julia
using Saliency

# load the data set
dataset_name = "MIT1003"
dataset_location = "path/to/datasets/"
dataset = load_dataset(dataset_name, dataset_location)

# load a precomputed saliency model
prediction_location = "path/to/saliency_maps/"
model = SaliencyModelFromDirectory(prediction_location)

# calculate metrics
metrics = calc_metrics(model, dataset, ["NSS", "CC"])
```