# Setup

p1 = new Posn(10, 20)
p2 = new Posn(50, 50)
p3 = new Posn(56.375, 920.505)
p4 = new Posn(78.2, 2.4)

poly1 = new Polynomial([-8556.40625, 9786.5625, 1565.765625, -1798.09375])
poly2 = new Polynomial([-8556.40625, 9786.5625, 1565.765625, -1798.09375])
poly3 = new Polynomial([-2521.40325, 2015.7625, -2298.04175])

hugepoly = new Polynomial([
  819552855133368,
  -4059695028789612,
  9135238247204166,
  -11299205179679670,
  7817505757508070,
  -2752582173072824,
  -184979604186062.2,
  759898652221607.1,
  -250714946036920.75,
  6934793103614.088
])

blob1 = new Path(
  d: """M207.337,68.753c-39.326,19.102-65.168,95.506-47.191,106.742
        s78.652,53.933,104.495,28.09s47.191-133.708,30.337-134.832
        S207.337,68.753,207.337,68.753z"""
)
blob2 = new Path(
  d: """M346.664,158.641c-50.562-8.989-113.483-30.336-123.596-7.865
s-27.439,21.987-9.787,54.252s54.731,79.456,69.338,65.973S346.664,158.641,346.664,158.641z"""
)

ln1 = new LineSegment(new Posn(0,0), new Posn(100,100))
ln110 = new LineSegment(new Posn(0,0), new Posn(100,110))
ln2 = new LineSegment(new Posn(0,100), new Posn(100,0))
ln3 = new LineSegment(new Posn(47.354,107.08), new Posn(133.065,161.985))
ln4 = new LineSegment(new Posn(29.541,146.268), new Posn(150.459,120.072))
ln5 = new LineSegment(new Posn(315, 309), new Posn(315, 228))
ln6 = new LineSegment(new Posn(350, 170), new Posn(400, 250))
ln7 = new LineSegment(new Posn(145.5, 58), new Posn(193.375, 23.125))
ln8 = new LineSegment(new Posn(148.5, 19.625), new Posn(198.375, 58.875))

bz = new CubicBezier(new Posn(0,50), new Posn(200,150), new Posn(100, 50), new Posn(50,50))
bz1 = new CubicBezier(new Posn(400, 200), new Posn(300, 185), new Posn(265, 230), new Posn(285, 250))
bz2 = new CubicBezier(new Posn(154, 14.25), new Posn(138.25, 36.625), new Posn(230.625, 48.375), new Posn(165.875, 64))
# These two intersect twice:
bz3 = new CubicBezier(new Posn(0, 0), new Posn(66.368, 66.368), new Posn(113.769, 70.044), new Posn(183.813, 0))
bz4 = new CubicBezier(new Posn(0, 76.746), new Posn(70.043, 6.702), new Posn(117.444, 10.378), new Posn(183.813, 76.746))
# So do these two:
bz5 = new CubicBezier(new Posn(20, 91.738), new Posn(59.5, 168.738), new Posn(107, -100.762), new Posn(107, 91.738))
bz6 = new CubicBezier(new Posn(46.148, 91.882), new Posn(78.648, 174.382), new Posn(69.648, -66.618), new Posn(88.148, 49.882))

bz7 = new CubicBezier(new Posn(583.4471131233216,244), new Posn(507.81821773433853,338), new Posn(670.0103920088109,183), new Posn(618.9836028774718,267))
bz8 = new CubicBezier(new Posn(577,246), new Posn(754,248), new Posn(446,267), new Posn(594,267))

bz9 = new CubicBezier(new Posn(537, 89), new Posn(479, 126), new Posn(477, 206), new Posn(557, 166))
bz10 = new CubicBezier(new Posn(517, 168), new Posn(536, 211), new Posn(472, 241), new Posn(463, 183))

ell1 = new Ellipse(
  cx: 100,
  cy: 100,
  rx: 50,
  ry: 60)

pth1 = new Path(
  stroke: '#F179AF'
  fill: 'none'
  d: "M0,0C80-80,200-85,300,0S165,125 165,130L0,0")


# Tests

new Test('Posn reflection',
  (-> p1.reflect(p2)), new Posn(90, 80))

new Test('Posn reflection',
  (-> p2.reflect(p1)), new Posn(-30, -10))

new Test('Posn reflection',
  (-> p1.reflect(p1)), p1)

new Test('Posn linear interpolation',
  (-> p2.lerp(p3, 0.5)), new Posn(53.1875, 485.2525))

new Test('Posn linear interpolation (lerp)',
  (-> p1.lerp(p2, 0.8)), new Posn(42, 44))

new Test('Posn add to Posn',
  (-> p1.add(p2)), new Posn(60, 70))

new Test('Posn add to Posn',
  (-> p2.add(p1)), new Posn(60, 70))

new Test('Posn add to Posn',
  (-> p2.add(p3)), new Posn(106.375, 970.505))

#  new Test('Push Posn after Posn into PointsList',
#    (-> new PointsList([p1,p2,p4]).push(p3, p4)), new PointsList([p1,p2,p3,p4]))

new Test('Push Posn into end of PointsList',
  (-> new PointsList([p1,p2,p4]).push(p3)), new PointsList([p1,p2,p4,p3]))

new Test('Validate links in PointsList after push',
  (-> new PointsList([p1,p2,p4]).push(p3).firstSegment.validateLinks()), true)

new Test('PointsList.toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).toString()), "M10,10 L45,60 C100,120 300,350 90,80")

new Test('PointsList.relative().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60)]).relative().toString()), "M10,10 l35,50")

new Test('PointsList.relative().absolute().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60)]).relative().absolute().toString()), "M10,10 L45,60")

new Test('PointsList.relative().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().toString()), "M10,10 l35,50 c55,60 255,290 45,20")

new Test('PointsList.relative().absolute() consistency',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().absolute().toString()), "M10,10 L45,60 C100,120 300,350 90,80")

new Test('PointsList.relative().absolute().relative() consistency',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().absolute().relative().toString()), "M10,10 l35,50 c55,60 255,290 45,20")

pointsSegment = new PointsSegment([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)])

new Test('LineTo.toLineSegment',
  (-> pointsSegment.moveMoveTo(pointsSegment.points[2])), '')

new Test('new Path with mix of absolute and relative turns them absolute',
  (-> new Path(d: 'M10,10l30,40C50,60,70,80,90,100L40,40l50,50').points),
  'M10,10 L40,50 C50,60 70,80 90,100 L40,40 L90,90')

new Test('Cubic polynomial roots',
  (-> poly1.roots()), [1.143019385425934,-0.4284039167874206,0.42915473278220573])

new Test('Cubic Polynomial eval(3)',
  (-> poly2.eval(3)), -140044.703125)

new Test('Cubic Polynomial roots()',
  (-> poly2.roots()), [1.143019385425934, -0.4284039167874206, 0.42915473278220573])

new Test('Cubic Polynomial derivative()',
  (-> poly2.derivative().coefs), [1565.765625, 19573.125, -25669.21875])

new Test('Cubic Polynomial add()',
  (-> poly2.add(poly3).coefs), [-4096.1355, 3581.528125, 7265.159250000001, -8556.40625])

new Test('Cubic Polynomial bisection()',
  (-> poly2.bisection(0, 1)), 0.4291543960571289)

new Test('Cubic Polynomial rootsInterval()',
  (-> poly2.rootsInterval(0, 1)), [0.42915499960917775])

new Test('Huge 10-coefficient Polynomial rootsInterval()',
  (-> hugepoly.rootsInterval(0, 1)), [0.030439317609131572, 0.4865324847206747, 0.9484604318106424])

new Test('Cubic Bezier intersects LineSegment',
  (-> bz.intersectionWithLineSegment(ln1)), [new Posn(89.20468634936002,89.20468634935999),new Posn(50.00000000000004,50)])

new Test('Cubic Bezier intersects LineSegment',
  (-> bz2.intersectionWithLineSegment(ln7)), [new Posn(172.4987019088338,38.33253829617591)])

new Test('Cubic Bezier xRange',
  (-> bz2.xRange()), new Range(152.169, 189.1624))

new Test('Cubic Bezier yRange',
  (-> bz2.yRange()), new Range(14.25, 64))

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz3.intersection(bz4)), [new Posn(47.90415473177786,38.43978101182949), new Posn(135.908264922779,38.30620344719945)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz5.intersection(bz6)), [new Posn(49.00242378510562,98.5357189974139), new Posn(72.06070160020182,60.998066741193696), new Posn(85.49725443971622,34.62459876819878)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz4.intersection(bz6)), [new Posn(76.26664017448732,27.28211939958595), new Posn(83.63548811847966,26.07062056075148)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz7.intersection(bz8)), [new Posn(581.7959971383461,246.0599451520868), new Posn(611.5468559995447,246.8269484357895),
                               new Posn(628.4619186189253,248.10341235722106), new Posn(626.8506058391803,252.40738666580168),
                               new Posn(594.6339715885225,257.48879390700273), new Posn(570.4713158190336,260.85017444139413),
                               new Posn(566.5128682640187,266.6452081770431),new Posn(580.4224295094082,266.93524733161775)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz9.intersection(bz10)), [new Posn(519.8386947286634,176.92274339432637)])

new Test('Cubic Bezier findPercentageOfPoint',
  (-> bz4.findPercentageOfPoint(new Posn(76.2666,27.2822))), 0.4012451171875)

new Test('Cubic Bezier splitAt(0.5)',
  (-> bz4.splitAt(0.5)),
  [new CubicBezier(new Posn(0,76.746), new Posn(35.0215,41.724), new Posn(64.38250000000001,25.131999999999998), new Posn(93.28425000000001,25.591499999999996)),
   new CubicBezier(new Posn(93.28425000000001,25.591499999999996), new Posn(122.186,26.051), new Posn(150.6285,43.562), new Posn(183.813,76.746))])

new Test('Cubic Bezier split at array of 8 points',
  (-> bz7.splitAt([new Posn(581.796,246.06), new Posn(611.5469,246.8269), new Posn(628.462,248.1034), new Posn(626.8506,252.4073),
    new Posn(594.6339,257.4888), new Posn(570.4713,260.8502), new Posn(566.5128,266.6452), new Posn(580.4224,266.9353)])),
 [new CubicBezier(new Posn(583.4471131233216,244), new Posn(583.4471131233216,244), new Posn(583.4471131233216,244), new Posn(580.4224,266.9353)),
  new CubicBezier(new Posn(580.4224,266.9353), new Posn(580.4224,266.9353), new Posn(580.4224,266.9353), new Posn(581.796,246.06)),
  new CubicBezier(new Posn(581.796,246.06), new Posn(577.1272361534001,251.86236572265625), new Posn(573.3991175174485,256.6811900511384), new Posn(570.4713,260.8502)),
  new CubicBezier(new Posn(570.4713,260.8502), new Posn(568.9269994920714,262.951033418894), new Posn(567.6176030414922,264.80763180728394), new Posn(566.5128,266.6452)),
  new CubicBezier(new Posn(566.5128,266.6452), new Posn(552.8234755300266,287.00990433663344), new Posn(573.4200716299288,271.8794306807597), new Posn(594.6339,257.4888)),
  new CubicBezier(new Posn(594.6339,257.4888), new Posn(600.388768892232,253.66825105981948), new Posn(606.1884500827612,249.90638989498956), new Posn(611.5469,246.8269)),
  new CubicBezier(new Posn(611.5469,246.8269), new Posn(623.1194403147066,240.1897686797748), new Posn(631.4839224387921,237.6295916160095), new Posn(628.462,248.1034)),
  new CubicBezier(new Posn(628.462,248.1034), new Posn(628.1275684678864,249.26742641511547), new Posn(627.626792524753,250.63164231257952), new Posn(626.8506,252.4073)),
  new CubicBezier(new Posn(626.8506,252.4073), new Posn(625.3425898571114,255.92451126762697), new Posn(622.7412270743075,260.8142211589726), new Posn(618.9836028774718,267))])


new Test('Cubic Bezier splitAt(0.5)[0].splitAt(0.5)',
  (-> bz4.splitAt(0.5)[0].splitAt(0.5)),
  [new CubicBezier(new Posn(0,76.746), new Posn(17.51075,59.235), new Posn(33.606375,46.3315), new Posn(48.937031250000004,37.863187499999995)),
   new CubicBezier(new Posn(48.937031250000004,37.863187499999995), new Posn(64.26768750000001,29.394875), new Posn(78.83337500000002,25.361749999999997), new Posn(93.28425000000001,25.591499999999996))])

new Test('LineSegment intersects LineSegment',
  (-> ln1.intersection(ln2)), [new Posn(50,50)])

new Test('LineSegment intersects LineSegment',
  (-> ln3.intersection(ln4)), [new Posn(88.56712407541042,133.4804220853847)])

new Test('Path.lineSegments()',
  (-> pth1.lineSegments()), [
    new CubicBezier(new Posn(0,0), new Posn(80, -80), new Posn(200, -85), new Posn(300, 0))
    new CubicBezier(new Posn(300, 0), new Posn(400, 85), new Posn(165, 125), new Posn(165, 130))
    new LineSegment(new Posn(165, 130), new Posn(0,0))
    new LineSegment(new Posn(0,0), new Posn(0,0))
  ])

new Test('Path.lineSegments().map(bounds)',
  (-> pth1.lineSegments().map((x) -> x.bounds())),
  [new Bounds(0, -61.875, 300, 61.875), new Bounds(165, 0, 159.77671875, 130), new Bounds(0, 0, 165, 130), new Bounds(0, 0, 0, 0)])



new Test('Path.bounds()',
  (-> pth1.bounds()),
  [{"x":0,"y":-61.875,"width":324.77671875,"height":191.875,"x2":324.77671875,"y2":130,"xr":{"min":0,"max":324.77671875},"yr":{"min":-61.875,"max":130}}])


new Test('Ellipse primitive coords',
  (-> [ell1.top().x, ell1.top().y, ell1.right().x, ell1.right().y, ell1.bottom().x, ell1.bottom().y, ell1.left().x, ell1.left().y]), [100, 40, 150, 100, 100, 160, 50, 100])

print blob1.points.reverse().toString()




