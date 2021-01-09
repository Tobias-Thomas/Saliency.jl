@testset "Util" begin

    @testset "z standardization" begin
        a = rand(Float64, 10, 10)
        a = z_standardize(a)
        @test isapprox(mean(a), 0, atol=1e-9)
        @test isapprox(std(a), 1)
    end

end