Class {
	#name : #SomNeuronMirror,
	#superclass : #Object,
	#instVars : [
		'som',
		'index'
	],
	#category : #'Som-Core'
}

{ #category : #'instance creation' }
SomNeuronMirror class >> som: aSom index: anIndex [
    ^ self new
        som: aSom;
        index: anIndex;
        yourself
]

{ #category : #'gt-views' }
SomNeuronMirror >> buildInfoColumn [
    | col text |
    col := BlElement new.
    col layout: BlLinearLayout vertical.

    text := String streamContents: [ :s |
        s
            nextPutAll: 'Neuron #'; nextPutAll: self index asString; cr;
            nextPutAll: 'Grid position: ('; nextPutAll: self gridRow asString;
            nextPutAll: ', '; nextPutAll: self gridColumn asString; nextPutAll: ')' ].

    col addChild: (BrLabel new
        text: text;
        yourself).

    ^ col
]

{ #category : #'gt-views' }
SomNeuronMirror >> buildMirrorElement [
    | root layout |
    root := BlElement new.
    layout := BlLinearLayout horizontal.
    layout cellSpacing: 16.
    root layout: layout.

    root addChild: self buildInfoColumn.
    root addChild: self buildNeighborsColumn.
    root addChild: self buildWeightBarsColumn.

    ^ root
]

{ #category : #'gt-views' }
SomNeuronMirror >> buildNeighborsColumn [
    | col header rows |
    col := BlElement new.
    col layout: BlLinearLayout vertical.

    header := BrLabel new
        text: 'Neighbours (index / Δ in signal space)';
        yourself.
    col addChild: header.

    rows := self distanceToNeighborWeights
        collect: [ :triple |
            | idx dist row |
            idx := triple first.
            dist := triple third.
            row := BrLabel new
                text: ('#', idx asString, '  d² = ', dist printString);
                yourself.
            row ].

    rows do: [ :r | col addChild: r ].

    ^ col
]

{ #category : #'gt-views' }
SomNeuronMirror >> buildWeightBarsColumn [
    | col w maxAbs |
    col := BlElement new.
    col layout: BlLinearLayout vertical.

    col addChild: (BrLabel new
        text: 'Reference vector components';
        yourself).

    w := self weight.
    maxAbs := (w collect: [ :v | v abs ]) max max: 1e-6.

    w withIndexDo: [ :value :idx |
        | row label bar barWidth |
        row := BlElement new.
        row layout: BlLinearLayout horizontal.
        row layout cellSpacing: 4.

        label := BrLabel new
            text: idx asString;
            yourself.

        barWidth := (200 * (value abs / maxAbs)) asFloat.

        bar := BlElement new.
        bar background: Color gray.
        bar width: barWidth.
        bar height: 8.

        row addChild: label.
        row addChild: bar.

        col addChild: row ].

    ^ col
]

{ #category : #metrics }
SomNeuronMirror >> distanceToNeighborWeights [
    "Answer {index . weight . squaredDistance} for each neighbour."
    | w |
    w := self weight.
    ^ self neighborIndices collect: [ :i |
        | nw d |
        nw := som weights at: i.
        d := self squaredDistanceFrom: w to: nw.
        { i . nw . d } ]
]

{ #category : #query }
SomNeuronMirror >> gridColumn [
    "1-based column of this neuron in the SOM grid."
    ^ ((self index - 1) \\ self gridWidth) + 1
]

{ #category : #query }
SomNeuronMirror >> gridHeight [
    ^ som height
]

{ #category : #derived }
SomNeuronMirror >> gridPosition [
    "2D lattice position of this neuron (x@y)."
    ^ som positionOfIndex: index
]

{ #category : #query }
SomNeuronMirror >> gridRow [
    "1-based row of this neuron in the SOM grid."
    ^ ((self index - 1) // self gridWidth) + 1
]

{ #category : #query }
SomNeuronMirror >> gridWidth [
    ^ som width
]

{ #category : #'gt-views' }
SomNeuronMirror >> gtMirrorOn: aView [
    <gtView>
    ^ aView explicit
        title: 'Neuron as mirror';
        stencil: [ :v | self buildMirrorElement ]
]

{ #category : #'gt-views' }
SomNeuronMirror >> gtNeuronAsMirrorOn: aView [
    <gtView>
    ^ aView explicit
        title: 'Neuron as mirror';
        stencil: [ :v |
            | root header weights neighbors |

            root := BlElement new.
            root layout: BlLinearLayout vertical.
            root padding: (BlInsets all: 10).

            header := BrLabel new
                text: ('Neuron #{1} at {2}'
                    format: { self index. self gridPosition });
                yourself.

            weights := BrLabel new
                text: ('Weight vector: {1}'
                    format: { self weightVector printString });
                yourself.

            neighbors := BrLabel new
                text: ('Neighbor indices: {1}'
                    format: { self neighborIndices printString });
                yourself.

            root addChild: header.
            root addChild: weights.
            root addChild: neighbors.

            root ]
]

{ #category : #accessing }
SomNeuronMirror >> index [
    ^ index
]

{ #category : #accessing }
SomNeuronMirror >> index: anInteger [
    index := anInteger
]

{ #category : #derived }
SomNeuronMirror >> neighborIndices [
    "Indices of immediate grid neighbors (8-neighborhood) around this neuron."
    | myPos |
    myPos := self gridPosition.
    ^ (1 to: som weights size) select: [ :i |
        i ~= index and: [
            | p d2 |
            p := som positionOfIndex: i.
            d2 := som gridDistanceSquaredFrom: myPos to: p.
            d2 <= 2 ] ]
]

{ #category : #derived }
SomNeuronMirror >> neighborWeightVectors [
    "Weight vectors of the neighboring neurons."
    ^ self neighborIndices collect: [ :i | som weights at: i ]
]

{ #category : #query }
SomNeuronMirror >> neighborsWithWeights [
    "Answer an OrderedCollection of {index . weight} for neighbours."
    ^ self neighborIndices collect: [ :i |
        { i . (som weights at: i) } ]
]

{ #category : #accessing }
SomNeuronMirror >> som [
    ^ som
]

{ #category : #accessing }
SomNeuronMirror >> som: aSom [
    som := aSom
]

{ #category : #metrics }
SomNeuronMirror >> squaredDistanceFrom: v1 to: v2 [
    "Euclidean squared distance over collections of numbers."
    ^ (v1 with: v2 collect: [ :a :b | (a - b) squared ]) sum
]

{ #category : #query }
SomNeuronMirror >> weight [
    "The reference / codebook vector for this neuron."
    ^ som weights at: index
]

{ #category : #derived }
SomNeuronMirror >> weightVector [
    "Reference / codebook vector of this neuron."
    ^ som weights at: index
]
