###

  Ellipse

###

tools.rectangle = new ArbitraryShapeTool
  id: "rectangle"
  template: "M-0.1,-0.1 L0.1,-0.1 L0.1,0.1 L-0.1,0.1 L-0.1,-0.1z"
  virgin: -> new Rect
    x: -0.1
    y: -0.1
    width: 0.2
    height: 0.2

  hotkey: 'M'
