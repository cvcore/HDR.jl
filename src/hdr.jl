using Images, ImageView

HDRSequence = Vector{Tuple{Matrix{RGB{N0f8}}, Float64}}

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

        push!(hdr_pairs, (image, float(exposure)))
    end

    return hdr_pairs
end

function image_synthesis(hdr_pairs::HDRSequence, iterations::Number)
# description: generating a HDR image by combining multiple images of different
#              exposure time, while recovering camera's response curve by Gauss-
#              Seidel relaxation.
# input: image sequence as parsed by read_hdrgen_file
# output: one single HDR image and response function
    fw = (x) -> exp(-4 * (x - 0.5)^2 / (0.5^2)) # weighing function

    fi = Array(Float64, (256, 3)) # response curve in R, G, B channel
    fi[:, 1] = linspace(0.5, 1.5, 256)
    fi[:, 2] = linspace(0.5, 1.5, 256)
    fi[:, 3] = linspace(0.5, 1.5, 256)

    image_size = size(channelview(hdr_pairs[1][1]))
    hdr_image = Matrix()
    hdr_response = Matrix()

    for iteration_count in 1:iterations
        ir = zeros(Float64, image_size) #irradiance
        ir_normalizer = zeros(Float64, image_size)

        new_fi = zeros(Float64, (256, 3))
        new_fi_normalizer = zeros(Int64, (256, 3))

        for (image, exposure) in hdr_pairs
            image_ch = channelview(image)
            for j in 1:size(image_ch, 3), i in 1:size(image_ch, 2), k in size(image_ch, 1)
                ch_i = image_ch[k, i, j] # channel intensity

                ir[k, i, j] += fw(ch_i) * exposure * fi[ch_i.i + 1]
                ir_normalizer[k, i, j] += fw(ch_i) * exposure^2
            end
        end

        ir .= ir ./ ir_normalizer
        ir[isnan(ir)] = 0 # silent NaNs

        for (image, exposure) in hdr_pairs
            image_ch = channelview(image)
            for j in 1:size(image_ch, 3), i in 1:size(image_ch, 2), k in size(image_ch, 1)
                ch_i = image_ch[k, i, j]

                new_fi_normalizer[ch_i.i + 1, k] += 1
                new_fi[ch_i.i + 1, k] += exposure * ir[k, i, j]
            end
        end

        fi .= new_fi ./ new_fi_normalizer
        fi[:, 1] = fi[:, 1] / fi[129, 1]
        fi[:, 2] = fi[:, 2] / fi[129, 2]
        fi[:, 3] = fi[:, 3] / fi[129, 3]

        imshow(ir[3, :, :])
        #return fi

        hdr_image = ir
        hdr_response = fi

   end #for iterations
#
    #return (ir, fi) # irradiance, response func
    return hdr_image, hdr_response
end

function plot_response_function(response_function)
end
