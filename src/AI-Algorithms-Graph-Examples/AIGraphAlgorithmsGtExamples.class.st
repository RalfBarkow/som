Class {
	#name : #AIGraphAlgorithmsGtExamples,
	#superclass : #Object,
	#category : #'AI-Algorithms-Graph-Examples-GT-Examples'
}

{ #category : #'examples - basic' }
AIGraphAlgorithmsGtExamples class >> basicUnweightedGraph [
    <gtExample>
    | algo |
    "Example for PharoGraphs, chapter 3: Graph Representation.
    A small directed graph A → B, A → C, B → C."
    algo := AIGraphAlgorithm new.
    algo
        nodes: #( $A $B $C );
        edges: #(
            #( $A $B )
            #( $A $C )
            #( $B $C )
        ) from: #first to: #second.
    ^ algo
]

{ #category : #'examples - basic' }
AIGraphAlgorithmsGtExamples class >> basicWeightedGraph [
    <gtExample>
    | algo |
    "Example for PharoGraphs, section on weighted graphs."
    algo := AIGraphAlgorithm new.
    algo
        nodes: #( $A $B $C );
        edges: #(
            #( $A $B 2 )
            #( $A $C 4 )
            #( $B $C 7 )
        )
        from: #first
        to: #second
        weight: #third.
    ^ algo
]

{ #category : #'examples - shortest path' }
AIGraphAlgorithmsGtExamples class >> bfsShortestPathExample [
    <gtExample>
    | bfs nodes edges |
    "PharoGraphs, chapter 5: shortest path on unweighted graph via BFS.
     Simple toy graph from the booklet pattern."
    nodes := $A to: $I.
    edges := #(
        #( $A $B ) #( $B $C ) #( $C $D ) #( $D $E ) #( $E $A )
        #( $B $E ) #( $E $B ) #( $E $F ) #( $F $G ) #( $G $H )
        #( $H $F ) #( $G $I ) #( $I $G )
    ).
    bfs := AIBFS new.
    bfs
        nodes: nodes;
        edges: edges from: #first to: #second.
    ^ bfs runFrom: $A to: $G  "returns the path as a LinkedList of chars"
]

{ #category : #'examples - shortest path' }
AIGraphAlgorithmsGtExamples class >> dijkstraShortestPathExample [
    <gtExample>
    | dijkstra nodes edges |
    "PharoGraphs, chapter 5: Dijkstra on a small weighted graph."
    nodes := #( $A $B $C $D $E $F $G ).
    edges := #(
        #( $A $B 1 )
        #( $A $C 4 )
        #( $B $C 2 )
        #( $B $D 5 )
        #( $C $E 1 )
        #( $D $F 2 )
        #( $E $D 1 )
        #( $E $G 3 )
        #( $F $G 1 )
    ).
    dijkstra := AIDijkstra new.
    dijkstra
        nodes: nodes;
        edges: edges
            from: #first
            to: #second
            weight: #third.
    ^ dijkstra runFrom: $A to: $G   "shortest A→G path"
]

{ #category : #'examples - matching' }
AIGraphAlgorithmsGtExamples class >> greedyMatchingExample [
    <gtExample>
    | algo nodes edges matching |
    "PharoGraphs, chapter 9: greedy matching.
     U = {a1,a2}, V = {b1,b2,b3}."
    nodes := #( #a1 #a2 #b1 #b2 #b3 ).
    edges := #(
        #( #a1 #b1 )
        #( #a1 #b2 )
        #( #a2 #b2 )
        #( #a2 #b3 )
    ).
    algo := AIGreedyMatching new.
    algo
        nodes: nodes;
        edges: edges from: #first to: #second.
    matching := algo run.  "collection of AIGraphEdge"
    ^ matching collect: [ :e |
        { e from model. e to model } ]
]

{ #category : #'examples - hits' }
AIGraphAlgorithmsGtExamples class >> hitsToyWebGraph [
    <gtExample>
    | hits nodes edges |
    "PharoGraphs, chapter 8: HITS (hubs & authorities)."
    nodes := #( #a #b #c #d ).  "pages"
    edges := #(
        #( #a #b )
        #( #a #c )
        #( #b #c )
        #( #c #d )
    ).
    hits := AIHits new.
    hits
        nodes: nodes;
        edges: edges from: #first to: #second.
    hits run.
    ^ hits nodes collect: [ :node |
        { node model. node hub. node auth } ]
]

{ #category : #'examples - mst' }
AIGraphAlgorithmsGtExamples class >> kruskalMstExample [
    <gtExample>
    | algo nodes edges treeEdges |
    "PharoGraphs, chapter 6: Kruskal's algorithm (MST)."
    nodes := #( $A $B $C $D $E ).
    edges := #(
        #( $A $B 3 )
        #( $A $C 1 )
        #( $B $C 1 )
        #( $B $D 4 )
        #( $C $D 2 )
        #( $C $E 5 )
        #( $D $E 1 )
    ).
    algo := AIKruskal new.
    algo
        nodes: nodes;
        edges: edges
            from: #first
            to: #second
            weight: #third.
    treeEdges := algo run.   "collection of AIGraphWeightedEdge"
    ^ treeEdges collect: [ :e |
        { e from model. e to model. e weight } ]
]

{ #category : #'examples - som bridge' }
AIGraphAlgorithmsGtExamples class >> somLikeGridGraph [
    <gtExample>
    | g |
    "Bridge to the som project: a 2D grid graph that can be read as
     a Kohonen map lattice (each node = a unit, edges = neighbours).
     Uses AIGrid2DGenerator's existing example API."
    g := AIGrid2DGenerator new
        width: 10;
        height: 10;
        neighborhood: #moore;
        yourself.
    g run.
    "Return nodes + edges as a tuple-like array for exploration or
     for feeding a KohonenSom or GT view later."
    ^ { g nodes. g edges }
]

{ #category : #'examples - scc' }
AIGraphAlgorithmsGtExamples class >> tarjanSccExample [
    <gtExample>
    | algo nodes edges |
    "PharoGraphs, chapter 7: Tarjan's strongly connected components."
    nodes := #( $A $B $C $D $E $F ).
    edges := #(
        #( $A $B )
        #( $B $C )
        #( $C $A )   "A-B-C forms an SCC"
        #( $B $D )
        #( $D $E )
        #( $E $D )   "D-E forms an SCC"
        #( $E $F )
    ).
    algo := AITarjan new.
    algo
        nodes: nodes;
        edges: edges from: #first to: #second.
    ^ algo stronglyConnectedComponents
        "returns #( #( $A $B $C ) #( $D $E ) #( $F ) ) (order may vary)"
]

{ #category : #'examples - topo sort' }
AIGraphAlgorithmsGtExamples class >> topologicalSortModules [
    <gtExample>
    | sorter nodes edges |
    "PharoGraphs, chapter 4: A DAG representing module dependencies.
     This is essentially the book's software-modules example."
    nodes := #( $A $B $C $D $E $F $G ).
    edges := #(
        #( $A $B )
        #( $A $C )
        #( $B $E )
        #( $C $E )
        #( $C $D )
        #( $D $E )
        #( $D $F )
        #( $E $G )
        #( $F $G )
    ).
    sorter := AITopologicalSorting new.
    sorter
        nodes: nodes;
        edges: edges from: #first to: #second.
    ^ sorter run  "returns an OrderedCollection of models"
]
