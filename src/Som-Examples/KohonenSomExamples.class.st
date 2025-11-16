Class {
	#name : #KohonenSomExamples,
	#superclass : #Object,
	#category : #'Som-Examples'
}

{ #category : #examples }
KohonenSomExamples class >> exampleUnitSquare2D [
    <gtExample>
    "Train a small SOM on random points in the unit square."
    
    | data som numberOfSamples |
    numberOfSamples := 500.
    data := (1 to: numberOfSamples) collect: [ :i |
        { Random new next. Random new next } asArray ].
    
    som := KohonenSom new
        initializeWithInputDimension: 2
        width: 10
        height: 10
        iterations: 2000.
    
    som trainOn: data.
    ^ som
]

{ #category : #examples }
KohonenSomExamples class >> exampleWeightCoordinates2D [
    <gtExample>
    "Return a collection of Points representing weight vectors in 2D."
    
    | som coords |
    som := self exampleUnitSquare2D.
    coords := som weights collect: [ :w |
        (w size >= 2)
            ifTrue: [ (w first) @ (w second) ]
            ifFalse: [ 0 @ 0 ] ].
    ^ coords
]
