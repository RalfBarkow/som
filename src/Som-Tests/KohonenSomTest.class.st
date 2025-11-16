Class {
	#name : #KohonenSomTest,
	#superclass : #TestCase,
	#category : #'Som-Tests'
}

{ #category : #tests }
KohonenSomTest >> testBestMatchingUnitReasonable [
    | som input winnerVector winnerDistance |
    som := KohonenSom new
        initializeWithInputDimension: 2
        width: 3
        height: 3
        iterations: 1.
    
    input := { 0.5. 0.5 } asArray.
    winnerVector := som weights at: (som bestMatchingUnitIndexFor: input).
    winnerDistance := som
        distanceSquaredBetween: winnerVector
        and: input.
    
    som weights do: [ :w |
        self assert: (som distanceSquaredBetween: w and: input) >= winnerDistance ]
]

{ #category : #tests }
KohonenSomTest >> testInitializationShapes [
    | som |
    som := KohonenSom new
        initializeWithInputDimension: 3
        width: 5
        height: 4
        iterations: 10.
    
    self assert: som weights size equals: 5 * 4.
    som weights do: [ :w |
        self assert: w size equals: 3 ]
]

{ #category : #tests }
KohonenSomTest >> testWeightsChangeAfterTraining [
    | som data before after |
    som := KohonenSom new
        initializeWithInputDimension: 2
        width: 3
        height: 3
        iterations: 20.
    
    data := #( {0.0. 0.0} {1.0. 1.0} ) collect: #asArray.
    before := som weights collect: [ :w | w collect: [ :v | v ] ].
    
    som trainOn: data.
    after := som weights.
    
    self deny: (before = after)
]
