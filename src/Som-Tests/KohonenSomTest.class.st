Class {
	#name : #KohonenSomTest,
	#superclass : #TestCase,
	#instVars : [
		'som'
	],
	#category : #'Som-Tests'
}

{ #category : #tests }
KohonenSomTest >> setUp [
	"Create a small, reproducible SOM for the tests.
     Adjust iterations if needed, but keep it > 20 so decay tests make sense."

	som := KohonenSom new
			initializeWithInputDimension: 2
			width: 3
			height: 3
			iterations: 100	"maxIterations"
]

{ #category : #tests }
KohonenSomTest >> testBestMatchingUnitReasonable [
	| input winnerVector winnerDistance |
	som := KohonenSom new
			initializeWithInputDimension: 2
			width: 3
			height: 3
			iterations: 1.

	input := {0.5.
			0.5} asArray.
	winnerVector := som weights at: (som bestMatchingUnitIndexFor: input).
	winnerDistance := som distanceSquaredBetween: winnerVector and: input.

	som weights
		do: [ :w | self assert: (som distanceSquaredBetween: w and: input) >= winnerDistance ]
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testBestMatchingUnitSelectsExactMatch [
	"If one neuron weight exactly equals the input and all others are far away,
     BMU must be that neuron. This falsifies distance/indexing bugs."

	| input far |
	input := #(0.0 0.0) asArray.
	far := #(10.0 10.0) asArray.

	1 to: som weights size do: [ :i | som weights at: i put: far copy ].
	som weights at: 1 put: input copy.

	self assert: (som bestMatchingUnitIndexFor: input) equals: 1
]

{ #category : #tests }
KohonenSomTest >> testInitializationShapes [
	som := KohonenSom new
			initializeWithInputDimension: 3
			width: 5
			height: 4
			iterations: 10.

	self assert: som weights size equals: 5 * 4.
	som weights do: [ :w | self assert: w size equals: 3 ]
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testNeighborhoodInfluenceIsMaxAtWinnerAndDecreasesWithGridDistance [
	"At t = 0, Gaussian neighborhood should give:
     h(winner,winner) = 1, and strictly decreasing with grid distance.
     This will fail if radiusAtTime: or gridDistance logic is wrong."

	| winnerIndex neighborIndex farIndex hWinner hNeighbor hFar |
	"Assuming 3x3 grid with indices:
        1 2 3
        4 5 6
        7 8 9
     winner = 5 (center), neighbor = 2, far = 1."
	winnerIndex := 5.
	neighborIndex := 2.
	farIndex := 1.

	hWinner := som
			neighborhoodInfluenceAtTime: 0
			winnerIndex: winnerIndex
			neuronIndex: winnerIndex.

	hNeighbor := som
			neighborhoodInfluenceAtTime: 0
			winnerIndex: winnerIndex
			neuronIndex: neighborIndex.

	hFar := som
			neighborhoodInfluenceAtTime: 0
			winnerIndex: winnerIndex
			neuronIndex: farIndex.	"At zero distance we expect e^(0) = 1."
	self
		assert: (hWinner closeTo: 1.0)
		description: 'Winner influence should be 1 at distance 0'.
	self assert: hWinner > hNeighbor.
	self assert: hNeighbor > hFar
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testRadiusDecaysOverTime [
	"Radius should monotonically decrease over time and never hit zero too early.
     This will fail if radiusAtTime: is constant or not implemented."

	| r0 rMid rEnd mid |
	r0 := som radiusAtTime: 0.
	mid := som maxIterations // 2.
	rMid := som radiusAtTime: mid.
	rEnd := som radiusAtTime: som maxIterations - 1.

	self assert: r0 > rMid.
	self assert: rMid > rEnd.
	self assert: rEnd > 0.0
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testTrainOneMovesBestMatchingUnitTowardsInput [
    "A single training step should move the BMU weight closer to the input.
     This falsifies bugs in updateNeuronAt:withInput:learningRate:neighborhoodInfluence:."
    | input beforeWeights bmuIndex before after |
    input := #(0.2 0.8) asArray.
    beforeWeights := self copyWeights.

    bmuIndex := som bestMatchingUnitIndexFor: input.
    before := beforeWeights at: bmuIndex.

    som trainOne: input atTime: 0.

    after := som weights at: bmuIndex.

    self assert:
        ((self distanceSquaredFrom: after to: input)
            < (self distanceSquaredFrom: before to: input))
        description: 'BMU weight should move closer to the input after one training step'
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testTrainOneMovesWinnerMoreThanFarNeuron [
	"The BMU must move more than a far-away neuron for the same input,
     otherwise the neighborhood function is wrong or not used."

	| input beforeWeights bmuIndex winnerDelta farIndex farDelta |
	input := #(0.5 0.5) asArray.
	beforeWeights := self copyWeights.

	bmuIndex := som bestMatchingUnitIndexFor: input.	"Pick a far neuron: here index 1 is typically a corner far from center BMUs."
	farIndex := 1.

	som trainOne: input atTime: 0.

	winnerDelta := self
			distanceSquaredFrom: (beforeWeights at: bmuIndex)
			to: (som weights at: bmuIndex).
	farDelta := self
			distanceSquaredFrom: (beforeWeights at: farIndex)
			to: (som weights at: farIndex).

	self
		assert: winnerDelta > farDelta
		description: 'BMU must be updated more strongly than a far neuron'
]

{ #category : #'as yet unclassified' }
KohonenSomTest >> testTrainingReducesQuantizationErrorOnSimpleDataset [
	"On a tiny 2D dataset, overall quantization error should decrease after training.
     This falsifies globally broken training loops (trainOn:, neighborhood, learning rate)."

	| data before after |
	data := {#(0.0 0.0) asArray.
			#(1.0 1.0) asArray}.

	before := self quantizationErrorFor: data.
	som trainOn: data.
	after := self quantizationErrorFor: data.

	self
		assert: after < before
		description: 'Quantization error should decrease after training on a simple dataset'
]

{ #category : #tests }
KohonenSomTest >> testWeightsChangeAfterTraining [
	| data before after |
	som := KohonenSom new
			initializeWithInputDimension: 2
			width: 3
			height: 3
			iterations: 20.

	data := #(#'{' 0.0 #'.' 0.0 #'}' #'{' 1.0 #'.' 1.0 #'}') collect: #asArray.
	before := som weights collect: [ :w | w collect: [ :v | v ] ].

	som trainOn: data.
	after := som weights.

	self deny: before = after
]
