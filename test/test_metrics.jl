@testset "Metrics" begin
    scanpaths1 = [Scanpath([CartesianIndex(1,1), CartesianIndex(2,2)], 0),
        Scanpath([CartesianIndex(3,1), CartesianIndex(2,1)], 1)]
    scanpaths2 = [Scanpath([CartesianIndex(1,2), CartesianIndex(2,3)], 0),
        Scanpath([CartesianIndex(3,2), CartesianIndex(3,3)], 1)]
    # this saliency maps is not z standardized but that does not matter for the tests
    sal_map1 = [1 0 -1; 2 1 -3; -3 -1 4]
    sal_map2 = [2 -4 2; 0 3 -3; -2 1 1]

    @testset "NSS" begin
        @test all(Saliency.nss(sal_map1, scanpaths1) .== [1, 1, -3, 2])
        @test all(Saliency.nss(sal_map1, scanpaths2) .== [0, -3, -1, 4])
        @test all(Saliency.nss(sal_map2, scanpaths1) .== [2, 3, -2, 0])
        @test all(Saliency.nss(sal_map2, scanpaths2) .== [-4, -3, 1, 1])
    end

    @testset "CC" begin
        @test Saliency.cc(sal_map1, sal_map2) == Saliency.cc(sal_map2, sal_map1)
        @test Saliency.cc(sal_map1, sal_map1) == 1
        @test Saliency.cc(sal_map1, sal_map2) ≈ 0.4677071733467427
    end

end
