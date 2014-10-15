# The FST type that doesn't support weighted arcs.
type Wfst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    transitions::Set
end

# Empty constructor
Wfst() = Wfst(Set(), Set{String}(), Set{String}(), Set(), Set(), Set())

function wfst2dot(wfst::Wfst)
    s = "digraph FST {\n"
    for rule in wfst.transitions
        # fromtext and totext used to allow us to prepend quotes in the
        # actual nodes names with backslashes so that bash pipes the desired
        # text to graphviz.
        fromtext = replace(string(rule[1]), r"\"", "\\\"")
        totext = replace(string(rule[2]), r"\"", "\\\"")
        s = "$s\t\"$fromtext\" -> \"$totext\"
                [label=\"$(string(rule[3])):$(string(rule[4]))/$(rule[5])\"];\n"
    end
    s = "$s}"
    return s
end

function create_pdf(wfst::Wfst, filename::String)
    dotstring = wfst2dot(wfst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end

function add_arc(wfst::Wfst,
        from::String, to::String,
        input::String, output::String, weight::Float64)
    wfst.states = union(wfst.states, Set([[from], [to]]))
    wfst.input_alphabet = union(wfst.input_alphabet, Set([input]))
    wfst.output_alphabet = union(wfst.output_alphabet, Set([output]))
    wfst.transitions =
            union(wfst.transitions, Set([(from, to, input, output, weight)]))
end

function compose(a::Wfst, b::Wfst)
    # Check that the output alphabet of a matches the input alphabet of b

    # New states are the cross product of the states of the two FSTs
    states = Set([(x,y) for x in a.states, y in b.states])
    ##println(states)

    # New initial_states and final_states are created similarly
    initial_states =
            Set([(x,y) for x in a.initial_states, y in b.initial_states])
    ##println(initial_states)
    final_states =
            Set([(x,y) for x in a.final_states, y in b.final_states])
    #println(final_states)

    # Then combine the rules
    transitions = Set()
    for a_rule in a.transitions
        for b_rule in b.transitions
            if a_rule[4] == b_rule[3]
                transitions = union(transitions,
                        Set([((a_rule[1], b_rule[1]), (a_rule[2], b_rule[2]),
                        a_rule[3], b_rule[4])]))
            end
        end
    end
    #println(transitions)

    input_alphabet = a.input_alphabet
    output_alphabet = b.output_alphabet

    # Then consider removing unreachable states and transitions that cannot
    # occur

    # Then create the new wfst and return it
    #println(typeof(states))
    #println(typeof(input_alphabet))
    #println(typeof(output_alphabet))
    #println(typeof(initial_states))
    ###println(typeof(final_states))
    #println(typeof(transitions))
    return Wfst(states, input_alphabet, output_alphabet, initial_states,
           final_states, transitions)
end

a = Wfst()
add_arc(a, "0", "1", "a", "b", 0.1)
add_arc(a, "1", "0", "a", "b", 0.2)
add_arc(a, "1", "2", "b", "b", 0.3)
add_arc(a, "1", "3", "b", "b", 0.4)
add_arc(a, "2", "3", "a", "b", 0.5)
wfst2dot(a)
create_pdf(a, "a.pdf")


b = Wfst()
add_arc(b, "0", "1", "b", "b", 0.1)
add_arc(b, "1", "1", "b", "a", 0.2)
add_arc(b, "1", "2", "a", "b", 0.3)
add_arc(b, "1", "3", "a", "b", 0.4)
add_arc(b, "2", "3", "b", "a", 0.5)
create_pdf(b, "b.pdf")

#c = compose(a, b)
#create_pdf(c, "c.pdf")
