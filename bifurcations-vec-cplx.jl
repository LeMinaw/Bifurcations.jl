__precompile__()

module Bifurcations

    using Luxor, Colors, FixedPointNumbers

    include("utils.jl")
    include("populations.jl")
    include("gradients.jl")

    function plot(pop::Population,
            colmap::Gradient;
            iters::Int64=600,
            steps::Int64=1000,
            xmin::Float64=0.0, xmax::Float64=1.0,
            ymin::Float64=0.0, ymax::Float64=4.0)
        
        plot(pop, colmap, colmap;
            iters=iters,
            steps=steps,
            xmin=xmin, xmax=xmax,
            ymin=ymin, ymax=ymax)
    end

    function plot(pop::Population,
            colmap_r::Gradient,
            colmap_i::Gradient;
            iters::Int64=600,
            steps::Int64=1000,
            xmin::Float64=0.0, xmax::Float64=1.0,
            ymin::Float64=0.0, ymax::Float64=4.0)

        # We precompute colors for each iteration for performance
        colors_r::Array = [grad(colmap_r, n, 1, iters) for n = 1:iters]
        colors_i::Array = [grad(colmap_i, n, 1, iters) for n = 1:iters]

        coords_r = [Array{Point, 1}() for _ = 1:iters]
        coords_i = [Array{Point, 1}() for _ = 1:iters]

        for x = 1:steps
            p::ComplexF64 = pop.initial
            x::Float64 = interp(x, 1, steps, ymin, ymax)

            for n = 1:iters
                if abs2(p) > maximum(abs.((xmin, xmax, ymin, ymax)))^2
                    break
                end

                # n > card(f) to avoid initial horizontal lines on the plot
                if n > length(pop.fertilities)
                    y_r = 1 - real(p)
                    y_i = 1 - imag(p)
                    if ymin < y_r < ymax
                        push!(coords_r[n], Point(960x, 960y_r))
                    end
                    if ymin < y_i < ymax
                        push!(coords_i[n], Point(960x, 960y_i))
                    end
                end
                f = pop.fertilities[n % end + 1](x)
                p = pop.law(f, p)
            end
        end

        @svg begin
            setline(1)
            setlinecap("round")
            setlinejoin("round")
            for (coords, colors) = zip((coords_r, coords_i), (colors_r, colors_i))
                for (line_coords, color) = Iterators.reverse(zip(coords, colors))
                    setcolor(color)
                    try
                        # poly(line_coords, :stroke)
                        drawbezierpath(makebezierpath(simplify(line_coords, .5)), :stroke)
                        # drawbezierpath(makebezierpath(line_coords), :stroke)
                    catch e
                        if !isa(e, BoundsError)
                            throw(e)
                        end
                    end
                end
            end
        end
    end


    function __init__()
        pop = Population(logistic, [x -> x-.5im*x], .5)
        pop = Population(mandelbrot, [x -> x*im - 0.2], .5)
        pop = Population(logistic, [x->.5x+im], .5) # pour L.I

        black   = RGBA(0.0, 0.0, 0.0, 1.0)
        black_a = RGBA(1.0, 1.0, 1.0, 0.0)
        red     = RGBA(1.0, 0.0, 0.0, 1.0)
        red_a   = RGBA(1.0, 0.0, 0.0, 0.0)
        blue_a  = RGBA(0.0, 0.0, 1.0, 0.0)
        white   = RGBA(1.0, 1.0, 1.0, 1.0)

        black_to_red       = Gradient(black, red)
        black_to_red_fade  = Gradient(black, red_a)
        black_to_blue_fade = Gradient(black, blue_a)
        red_to_black       = Gradient(red,   black)
        red_to_white       = Gradient(red,   white)
        black              = Gradient(black, black)

        plot(pop, black_to_red_fade, black_to_blue_fade;
            # name = string(rand(0000:9999)),
            iters = 100,
            steps = 8000,
            xmin = -4.0, xmax = 4.0,
            ymin = -4.0, ymax = 4.0)
    end
end
