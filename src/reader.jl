function read_hdrgen_file(path::String)
# description: read hdrgen file and parse the lines as (image, shutter_time)
#              pair.
# input: path to hdrgen file
# return value: vector of the (image, shutter_time) pairs.
    hdrgen_file = open(path)
    hdrgen_lines = readlines(hdrgen_file)
    base_dir = dirname(path)

    #Enhancement: take general image types instead of only RGB{N0f8}
    hdr_pairs = HDRSequence()

    for line in hdrgen_lines
        image_name, exposure = split(line)
        image_path = joinpath(base_dir, image_name)
        println("reading image ", image_path)
        image = load(image_path)

        push!(hdr_pairs, (image, 1.0 / float(exposure)))
    end

    return hdr_pairs
end
