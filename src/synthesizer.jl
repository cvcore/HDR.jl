function hdr_sequence_downsample{T<:Integer}(hdrseq::HDRSequence, downsample_ratio::T)
    kernel_size = (0.75 * 1, 0.75 * 1)
    gaussian = KernelFactors.gaussian(kernel_size)

    quick_downsample_subm = [hdrseq[i][1][1:downsample_ratio÷2:size(hdrseq[i][1], 1),
                                          1:downsample_ratio÷2:size(hdrseq[i][1], 2)] for i in 1:size(hdrseq, 1)]
    filtered_image = [imfilter(RGB{N0f8}, quick_downsample_subm[i], gaussian, NA()) for i in 1:size(hdrseq, 1)]
    downsampled_seq = [(filtered_image[i], hdrseq[i][2]) for i in 1:size(hdrseq, 1)]

    return downsampled_seq
end


function image_synthesis(hdr_pairs,
                         iterations = -1,
                         show_intermediate_results = false)
# description: generating a HDR image by combining multiple images of different
#              exposure time, while recovering camera's response curve by Gauss-
#              Seidel relaxation.
# input: image sequence as parsed by read_hdrgen_file
# output: one single HDR image and response function
    fw = (x) -> exp(-4 * (x - 0.5)^2 / (0.5^2)) # weighing function

    image_size = size(channelview(hdr_pairs[1][1]))
    color_depth = Integer(typemax(channelview(hdr_pairs[1][1])[1].i) + 1)
    color_channel = Integer(size(channelview(hdr_pairs[1][1]), 1))

    fi = Array(Float64, (color_depth, color_channel)) # response curve in R, G, B channel
    for i = 1:color_channel
        fi[:, i] = linspace(0.5, 1.5, color_depth)
    end

    last_ir = zeros(Float64, image_size)
    last_res = zeros(Float64, (color_depth, color_channel))

    iteration_count = 0

    while (iteration_count < iterations) || iterations == -1
        ir = zeros(Float64, image_size) #irradiance
        ir_normalizer = zeros(Float64, image_size)

        new_fi = zeros(Float64, (color_depth, color_channel))
        new_fi_normalizer = zeros(Int64, (color_depth, color_channel))

        for (image, exposure) in hdr_pairs
            image_ch = channelview(image)
            for j in 1:size(image_ch, 3), i in 1:size(image_ch, 2), k in 1:size(image_ch, 1)
                ch_i = image_ch[k, i, j] # channel intensity

                ir[k, i, j] += fw(ch_i) * exposure * fi[ch_i.i + 1]
                ir_normalizer[k, i, j] += fw(ch_i) * exposure^2
            end
        end

        ir .= ir ./ ir_normalizer
        #ir[isnan(ir)] = 0 # silent NaNs

        for (image, exposure) in hdr_pairs
            image_ch = channelview(image)
            for j in 1:size(image_ch, 3), i in 1:size(image_ch, 2), k in 1:size(image_ch, 1)
                ch_i = image_ch[k, i, j]

                new_fi_normalizer[ch_i.i + 1, k] += 1
                new_fi[ch_i.i + 1, k] += exposure * ir[k, i, j]
            end
        end

        # normalizing & constraining fi(mid intensity) = 1.0
        fi .= new_fi ./ new_fi_normalizer
        for ch in 1:color_channel
            fi[:, ch] = fi[:, ch] / fi[color_depth ÷ 2, ch]
        end

        if show_intermediate_results
            imgc, imsl = imshow(colorview(RGB, ir) / maximum(ir)) # show by simple linear mapping
            ImageView.annotate!(imgc, imsl,
                                ImageView.AnnotationText(40, 30, "i=$iteration_count", color = RGB(1, 0, 0),
                                fontsize = 15))
        end

        res_diff = fi - last_res
        res_diff_norm = [norm(res_diff[:, k]) for k in 1:size(res_diff, 2)]
        #println(norm(res_diff_norm)) #debug
        #println(last_res[1:10, 1])

        last_ir = copy(ir)
        last_res = copy(fi)

        iteration_count += 1
        if iterations == -1 && norm(res_diff_norm) < 2.0
            break
        end

   end #for iterations

   return (last_ir, last_res)
end
