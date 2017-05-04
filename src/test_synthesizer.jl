function test_synthesizer()
    sony_hdrpair = read_hdrgen_file("/Users/core/Development/Robotics/HDR.jl/dataset/Home/home.hdrgen");
    dseq = hdr_sequence_downsample(sony_hdrpair, 10)
    sony_hdr, sony_res = image_synthesis(dseq, 3, true)
    imshow(colorview(RGB, sony_hdr) / 300)
end
