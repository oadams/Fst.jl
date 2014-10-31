export forward_filtering

function forward_filtering(wfst::Wfst)
    f = Dict{Any, Float64}()
    # Will throw an error if an ordering can't be found
    ordering = topological_sort(wfst)
    # Set the forward probabilities to be the initial weights.
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
