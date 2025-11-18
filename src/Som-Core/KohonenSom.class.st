Class {
	#name : #KohonenSom,
	#superclass : #Object,
	#instVars : [
		'inputDimension',
		'width',
		'height',
		'weights',
		'maxIterations',
		'iterationCount',
		'initialLearningRate',
		'initialRadius',
		'learningTimeConstant',
		'radiusTimeConstant',
		'zoomFactor'
	],
	#category : #'Som-Core'
}

{ #category : #training }
KohonenSom >> bestMatchingUnitIndexFor: inputVector [
    "Return the index of the weight vector closest to inputVector."
    
    | bestIndex bestDistance |
    bestIndex := nil.
    bestDistance := nil.
    1 to: weights size do: [ :i |
        | d |
        d := self distanceSquaredBetween: (weights at: i) and: inputVector.
        (bestDistance isNil or: [ d < bestDistance ]) ifTrue: [
            bestDistance := d.
            bestIndex := i ] ].
    ^ bestIndex
]

{ #category : #metrics }
KohonenSom >> distanceSquaredBetween: v1 and: v2 [
    "Squared Euclidean distance between two vectors (Arrays of numbers)."
    
    | sum |
    sum := 0.0.
    1 to: inputDimension do: [ :k |
        | d |
        d := (v1 at: k) - (v2 at: k).
        sum := sum + (d * d) ].
    ^ sum
]

{ #category : #geometry }
KohonenSom >> gridDistanceSquaredFrom: p1 to: p2 [
    "Squared Euclidean distance on the neuron grid."
    
    | dx dy |
    dx := p1 x - p2 x.
    dy := p1 y - p2 y.
    ^ (dx * dx) + (dy * dy)
]

{ #category : #'as yet unclassified' }
KohonenSom >> gtJsonFor: aView [
	<gtView>
	^ aView forward
		title: 'weightsAsPoints2D';
		object: [ self weightsAsPoints2D asGtJson ];
		view: #gtJsonObjectFor:context:
]

{ #category : #'as yet unclassified' }
KohonenSom >> gtWeightVectorsInInputSpaceOn: aView [
	<gtView>
	^ aView explicit
		title: 'Codebook Scatter';
		stencil: [ :presentation | 
			| root scaledPoints |
			root := BlElement new
					size: 600 @ 600;
					background: Color white;
					yourself.

			scaledPoints := self weightsAsPoints2DScaledBy: self zoomFactor.

			scaledPoints
				do: [ :p "p is a scaled Point in pixel space" | 
					| dot |
					dot := BlElement new
							size: 12 @ 12;
							geometry: BlEllipseGeometry new;
							background: Color blue;
							relocate: p;
							yourself.
					root addChild: dot ].

			root ]
]

{ #category : #'gt-views' }
KohonenSom >> gtWeightsOn: aView [
	<gtView>
	^ aView forward
		title: 'Weights';
		object: [ weights ]
]

{ #category : #'as yet unclassified' }
KohonenSom >> gtZoomOn: aView [
    <gtView>
    ^ aView text
        title: 'Zoom factor';
        priority: 5;
        text: [ self zoomFactor asString ]

]

{ #category : #accessing }
KohonenSom >> height [
    ^ height
]

{ #category : #initialization }
KohonenSom >> initializeRandomWeights [
    "Initialize all weight vectors with random values in [0, 1]."
    
    | numberOfNeurons |
    numberOfNeurons := width * height.
    weights := Array new: numberOfNeurons.
    1 to: numberOfNeurons do: [ :i |
        weights
            at: i
            put: (Array new: inputDimension
                streamContents: [ :stream |
                    1 to: inputDimension do: [ :k |
                        stream nextPut: (Random new next) ] ]) ]
]

{ #category : #initialization }
KohonenSom >> initializeWithInputDimension: anInteger width: aWidth height: aHeight iterations: totalIterations [
    inputDimension := anInteger.
    width := aWidth.
    height := aHeight.
    maxIterations := totalIterations.
    iterationCount := 0.
    initialLearningRate := 0.1.
    initialRadius := (width max: height) / 2.0.
    learningTimeConstant := maxIterations asFloat / 2.0.
    radiusTimeConstant := maxIterations asFloat / (initialRadius ln).
    self initializeRandomWeights.
    ^ self
]

{ #category : #accessing }
KohonenSom >> inputDimension [
    ^ inputDimension
]

{ #category : #training }
KohonenSom >> learningRateAtTime: t [
    "Exponential decay of the learning rate.
    t is zero-based iteration index."
    
    ^ initialLearningRate * (Float e raisedTo: (t negated / learningTimeConstant))
]

{ #category : #accessing }
KohonenSom >> maxIterations [
	"Answer the configured number of training iterations.
     This is used by tests and examples for radius decay, etc."

	^ maxIterations
]

{ #category : #training }
KohonenSom >> neighborhoodInfluenceAtTime: t winnerIndex: winnerIndex neuronIndex: neuronIndex [
    "Gaussian neighborhood h_ci(t) in the neuron grid."
    
    | sigma2 dist2 |
    sigma2 := (self radiusAtTime: t) squared.
    sigma2 = 0 ifTrue: [ ^ 0 ].
    dist2 := self
        gridDistanceSquaredFrom: (self positionOfIndex: winnerIndex)
        to: (self positionOfIndex: neuronIndex).
    ^ Float e raisedTo: (dist2 negated / (2.0 * sigma2))
]

{ #category : #geometry }
KohonenSom >> positionOfIndex: index [
    "Return the 2D grid coordinates (x @ y) for a 1-based linear index."
    
    | zeroBased x y |
    zeroBased := index - 1.
    x := (zeroBased \\ width).
    y := (zeroBased // width).
    ^ x @ y
]

{ #category : #training }
KohonenSom >> radiusAtTime: t [
    "Exponential decay of the neighborhood radius."
    
    ^ initialRadius * (Float e raisedTo: (t negated / radiusTimeConstant))
]

{ #category : #'as yet unclassified' }
KohonenSom >> scaledWeightsAsPoints2DForCanvas: canvasExtent [
	"Return points scaled so that *all* weightsAsPoints2D fit
	 into a rectangle 0@0 corner: canvasExtent, with a small margin."

	| pts minX maxX minY maxY spanX spanY scaleX scaleY margin |

	pts := self weightsAsPoints2D.
	pts isEmpty ifTrue: [ ^ #() ].

	"Find bounding box in input space"
	minX := maxX := pts first x.
	minY := maxY := pts first y.
	pts do: [ :p |
		minX := minX min: p x.
		maxX := maxX max: p x.
		minY := minY min: p y.
		maxY := maxY max: p y ].

	spanX := (maxX - minX) max: 1e-6.
	spanY := (maxY - minY) max: 1e-6.

	margin := 10.  "pixels"

	scaleX := (canvasExtent x - (2 * margin)) / spanX.
	scaleY := (canvasExtent y - (2 * margin)) / spanY.

	^ pts collect: [ :p |
		| nx ny |
		nx := margin + (p x - minX) * scaleX.
		ny := margin + (p y - minY) * scaleY.
		nx @ ny ]

]

{ #category : #'batch-training' }
KohonenSom >> trainBatchOn: aCollection iterations: batchIterations [
    "Skeleton for the Batch Map algorithm (Sec. 3.14).
    For now, this just calls the online trainer; fill with
    the true batch algorithm later."
    
    ^ self trainOn: aCollection
]

{ #category : #training }
KohonenSom >> trainOn: aCollection [
    "Train the SOM for maxIterations iterations, cycling through aCollection."
    
    1 to: maxIterations do: [ :t |
        | index input |
        index := ((t - 1) \\ aCollection size) + 1.
        input := aCollection at: index.
        self trainOne: input atTime: t - 1 ].
    ^ self
]

{ #category : #training }
KohonenSom >> trainOne: inputVector atTime: t [
    "Perform one SOM update step for a single input vector."
    
    | eta winner radius |
    eta := self learningRateAtTime: t.
    winner := self bestMatchingUnitIndexFor: inputVector.
    radius := self radiusAtTime: t.  "not used directly but makes intent explicit"
    
    1 to: weights size do: [ :i |
        | h |
        h := self
            neighborhoodInfluenceAtTime: t
            winnerIndex: winner
            neuronIndex: i.
        self
            updateNeuronAt: i
            withInput: inputVector
            learningRate: eta
            neighborhoodInfluence: h ].
    
    iterationCount := iterationCount + 1
]

{ #category : #training }
KohonenSom >> updateNeuronAt: neuronIndex
    withInput: inputVector
    learningRate: eta
    neighborhoodInfluence: h [
    "Apply Kohonen update: m_i <- m_i + eta * h * (x - m_i)."
    
    | w |
    h = 0 ifTrue: [ ^ self ].
    w := weights at: neuronIndex.
    1 to: inputDimension do: [ :k |
        | old delta |
        old := w at: k.
        delta := eta * h * ((inputVector at: k) - old).
        w at: k put: old + delta ]
]

{ #category : #accessing }
KohonenSom >> weights [
    ^ weights
]

{ #category : #converting }
KohonenSom >> weightsAsPoints2D [
    "Return a collection of Points for 2D SOMs (first two components)."
    
    ^ weights collect: [ :w |
        (w size >= 2)
            ifTrue: [ (w first) @ (w second) ]
            ifFalse: [ 0 @ 0 ] ]
]

{ #category : #'as yet unclassified' }
KohonenSom >> weightsAsPoints2DScaledBy: factor [
	"Simple zoom: multiply all coordinates by a scalar.
     Assumes weightsAsPoints2D answers Points (x@y)."

	| pts |
	pts := self weightsAsPoints2D.
	pts isEmpty ifTrue: [ ^ #() ].

	^ pts collect: [ :p | p * factor ]
]

{ #category : #accessing }
KohonenSom >> width [
    ^ width
]

{ #category : #accessing }
KohonenSom >> zoomFactor [
	^ zoomFactor ifNil: [  "default zoom"zoomFactor := 600.0 ]
]

{ #category : #accessing }
KohonenSom >> zoomFactor: aNumber [
	zoomFactor := (aNumber max: 0.01) asFloat	"avoid zero / negative"
]
