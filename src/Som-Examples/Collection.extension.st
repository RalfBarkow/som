Extension { #name : #Collection }

{ #category : #'*Som-Examples' }
Collection >> gtScatter2DOn: aView [
    <gtView>
    ^ aView mondrian
        title: '2D Input Space';
        painting: [ :m |

            "1. Each node is a small dot"
            m nodes
                shape: [ :p |
                    BlElement new
                        size: 4 @ 4;
                        geometry: BlEllipseGeometry new;
                        background: Color blue;
                        yourself ];
                with: self.]

]
