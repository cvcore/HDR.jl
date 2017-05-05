using Images, ImageView, Plots, ImageFiltering, FileIO

HDRSequence = Vector{Tuple{Matrix{RGB{N0f8}}, Float64}}

include("tonemapper.jl")
include("synthesizer.jl")
include("reader.jl")

include("test_synthesizer.jl")
