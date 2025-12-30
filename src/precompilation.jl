using PrecompileTools

@setup_workload begin
    # Minimal setup - avoid heavy dependencies
    @compile_workload begin
        # Precompile the most common operations with Vector{Float64}
        x = [1.0, 2.0, 3.0]

        # Test isscimlstructure
        isscimlstructure(x)

        # Test hasportion for all portion types
        hasportion(Tunable(), x)
        hasportion(Constants(), x)
        hasportion(Caches(), x)
        hasportion(Discrete(), x)

        # Precompile canonicalize and repack for Vector{Float64}
        vals, repack, aliases = canonicalize(Tunable(), x)
        repack([4.0, 5.0, 6.0])

        # Precompile replace
        replace(Tunable(), x, [7.0, 8.0, 9.0])

        # Precompile canonicalize for other portions (returns nothing)
        canonicalize(Constants(), x)
        canonicalize(Caches(), x)
        canonicalize(Discrete(), x)

        # Precompile with Matrix{Float64}
        mat = [1.0 2.0; 3.0 4.0]
        isscimlstructure(mat)
        hasportion(Tunable(), mat)
        vals_m, repack_m, aliases_m = canonicalize(Tunable(), mat)
        repack_m([5.0, 6.0, 7.0, 8.0])
        replace(Tunable(), mat, [5.0, 6.0, 7.0, 8.0])
    end
end
