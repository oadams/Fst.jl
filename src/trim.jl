export accessible, coaccessible, trim

function accessible(wfst::Wfst)
    stack = copy(wfst.initial_states)
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

    println(wfst)
    new = deepcopy(wfst)
    new.states = Set(discovered_states)
    new.arcs = Set(discovered_arcs)
    println(new)
    return new
end

function coaccessible(wfst::Wfst)
    stack = copy(wfst.final_states)
    discovered_states = Any[]
    discovered_arcs = Arc[]
    # Classic DFS, just reversing the direction we follow arcs
    while length(stack) > 0
        state = pop!(stack)
        if !(state in discovered_states)
            push!(discovered_states, state)
            for arc in wfst.arcs
                # Note the reversal of arc.to and arc.from
                if arc.to == state
                    push!(stack, arc.from)
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

function trim(wfst::Wfst)
    return coaccessible(accessible(wfst))
end
