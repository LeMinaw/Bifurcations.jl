"Linear two point interpolation"
function interp(x::Real,
        xmin::Real=0, xmax::Real=1,
        ymin::Real=0, ymax::Real=1)
    (x - xmin) * (ymax - ymin) / (xmax - xmin) + ymin
end

"Constant function"
function cst(k::Number)
    return f(args...) = k
end

"Identity function"
id(x::Any) = x
