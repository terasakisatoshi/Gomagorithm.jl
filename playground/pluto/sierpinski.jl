using Random
using StaticArrays

begin
    struct Affine{Mat, Vec}
        W::Mat
        b::Vec
    end
    
    function (aff::Affine)(x1::Real, x2::Real)
        W = aff.W
        b = aff.b
        y1 = W[1,1] * x1 + W[1, 2] * x2 + b[1]
        y2 = W[2,1] * x1 + W[2, 2] * x2 + b[2]
        [y1, y2]
    end

    function (aff::Affine)(v::AbstractVector)
        aff.W * v + aff.b
    end
end

function gasket()
    W1 = @SMatrix Float64[0.5 0; 0 0.5]
    b1 = @SVector Float64[0., 0.]
    aff1 = Affine(W1, b1)

    W2 = @SMatrix Float64[0.5 0; 0 0.5]
    b2 = @SVector Float64[0.5, 0]
    aff2 = Affine(W2, b2)

    W3 = @SMatrix Float64[0.5 0; 0 0.5]
    b3 = @SVector Float64[0.5, 0.5]
    ms = [W1, W2, W3]
    bs = [b1, b2, b3]
    affines = map(ntuple(identity, 3)) do i
        Affine(ms[i], bs[i])
    end
    return affines
end

begin
    function generate_points(affines)
        npoints = 100_000
        xs = Float64[]
        ys = Float64[]
        v = @SVector rand(2)
        ntfms= length(affines)
        for i in 1:npoints
            aff = affines[rand(1:ntfms)]
            v = aff(v)
            push!(xs, v[1])
            push!(ys, v[2])
        end
        xs, ys
    end
    
    function generate_points!(xs, ys, affines)
        v = @SVector zeros(2)
        ntfms= length(affines)
        for i in eachindex(xs, ys)
            aff = rand(affines)
            v = aff(v)
            xs[i] = v[1]
            ys[i] = v[2]
        end
    end

    function generate_points!(xys, affines)
        v = @SVector zeros(2)
        ntfms= length(affines)
        for i in axes(xys, 2)
            aff = rand(affines)
            v = aff(v)
            xys[:, i] .= v
        end
    end
end
