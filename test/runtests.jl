using Saliency
using Test
using Statistics

tests = [
    "util"
    "metrics"
]

@testset "Saliency" begin

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end

end