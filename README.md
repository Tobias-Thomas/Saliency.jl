# Saliency.jl
A julia package for image saliency modeling. Functionality wise this package is oriented to the python package [pysaliency](https://github.com/matthias-k/pysaliency)  
Primary focus in terms of functionality will be loading datasets aswell as different type of saliency models and calculate metrics on them.  
## State of the project
The project is in quite early state, therefore you can currently **not** install it with Pkg.
## Current Functionality
The state of the current functionality in terms of available datasets and possible metrics to calculate can be accessed via the following constants.
```julia
Saliency.DATASETS  # lists the available datasets
Saliency.AVAIL_METRICS  # lists the available metrics
```
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
## Known differences to pysaliency
As already said in the beginning, most of the functionality is similar to [pysaliency](https://github.com/matthias-k/pysaliency), therefore most of the functions are tested against the pysaliency implementations on consistency.  
Following are some differences to the python version.  
### Fixations are correctly rounded
In the dataset fixations are given as floating points. Using them to index into the image, they have to be converted to Integers. Pysaliency just removes all decimal places, while this package actually rounds the numbers.
### Different implementations for convolutions with gaussian filters
To create Saliency Map from Fixations, all fixated positions are 1 in an otherwise 0 image and are then getting filtered with a gaussian kernel. The python implementation uses `gaussian_filter` from scipy.ndimage while I am using `imfilter` from ImageFiltering.jl. At the current stage I was not able to fully reproduce the python defaults, but it is on my todo list.