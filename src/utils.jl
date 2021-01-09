using Statistics

z_standardize(arr) = (arr .- mean(arr)) ./ std(arr)