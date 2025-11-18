Class {
	#name : #SomReferenceVector,
	#superclass : #Object,
	#instVars : [
		'som',
		'index',
		'weight',
		'point2D',
		'gridPosition'
	],
	#category : #'Som-Core'
}

{ #category : #'instance creation' }
SomReferenceVector class >> som: aSom
index: anIndex
weight: aWeight
point2D: aPoint
gridPosition: aGridPoint [

    ^ self new
        som: aSom;
        index: anIndex;
        weight: aWeight;
        point2D: aPoint;
        gridPosition: aGridPoint;
        yourself

]

{ #category : #accessing }
SomReferenceVector >> gridPosition [
	"its place on the SOM lattice"

	^ gridPosition
]

{ #category : #accessing }
SomReferenceVector >> gridPosition: aPoint [
    gridPosition := aPoint

]

{ #category : #'gt-views' }
SomReferenceVector >> gtImageOn: aView [
    <gtView>
    ^ aView explicit
        title: 'Weight image';
        stencil: [ :v |
            BlElement new
                size: 200@200;
                background: Color red;
                yourself ]
]

{ #category : #visualization }
SomReferenceVector >> imageForm [
	"Convert the weight vector into a grayscale Form, assuming dimension ≈ n².
     If the vector is not a perfect square, we just leave trailing pixels white."

	| n values form |
	n := weight size sqrt rounded.
	values := weight collect: [ :v | (v max: 0.0) min: 1.0 ].

	form := Form extent: n @ n depth: 32.
	form fillColor: Color white.

	1
		to: n
		do: [ :y | 
			1
				to: n
				do: [ :x | 
					| idx gray |
					idx := (y - 1) * n + x.
					idx <= values size
						ifTrue: [ gray := values at: idx.
							form colorAt: x @ y put: (Color gray: gray) ] ] ].

	^ form
]

{ #category : #accessing }
SomReferenceVector >> index [
	"neuron number"

	^ index
]

{ #category : #accessing }
SomReferenceVector >> index: anInteger [
    index := anInteger

]

{ #category : #accessing }
SomReferenceVector >> point2D [
	"its position in input space"

	^ point2D
]

{ #category : #accessing }
SomReferenceVector >> point2D: aPoint [
    point2D := aPoint

]

{ #category : #printing }
SomReferenceVector >> printOn: aStream [
    super printOn: aStream.
    aStream
        nextPutAll: ' index: '; print: index;
        nextPutAll: ' point2D: '; print: point2D

]

{ #category : #accessing }
SomReferenceVector >> som [
    ^ som

]

{ #category : #accessing }
SomReferenceVector >> som: aSom [
    som := aSom

]

{ #category : #accessing }
SomReferenceVector >> weight [
	"full weight vector"

	^ weight
]

{ #category : #accessing }
SomReferenceVector >> weight: anArray [
    weight := anArray

]
