using Images, ImageView, Plots, ImageFiltering, FileIO

# Currently N0f16 and others are NOT supported
HDRSequence = Vector{Tuple{Matrix{RGB{N0f8}}, Float64}}

include("tonemapper.jl")
include("synthesizer.jl")
include("reader.jl")

include("test_synthesizer.jl")
