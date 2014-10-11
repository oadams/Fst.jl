# The FST type that doesn't support weighted arcs.
type Fst
    states::Set{String}
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set{String}
    final_states::Set{String}
    transitions::Set{(String, String, String, String)}
end

# Empty constructor
Fst() = Fst(Set{String}(), Set{String}(), Set{String}(), Set{String}(),
        Set{String}(), Set{(String, String, String, String)}())

function fst2dot(fst::Fst)
    s = "digraph FST {\n"
    for rule in fst.transitions
        #s = string(s, "\t", rule[1], " -> ", rule[2], ";\n")
        s = "$s\t$(rule[1]) -> $(rule[2]) [label=\"$(rule[3])/$(rule[4])\"];\n"
    end
    s = "$s}"
    return s
end

function add_arc(fst::Fst,
        from::String, to::String,
        input::String, output::String)
    fst.states = union(fst.states, Set([[from], [to]]))
    fst.input_alphabet = union(fst.input_alphabet, Set([input]))
    fst.output_alphabet = union(fst.output_alphabet, Set([output]))
    fst.transitions = union(fst.transitions, Set([(from, to, input, output)]))
end

function compose(a::Fst, b::Fst)
    # Check that the output alphabet of a matches the input alphabet of b

    # New states are the cross product of the states of the two FSTs
    states = Set([(x,y) for x in a.states, y in b.states])
    println(states)

    # New initial_states and final_states are created similarly
    initial_states =
            Set([(x,y) for x in a.initial_states, y in b.initial_states])
    println(initial_states)
    final_states =
            Set([(x,y) for x in a.final_states, y in b.final_states])
    println(final_states)

    # Then combine the rules
    transitions = Set()
    for a_rule in a.transitions
        for b_rule in b.transitions
            if a_rule[4] == b_rule[3]
                transitions = [transitions,
                        rule = ((a_rule[0], b_rule[0]), (a_rule[1], b_rule[1]),
                        a_rule[3], b_rule[4])]
            end
        end
    end
    println(transitions)
    println(Set(transitions))

    # Then consider removing unreachable states and transitions that cannot
    # occur

    # Then create the new fst and return it
    # return Fst(states, input_alphabet, output_alphabet, initial_states,
    #       final_states, transitions)
end
