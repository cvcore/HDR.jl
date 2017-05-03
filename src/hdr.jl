using Images, ImageView

function read_hdrgen_file(path::String)
# description: read hdrgen file and parse the lines as (image, shutter_time)
# pair.
# return value: vector of the (image, shutter_time) pairs.
    hdrgen_file = open(path)
    hdrgen_lines = readlines(hdrgen_file)
    base_dir = dirname(path)

    hdr_pair = Vector{Tuple{Matrix{RGB{N0f8}}, Float64}}()

    for hdrgen_line in hdrgen_lines
        image_name, shutter = split(hdrgen_line)
        image_path = joinpath(base_dir, image_name)
        println("reading image ", image_path)
        image = load(image_path)

        push!(hdr_pair, (image, float(shutter)))
    end

    return (images, shutter_time)
end

function image_synthesis(images::Matrix, shutter_time::Number)
    return (hdr_image, response_function)
end

function plot_response_function(response_function)
end
