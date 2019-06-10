__precompile__()

module Bifurcations

    using FileIO, Images, Formatting

    include("utils.jl")
    include("populations.jl")
    include("gradients.jl")

    function plot(pop::Population,
            colmap::Gradient;
            background::Colorant=RGB(1,1,1),
            name::String="test",
            iters::Int64=600,
            osa::Bool=true,
            sx::Int64=1080, sy::Int64=1920,
            xmin::Float64=0.0, xmax::Float64=1.0,
            ymin::Float64=0.0, ymax::Float64=4.0)
        # Image size
        if osa
            sx, sy = 2sx, 2sy
        end
        sx, sy = sx-1, sy-1

        # Preallocates image array
        img::Array = fill(background, sx, sy)

        # We precompute colors for each iteration for performance
        colors::Array = [grad(colmap, n, 1, iters/2) for n = 1:iters]

        # Pixels populate
        for pix_y = 1:sy
            p::Float64 = pop.initial
            y::Float64 = interp(pix_y, 1, sy, ymin, ymax)

            old_values = Set{Float64}()
            for n = 1:iters
                # Detects cyclical behaviour
                approx_p::Float64 = round(p, digits=10)
                if in(approx_p, old_values)
                    break
                end
                push!(old_values, approx_p)

                # n > card(f) to avoid initial horizontal lines on the plot
                if xmin < p < xmax && n > length(pop.fertilities)
                    pix_x = trunc(Int64, interp(p, xmin, xmax, sx, 1))
                    img[pix_x, pix_y] = colors[n]
                end
                f = pop.fertilities[n % end + 1](y)
                p = pop.law(f, p)
            end
        end
        if osa
            img = restrict(img)
        end
        save("$name.png", img)
    end


    # Obsolete exemple for plotting animated zooms

    #= function __init__()
        function compute(y1::Real, y2::Real, x1::Real, x2::Real, i::Int)
            println("=== STARTING COMPUTATION ===")
            colormap = Gradient(RGB(1,0,0), RGB(0,0,0))
            pop = Population(logistic, [id, cst(3.8)], .5)
            plot(pop, colormap, name=format("u/{:.5f}-{:.5f}__{:.5f}-{:.5f}", y1, y2, x1, x2), iters=trunc(i), ymin=y1, ymax=y2, xmin=x1, xmax=x2)
            println("Done.")
        end

        # function compute(x::Real)
        #     red2black = Gradient(RGB(1,0,0), RGB(0,0,0))
        #     pop = Population(logistic, [id, cst(x)], .5)
        #     plot(pop, red2black, format("i/{:.5f}", x))
        # end

        function expspace(start::Real, stop::Real, steps::Int)
            logStart = log(start)
            logStop  = log(stop)
            space = linspace(logStart, logStop, steps)
            exp.(space)
        end

        function zoom(lowInit, upInit, fact, frames)
            lows, ups = [], []
            low,  up  = lowInit, upInit
            for n = 1:frames
                push!(lows, low)
                push!(ups,  up)
                range = up - low
                low += range * fact
                up  -= range * fact
            end
            lows, ups
        end

        const FRAMES = 2000
        const Y_LIMITS = zoom(0.99680, 4.00000, 0.025, FRAMES)
        const X_LIMITS = zoom(0.00000, 0.82896, 0.02, FRAMES)

        # crops a window [lower, upper] to make <center> its midpoint
        function limits(lower, center, upper)
            range = upper -lower
            if center < range/2
                return lower, 2 * center
            elseif center > range/2
                return 2 * center - range, upper
            else
                lower, upper
            end

        # pmap(compute, Y_LIMITS[1], Y_LIMITS[2], fill(0.4, FRAMES), fill(0.6, FRAMES), Int64.(trunc.(linspace(600, 6000, FRAMES))))
        pmap(compute, Y_LIMITS[1], Y_LIMITS[2], X_LIMITS[1], X_LIMITS[2], Int64.(trunc.(linspace(600, 100000, FRAMES))))
    end =#

    function __init__()
        # pop = Population(logistic, [id, cst(3.9), cst(3.9), cst(3.9)], .5) # pas mal
        # pop = Population(logistic, [id, id, id, cst(3.75), id, cst(3.75), cst(3.75)], .5) # trop stylé
        # pop = Population(logistic, [id, cst(3.85), cst(3.75)], .5) #vraiment cool
        pop = Population(logistic, [id, cst(3.8), cst(3.7)], .5)

        black = RGB(0,0,0)
        red   = RGB(1,0,0)
        white = RGB(1,1,1)
        alpha = RGBA(1,1,1,0)

        black2red = Gradient(black, red)
        red2white = Gradient(red,   white)
        black     = Gradient(black, black)


        # Precomp func for benchmarks

        # plot(pop, colormap; name="precomp", sx=128, sy=128)


        # Usual demo func

        #= plot(pop, black_to_red;
            name = string(rand(0000:9999)),
            iters = 3000,
            osa = true,
            sx = 1080*2, sy = 1920*6,
            xmin = 0.0, xmax = 1.0,
            ymin = 0.0, ymax = 4.0
        ) =#


        # Batch multiple views
        
        n = 24
        for i = n:n
            println("Computing frame $i/$n...")

            plot(pop, black2red;
                name = format("{:02d}", i),
                iters = 1000,
                osa = true,
                # sx = 297, sy = 420,
                sx = 2970, sy = 4200,
                xmin = 0.0, xmax = 1.0,
                ymin = 4(i-1)/n, ymax = 4i/n
            )
        end
    end
end
