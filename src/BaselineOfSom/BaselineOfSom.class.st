Class {
	#name : #BaselineOfSom,
	#superclass : #BaselineOf,
	#category : #BaselineOfSom
}

{ #category : #baseline }
BaselineOfSom >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Som'
		]
]
