using PyPlot

function pseudo_color_visualizer(ir_image)
    pcolormesh(sum(ir_image, 1)[1, end:-1:1, 1:end])
    colorbar()
end
