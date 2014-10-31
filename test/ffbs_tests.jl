using Fst

a = read_wfst(readall("fsts/ffbs/a.txt"), Probability_semiring)
b = read_wfst(readall("fsts/ffbs/b.txt"), Probability_semiring)

println(forward_filtering(a))
println(forward_filtering(b))

for i in 1:10
    println(sampleone(["a","b","c"], [0.9, 0.05, 0.05]))
end

for i in 1:10
    println(backward_sampling(a, forward_filtering(a)))
end
