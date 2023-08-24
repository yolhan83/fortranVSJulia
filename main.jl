using Plots,LinearAlgebra,BenchmarkTools,CUDA
function mandle_k(c::T)  where T<:Complex
    max_iter = 200
    z = c
    for i in 1:max_iter
        z = z^2 + c
        if abs2(z) > 4.0
            return i/max_iter
        end
    end
    return 1.0
end
@inline f(x::T,y::T)  where T<:Real =mandle_k(Complex{T}(x,y))

function compute_mandle_jl(x,y)
    result = Matrix{eltype(x)}(undef,length(x),length(y))
    @inbounds for j in axes(result,2)
        for i in axes(result,1)
            result[i,j] = f(x[i],y[j])
        end
    end
    result
end

xmin = -2.25
xmax = 0.75
xn = 450
ymin = -1.25
ymax = 1.25
yn = 375


dx = (xmax - xmin) / (xn-1)
dy = (ymax - ymin) / (yn-1)
x = xmin:dx:xmax 
y = ymin:dy:ymax 


@benchmark compute_mandle_jl($x,$y)


@time result =  compute_mandle_jl(x,y);
result = result |> collect
heatmap(result',colormap=:turbo)


# to see the fortran file 

using CSV,DataFrames

df = CSV.read("./gette/result.csv",DataFrame)

size(df,2)
M = Matrix{Float64}(undef,size(df,1),size(df,2))
for j in axes(M,2)
    M[:,j] = df[:,j]
end
using Plots
heatmap(M')




# If you wonder how it is on gpu


function compute_mandle(x,y)
    f.(x,transpose(y))
end

xg = xmin:dx:xmax |> collect |> cu
yg = ymin:dy:ymax |> collect |> cu

@benchmark compute_mandle($xg,$yg)


# less good on cpu
@benchmark compute_mandle($x,$y)












