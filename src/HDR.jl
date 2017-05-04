using Images, ImageView, Plots, ImageFiltering, FileIO

HDRSequence = Vector{Tuple{Matrix{Any}, Float64}}

include("tonemapper.jl")
include("synthesizer.jl")
include("reader.jl")

include("test_synthesizer.jl")
