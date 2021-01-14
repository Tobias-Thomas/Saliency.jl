using Documenter
using Saliency

makedocs(
    modules=[Saliency],
    format=Documenter.HTML(),
    sitename="Saliency.jl",
    pages=[
        "Home" => "index.md"
        "Datasets" => "datasets.md"
    ]
)