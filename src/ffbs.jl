export forward_filtering, sample

function forward_filtering(wfst::Wfst)
    f = Dict{Any, Float64}()
    # Will throw an error if an ordering can't be found
    ordering = topological_sort(wfst)
    for s in ordering
        if s in wfst.initial_states
            f[s] = wfst.initial_weights[s]
        else
            total = 0
            for arc in wfst.arcs
                if arc.to == s
                    total += arc.weight * f[arc.from]
                end
            end
            f[s] = total
        end
    end
    return f
end

#function backward_sampling(wfst::Wfst, f)
#    path = Arc[]
#    # Choose the final state first based on final_weights
#    
#    # This code should behave differently depending on the semiring used.
#end

function sample(items::Array, probs::Array{Float64})
    @assert length(items) == length(probs)
    # We're not asserting that probabilities sum to one since they might not in
    # the WFSTs.

    z = sum(probs)
    remaining = rand()*z
    for i in 1:length(probs)
        remaining -= probs[i]
        if remaining <= 0
            return items[i]
        end
    end
end
