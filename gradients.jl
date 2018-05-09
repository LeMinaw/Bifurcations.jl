"Simple start-end gradient structure."""
type Gradient{T<:Colorant}
    start::T
    stop::T
end

"Lineary interpolates between two colors of a `Gradient`, `x` between `xmin`
and `xmax`."
function grad(gradient::Gradient{T}, x::Real, xmin::Real=0, xmax::Real=1) where T
    mapc(
        (start, stop) -> clamp(interp(x, xmin, xmax, start, stop), 0, 1),
        gradient.start, gradient.stop
    )
end
