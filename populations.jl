__precompile__()

struct Population
    law::Function
    fertilities::Array{Function, 1}
    initial::Float64
end

logistic(f::Number, p::Number) = f * p * (1-p)

mandelbrot(f::Number, p::Number) = f + p^2
