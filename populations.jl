__precompile__()

struct Population
    law::Function
    fertilities::Array{Function, 1}
    initial::Float64
end

logistic(f::Float64, p::Float64) = f * p * (1-p)
