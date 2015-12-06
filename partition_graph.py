# e*- encoding:utf-8 -*-
import networkx as nx
# import matplotlib.pyplot as plt
import pygraphviz as pgv
import csv
import metis
import pydot
from pprint import pprint


print "こんにちは"

vector = {}



G=nx.Graph()
which_lang="JaToEn_EnToDe"
# which_lang="Ind_Mnk_Zsm_new"
# which_lang="Zh_Uy_Kz"
input_filename="share_ratio/"+which_lang+".csv"
output_each_trans_filename="connected_components/each_trans/"+which_lang

f = open(input_filename, 'rb')
dataReader = csv.reader(f)
for row in dataReader:
    # print row[0]
    G.add_node(row[0],lang='En')
    # G.graph[row[0]]='English'
    vector[row[0]] = []
    row1_separate =row[1].split(',')
    row2_separate =row[2].split(',')
    for lang_a in row1_separate:
        vector[row[0]].append(lang_a)
        G.add_node(lang_a,lang='Ja')
        G.add_edge(lang_a,row[0])
        pprint(lang_a)

    for lang_b in row2_separate:
        vector[row[0]].append(lang_b)
        G.add_node(lang_b,lang='De')
        G.add_edge(lang_b,row[0])
        pprint(lang_b)

    #    print lang_a.decode().encode('utf-8')
# G.add_edges_from([(1,2),(1,3)])
f.close()
# G = nx.Graph(vector)

# g = nx.to_agraph(G)
# g.draw('PyGraphviz.pdf',prog='circo')

# print "start connected_component_subgraphs"
# cc=nx.connected_components(G)
# for component in cc:
#     pprint(component)


print "hhhhhhhh"
# graphs = list(nx.connected_component_subgraphs(G))
graphs = nx.connected_component_subgraphs(G)
# graphs=[len(c) for c in sorted(nx.connected_components(G), key=len, reverse=True)]
# pprint(graphs)
i=0
# print "graphsの数:"+str((sum(1 for i in graphs)))
# for subgraph in nx.connected_components(G):
for subgraph in graphs:
    # print(G.adj)
    print "subgraph number:"+str(i)
    print "subgraph node数:"+str(len(subgraph))

    if 7 < len(subgraph):
        # f = open(output_each_trans_filename+str(i)+"_subgraph.csv", 'w')
        # writer = csv.writer(f, lineterminator='\n')
        with open(output_each_trans_filename+str(i)+"_subgraph.csv", "w") as file:

            for node in subgraph.nodes():
                ja_neighbors_pivot = set()
                de_neighbors_pivot = set()
                lang=nx.get_node_attributes(subgraph,'lang')
                if lang[node]=='En':
                    pprint(node)
                    file.write(node+",")
                    for node_ja_de in subgraph.neighbors(node):
                        if lang[node_ja_de]=='Ja':
                            ja_neighbors_pivot.add(node_ja_de)
                        elif lang[node_ja_de]=='De':
                            de_neighbors_pivot.add(node_ja_de)

                    # pprint(subgraph.nodes())
                    # pprint(subgraph.edges())
                    # writer.writerow(node+'\n')
                    for ja in ja_neighbors_pivot:
                        file.write(ja+",")

                    for de in de_neighbors_pivot:
                        file.write(de+",")

                    file.write("\n")

        i+=1
            # f.close()

# print "meris start"
# (edgecuts, parts) = metis.part_graph(G, nparts=30, recursive=True)
# pprint(parts)
# pprint(edgecuts)
#
# for part in parts:
#     pprint(part)

# for i, p in enumerate(parts):
#     G.node[i]['partition'] = p

# nx.write_dot(G, 'example.dot')






# g = nx.to_agraph(G)
#
# g.draw('PyGraphviz.pdf',prog='circo')
