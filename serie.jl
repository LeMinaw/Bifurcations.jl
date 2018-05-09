__precompile__()

module Serie

using Makie, GLVisualize, GeometryTypes, Reactive
import GLVisualize: play_slider, mm

include("utils.jl")
include("populations.jl")

function app(pop::Population, iters::Int64=1000)
    scene = Scene()
    control_scene = Scene(scene, Signal(SimpleRectangle(0, 0, 1800, 50)))
    screen = control_scene[:screen]

    play_gui, play_s = play_slider(screen, 8mm, linspace(0, 4, 10^5), slider_length=1500)
    controls = Pair[
        "fertility" => play_gui,
    ]
    _view(visualize(controls), screen, camera=:fixed_pixel)

    ax = linspace(1, iters, iters) # HACK: As Makie loops endlessly when using regular ranges...
    ay = linspace(0, 10, 11) # HACK: As Makie does not support different scales on x and y axis...
    grid = axis(ax, ay)

    points = map(play_s) do var_fert
        pts = Point2f0[]
        p = pop.initial
        for n = 1:iters
            push!(pts, Point2f0(n, 10p))
            f = pop.fertilities[n % end + 1](var_fert)
            p = pop.law(f, p)
        end
        pts
    end

    # pos = lift_node(getindex.(scene, (:mouseposition, :time))...) do mpos, t
    #     map(linspace(0, 2pi, 60)) do i
    #         circle = Point2f0(sin(i), cos(i))
    #         mouse = to_world(Point2f0(mpos), cam)
    #         secondary = (sin((i * 10f0) + t) * 0.09) * normalize(circle)
    #         (secondary .+ circle) .+ mouse
    #     end
    # end

    lines(points)
    center!(scene)
    # _view(visualize(points, :lines), view_screen)
    # renderloop(window)
end

function __init__()
    pop = Population(logistic, [id, cst(3.8), cst(3.7)], .5)
    app(pop, 100)
end

end
