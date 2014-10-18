export wfst2dot, create_pdf

# Returns a string representation of the supplied WFST in the DOT language for
# use with Graphviz.
function wfst2dot(wfst::Wfst)
    s = "digraph FST {\n"
    for node in wfst.states
        nodetext = replace(string(node), r"\"", "\\\"")
        if node in wfst.final_states
            s = "$s\t\"$nodetext\" [shape=doublecircle, color=purple
                label=\"$nodetext$(haskey(wfst.final_weights, node) ?
                string("/", wfst.final_weights[node]) : "")\"]\n"
        elseif node in wfst.initial_states
            s = "$s\t\"$nodetext\" [shape=circle, color=green
                label=\"$nodetext$(haskey(wfst.initial_weights, node) ?
                string("/", wfst.initial_weights[node]) : "")\"]\n"
        else
            s = "$s\t\"$nodetext\" [shape=circle]\n"
        end
    end
    for arc in wfst.arcs
        # fromtext and totext used to allow us to prepend quotes in the
        # actual nodes names with backslashes so that bash pipes the desired
        # text to graphviz.
        fromtext = replace(string(arc.from), r"\"", "\\\"")
        totext = replace(string(arc.to), r"\"", "\\\"")
        s = string("$s\t\"$fromtext\" -> \"$totext\",",
             "[label=\"$(string(arc.input)):$(string(arc.output))",
             "/$(arc.weight)\"];\n")
    end
    s = "$s}"
    return s
end

function create_pdf(wfst::Wfst, filename::String)
    dotstring = wfst2dot(wfst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end
