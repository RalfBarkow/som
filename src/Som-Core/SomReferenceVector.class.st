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
    ^ gridPosition

]

{ #category : #accessing }
SomReferenceVector >> gridPosition: aPoint [
    gridPosition := aPoint

]

{ #category : #accessing }
SomReferenceVector >> index [
    ^ index

]

{ #category : #accessing }
SomReferenceVector >> index: anInteger [
    index := anInteger

]

{ #category : #accessing }
SomReferenceVector >> point2D [
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
    ^ weight

]

{ #category : #accessing }
SomReferenceVector >> weight: anArray [
    weight := anArray

]
