export accessible

function accessible(wfst::Wfst)
    stack = wfst.initial_states
    discovered_states = Any[]
    discovered_arcs = Arc[]
    # Classic DFS
    while length(stack) > 0
        state = pop!(stack)
        if !(state in discovered_states)
            push!(discovered_states, state)
            for arc in wfst.arcs
                if arc.from == state
                    push!(stack, arc.to)
                    push!(discovered_arcs, arc)
                end
            end
        end
    end

    new = deepcopy(wfst)
    new.states = Set(discovered_states)
    new.arcs = Set(discovered_arcs)
    return new
end
