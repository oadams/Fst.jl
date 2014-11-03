export forward_filtering, new_forward_filtering, backward_sampling, sampleone

function forward_filtering(wfst::Wfst)
    f = Dict{Any, Float64}()
    # Will throw an error if an ordering can't be found
    orderings = topological_sort(wfst)
    for s in orderings[1] # The state ordering
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

function new_forward_filtering(wfst::Wfst)
    f = Dict{Any, Float64}()
    # Will throw an error if an ordering can't be found
    orderings = topological_sort(wfst)
    for s in wfst.initial_states
        f[s] = wfst.initial_weights[s]
    end
    for arc in orderings[2]
        if haskey(f, arc.to)
            f[arc.to] += f[arc.from] * arc.weight
        else
            f[arc.to] = f[arc.from] * arc.weight
        end
    end
    return f
end

function backward_sampling(wfst::Wfst, f)
    path = Arc[]
    # Choose the final state first based on final_weights
    state = sampleone(collect(keys(wfst.final_weights)),
            collect(values(wfst.final_weights)))
    while !(state in wfst.initial_states)
        possible_arcs = Arc[]
        possible_arcs_weights = Float64[]
        for arc in wfst.arcs
            if arc.to == state
                push!(possible_arcs, arc)
                push!(possible_arcs_weights, arc.weight)
            end
        end
        #println(string("possible_arcs: ", possible_arcs))
        #println(string("possible_arcs_weights: ", possible_arcs_weights))
        chosen_arc = sampleone(possible_arcs, possible_arcs_weights)
        unshift!(path, chosen_arc)
        state = chosen_arc.from
        #println(state)
    end
    return(path)
    # This code should behave differently depending on the semiring used.
end

# Samples from items where each item has a corresponding probability located at
# the same index in probs
function sampleone(items::Array, probs::Array{Float64})
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
