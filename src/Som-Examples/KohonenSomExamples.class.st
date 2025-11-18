Class {
	#name : #KohonenSomExamples,
	#superclass : #Object,
	#category : #'Som-Examples'
}

{ #category : #'gt-examples' }
KohonenSomExamples class >> bmuExactMatchExample [
	"Mirror of testBestMatchingUnitSelectsExactMatch.
     One neuron weight equals input, all others are far away.
     Inspect to see the chosen BMU index."

	<gtExample>
	| som input far |
	som := self smallSom.
	input := #(0.0 0.0) asArray.
	far := #(10.0 10.0) asArray.

	1 to: som weights size do: [ :i | som weights at: i put: far copy ].
	som weights at: 1 put: input copy.

	^ {#input -> input.
		#weights -> som weights.
		#bmuIndex -> (som bestMatchingUnitIndexFor: input)} asDictionary
]

{ #category : #'as yet unclassified' }
KohonenSomExamples class >> exampleInputSpace2D [
	"Generate random 2D input samples and visualize them."

	<gtExample>
	| data |
	data := (1 to: 500) collect: [ :i | Random new next @ Random new next ].

	^ data
]

{ #category : #examples }
KohonenSomExamples class >> exampleUnitSquare2D [
	"Train a small SOM on random points in the unit square."

	<gtExample>
	| data som numberOfSamples |
	numberOfSamples := 500.
	data := (1 to: numberOfSamples)
			collect: [ :i | 
				{Random new next.
					Random new next} asArray ].

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
	"Return a collection of Points representing weight vectors in 2D."

	<gtExample>
	| som coords |
	som := self exampleUnitSquare2D.
	coords := som weights
			collect: [ :w | w size >= 2 ifTrue: [ w first @ w second ] ifFalse: [ 0 @ 0 ] ].
	^ coords
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> gaussianNeighborhoodProfileExample [
	"Mirror of testNeighborhoodInfluenceIsMaxAtWinnerAndDecreasesWithGridDistance.
     Assumes a 3x3 grid with indices:
       1 2 3
       4 5 6
       7 8 9
     Winner = 5 (center), neighbor = 2, far = 1."

	<gtExample>
	| som winnerIndex neighborIndex farIndex hWinner hNeighbor hFar |
	som := self smallSom.
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
			neuronIndex: farIndex.

	^ {#winnerIndex -> winnerIndex.
		#neighborIndex -> neighborIndex.
		#farIndex -> farIndex.
		#hWinner -> hWinner.
		#hNeighbor -> hNeighbor.
		#hFar -> hFar} asDictionary
]

{ #category : #helpers }
KohonenSomExamples class >> meanQuantizationErrorFor: aSom on: dataCollection [
	| total |
	total := 0.0.
	dataCollection
		do: [ :input | 
			| bmuIndex w |
			bmuIndex := aSom bestMatchingUnitIndexFor: input.
			w := aSom weights at: bmuIndex.
			total := total + (self squaredDistanceFrom: w to: input) ].
	^ total / dataCollection size asFloat
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> quantizationErrorBeforeAfterTrainingExample [
	"Mirror of testTrainingReducesQuantizationErrorOnSimpleDataset.
     Inspect to see before and after quantization errors."

	<gtExample>
	| som data before after |
	som := self smallSom.
	data := {#(0.0 0.0) asArray.
			#(1.0 1.0) asArray}.

	before := self meanQuantizationErrorFor: som on: data.
	som trainOn: data.
	after := self meanQuantizationErrorFor: som on: data.

	^ {#data -> data.
		#beforeError -> before.
		#afterError -> after} asDictionary
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> radiusDecayExample [
	"Mirror of testRadiusDecaysOverTime.
     Inspect to see radius at start, mid and end."

	<gtExample>
	| som r0 mid rMid rEnd |
	som := self smallSom.
	r0 := som radiusAtTime: 0.
	mid := som maxIterations // 2.
	rMid := som radiusAtTime: mid.
	rEnd := som radiusAtTime: som maxIterations - 1.

	^ {#r0 -> r0.
		#midIteration -> mid.
		#rMid -> rMid.
		#rEnd -> rEnd} asDictionary
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> smallSom [
	"A small 3x3 SOM with 2D input, as used in the tests."

	<gtExample>
	^ KohonenSom new
		initializeWithInputDimension: 2
		width: 3
		height: 3
		iterations: 100
]

{ #category : #helpers }
KohonenSomExamples class >> squaredDistanceFrom: v1 to: v2 [
	"Simple Euclidean squared distance for Collections of numbers."

	^ (v1 with: v2 collect: [ :a :b | (a - b) squared ]) sum
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> trainOneMovesBmuTowardsInputExample [
	"Mirror of testTrainOneMovesBestMatchingUnitTowardsInput.
     Inspect before and after distances to see that the BMU moved closer."

	<gtExample>
	| som input bmuIndex beforeVector afterVector beforeDist afterDist |
	som := self smallSom.
	input := #(0.2 0.8) asArray.

	bmuIndex := som bestMatchingUnitIndexFor: input.
	beforeVector := (som weights at: bmuIndex) copy.
	beforeDist := self squaredDistanceFrom: beforeVector to: input.

	som trainOne: input atTime: 0.

	afterVector := som weights at: bmuIndex.
	afterDist := self squaredDistanceFrom: afterVector to: input.

	^ {#input -> input.
		#bmuIndex -> bmuIndex.
		#beforeVector -> beforeVector.
		#afterVector -> afterVector.
		#beforeDistanceSquared -> beforeDist.
		#afterDistanceSquared -> afterDist} asDictionary
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> trainOneNeighborhoodMovementExample [
	"Mirror of testTrainOneMovesWinnerMoreThanFarNeuron.
     Inspect the deltas of winner versus far neuron."

	<gtExample>
	| som input bmuIndex farIndex beforeWeights winnerDelta farDelta |
	som := self smallSom.
	input := #(0.5 0.5) asArray.

	bmuIndex := som bestMatchingUnitIndexFor: input.
	farIndex := 1.

	beforeWeights := som weights collect: [ :w | w collect: [ :v | v ] ].

	som trainOne: input atTime: 0.

	winnerDelta := self
			squaredDistanceFrom: (beforeWeights at: bmuIndex)
			to: (som weights at: bmuIndex).
	farDelta := self
			squaredDistanceFrom: (beforeWeights at: farIndex)
			to: (som weights at: farIndex).

	^ {#input -> input.
		#bmuIndex -> bmuIndex.
		#farIndex -> farIndex.
		#winnerDeltaSquared -> winnerDelta.
		#farDeltaSquared -> farDelta} asDictionary
]

{ #category : #'gt-examples' }
KohonenSomExamples class >> weightsCollectionSizeExample [
	"Mirror of testWeightsCollectionHasCorrectSize.
     Inspect to see width, height and weights size."

	<gtExample>
	| som |
	som := self smallSom.
	^ {#width -> som width.
		#height -> som height.
		#expectedNeuronCount -> (som width * som height).
		#actualWeightsSize -> som weights size} asDictionary
]
