### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 1142a7e1-6d83-4746-a602-c812512f2bc5
begin
	using Test
	using StableRNGs
end

# ╔═╡ 6c0552e8-cb9c-11ee-3e7f-3be38a736c2f
md"""
# 古典的グラムシュミットの直行化法
"""

# ╔═╡ a5978b5d-e211-4f5d-9c55-6eb4e7af3fc5
begin
	function innerproduct(a::AbstractVector, b::AbstractVector)
		s = zero(eltype(a))
		@inbounds for i in eachindex(a,b)
			s += a[i] * b[i]
		end
		s
	end
	const ⋅ = innerproduct
	norm(a::AbstractVector) = √(a ⋅ a)
end

# ╔═╡ 539319ce-ca4d-4de7-8469-e896b589c690
begin
	@testset "innerproduct" begin
		rng = StableRNG(999)
		x = rand(rng, 2)
		y = rand(rng, 2)

		@test innerproduct(x, y) == innerproduct(y, x)
		@test x ⋅ y == y ⋅ x

		@test innerproduct([1, 0], [0, 1]) == 0
		@test innerproduct([0, 1], [1, 0]) == 0
		@test innerproduct([1,1], [1,1]) ≈ norm([1,1]) ^ 2 ≈ 2.0
	end
	
	@testset "norm" begin
		@test norm([0., 0.]) == 0
		@test norm([1., 1.]) == √2
		@test norm([1., 2.]) == √5
		@test norm([2., 1.]) == √5
	end
	nothing
end

# ╔═╡ 3ff41189-0b8f-459d-87af-2d927cba6d4c
struct ClassicalGramSchmidt end # Algorithm

# ╔═╡ 24a69ae7-2574-4e35-bb4b-9ccb72b42521
function orthonormalize(::Type{ClassicalGramSchmidt}, veca⃗::AbstractVector{V}) where {V}
	a⃗₁ = veca⃗[1]
	r₁₁ = norm(a⃗₁)
	vecq⃗ = V[]
	q⃗₁ = a⃗₁/r₁₁
	push!(vecq⃗, q⃗₁)
	for n in 1:(length(veca⃗)-1)
		a⃗ₙ₊₁ = veca⃗[n+1]
		q⃗̃ₙ₊₁ = zero(a⃗ₙ₊₁)
		for i in 1:n
			q⃗ᵢ = vecq⃗[i]
			rᵢ₍ₙ₊₁₎ = q⃗ᵢ ⋅ a⃗ₙ₊₁
			q⃗̃ₙ₊₁ -= rᵢ₍ₙ₊₁₎ * q⃗ᵢ
		end
		q⃗̃ₙ₊₁ += a⃗ₙ₊₁
		r₍ₙ₊₁₎₍ₙ₊₁₎ = norm(q⃗̃ₙ₊₁)
		q⃗ₙ₊₁ = q⃗̃ₙ₊₁ / r₍ₙ₊₁₎₍ₙ₊₁₎
		push!(vecq⃗, q⃗ₙ₊₁)
	end
	vecq⃗
end

# ╔═╡ dc268e9b-b2ca-4143-abe9-5beb87f4f723
@testset "ClassicalGramSchmidt" begin
	rng = StableRNG(123)
	
	a⃗₁ = rand(rng, 3)
	a⃗₂ = rand(rng, 3)
	a⃗₃ = rand(rng, 3)
	veca⃗ = [a⃗₁, a⃗₂, a⃗₃]
	
	U = orthonormalize(ClassicalGramSchmidt, veca⃗)
	
	@test innerproduct(U[1], U[1]) ≈ 1.0
	@test innerproduct(U[2], U[2]) ≈ 1.0
	@test innerproduct(U[3], U[3]) ≈ 1.0

	@test abs(innerproduct(U[1], U[2])) ≈ 0.0 atol=1e-14
	@test abs(innerproduct(U[2], U[3])) ≈ 0.0 atol=1e-14
	@test abs(innerproduct(U[1], U[3])) ≈ 0.0 atol=1e-14

	@test_broken abs(innerproduct(U[1], U[2])) ≈ 0.0 atol=1e-16
	@test_broken abs(innerproduct(U[2], U[3])) ≈ 0.0 atol=1e-16
	@test abs(innerproduct(U[1], U[3])) ≈ 0.0 atol=1e-16
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
StableRNGs = "860ef19b-820b-49d6-a774-d7a799459cd3"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
StableRNGs = "~1.0.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.1"
manifest_format = "2.0"
project_hash = "a4590486d7604ab3578478648d997eb50013d5ca"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "ddc1a7b85e760b5285b50b882fa91e40c603be47"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ Cell order:
# ╟─6c0552e8-cb9c-11ee-3e7f-3be38a736c2f
# ╠═1142a7e1-6d83-4746-a602-c812512f2bc5
# ╠═a5978b5d-e211-4f5d-9c55-6eb4e7af3fc5
# ╠═539319ce-ca4d-4de7-8469-e896b589c690
# ╠═3ff41189-0b8f-459d-87af-2d927cba6d4c
# ╠═24a69ae7-2574-4e35-bb4b-9ccb72b42521
# ╠═dc268e9b-b2ca-4143-abe9-5beb87f4f723
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
