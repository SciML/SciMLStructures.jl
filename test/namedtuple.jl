@testset "NamedTuple" begin
    test_p = (layer_1 = (weight = rand(Float32, 2, 2), bias = rand(Float32, 2, 1)), layer_2 = (weight = rand(Float32, 2, 2), bias = rand(Float32, 2, 1)))
    tunables, repack, aliases = canonicalize(Tunable(), test_p)
    @test test_p == repack(tunables)
    @test length(tunables) == 4 + 2 + 4 + 2
    @test tunables isa AbstractVector
end
