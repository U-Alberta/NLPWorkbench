import itertools

from semantic import *


# TODO:
# better way to find predicates for triples
# handle ARG-of
# something with dates

text = """
(z0 / and
    :op1 (z1 / close-01
             :ARG0 (z2 / company
                       :wiki "Google"
                       :name (z3 / name
                                 :op1 "Google"
                                 :op2 "Inc"))
             :ARG1 (z4 / service
                       :purpose (z5 / search-01)
                       :ARG1-of (z6 / base-01
                                    :location (z7 / country
                                                  :wiki "China"
                                                  :name (z8 / name
                                                            :op1 "China")))
                       :poss z2)
             :time (z9 / date-entity
                       :weekday (z10 / monday)))
    :op2 (z11 / begin-01
              :ARG0 z2
              :ARG1 (z12 / redirect-01
                         :ARG0 z2
                         :ARG1 (z13 / person
                                    :ARG0-of (z14 / search-01
                                                  :ARG1 (z15 / web)))
                         :ARG2 (z16 / site
                                    :ARG1-of (z17 / censor-01
                                                  :polarity -)
                                    :location (z18 / city
                                                   :wiki "Hong_Kong"
                                                   :name (z19 / name
                                                              :op1 "Hong"
                                                              :op2 "Kong")))))
    :ARG0-of (z20 / cause-01
                  :ARG1 (z21 / draw-02
                             :ARG0 z2
                             :ARG1 (z22 / thing
                                        :ARG1-of (z23 / comment-01
                                                      :ARG0 (z24 / city
                                                                 :wiki "Beijing"
                                                                 :name (z25 / name
                                                                            :op1 "Beijing")))
                                        :ARG1-of (z26 / harsh-02)
                                        :ARG0-of (z27 / raise-01
                                                      :ARG1 (z28 / doubt-01
                                                                 :ARG1 (z29 / future
                                                                            :poss z2
                                                                            :location (z30 / market
                                                                                           :mod (z31 / internet)
                                                                                           :ARG1-of (z32 / have-degree-91
                                                                                                         :ARG2 (z33 / large)
                                                                                                         :ARG3 (z34 / most)
                                                                                                         :ARG5 (z35 / market
                                                                                                                    :location (z36 / world))))))))))
    :ARG1-of (z37 / describe-01
                  :ARG0 (z38 / publication
                             :wiki "Reuters"
                             :name (z39 / name
                                        :op1 "Reuters"))))
"""

tree = parse_single_amr_output(text)
graph = amr_tree_to_graph(tree)

def is_verb(node):
    # TODO: not like this
    return type(node) is not AMRConstant and '-0' in node.concept and len(node._edges) > 0

def extract_verb_triples(node):
    if type(node) == AMRConstant: return
    #print(node)
    arg0 = node._edges[0].var2
    for edge in node._edges[1:]:
        yield (arg0.name, node.name, edge.var2.name)

def join_name(node):
    return " ".join([e.var2.value for e in node._edges])

def build_alias_dict(graph):
    alias_graph = {}
    for node in graph.nodes:

        # not applicable to constants
        if type(node) is AMRConstant: continue

        # add the "concept" to the dict
        alias_graph[node.name] = alias_graph.get(node.name, []) + [node.concept]

        for edge in node._edges:
            # add all "wiki" names
            if edge.relationship == "wiki":
                alias_graph[node.name] = alias_graph.get(node.name, []) + [edge.var2.value]
            # add all "name" names
            #if edge.relationship == "name":
            #    alias_graph[node.name] = alias_graph.get(node.name, []) + [join_name(edge.var2)]
    return alias_graph

def extract_all(graph):
    triples = []
    for node in graph.nodes:
        if is_verb(node):
            triples.extend(list(extract_verb_triples(node)))
    return triples

def expand_triples(list_of_triples, alias_dict):
    for triple in list_of_triples:
        expanded = itertools.product(*[alias_dict[name] for name in triple])
        for e in expanded: print(e)

if __name__ == "__main__":
    triples = extract_all(graph)
    alias_dict = build_alias_dict(graph)
    expand_triples(triples, alias_dict)
