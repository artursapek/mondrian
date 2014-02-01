
testData = '''
           <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
              width="26px" height="28px" viewBox="0 0 26 26" enable-background="new 0 0 26 26" xml:space="preserve">
           <path fill="#454545" d="M8.125,17.874c0.447,0.447,1.201,0.425,1.674-0.048l8.027-8.027c0.474-0.474,0.495-1.227,0.048-1.674
             c-0.446-0.447-1.199-0.425-1.675,0.049L8.175,16.2C7.7,16.675,7.678,17.428,8.125,17.874z M12.108,17.142
             c0.116,0.228,0.177,0.487,0.177,0.755c0,0.446-0.171,0.863-0.482,1.175l-4.149,4.147C7.344,23.53,6.926,23.7,6.479,23.7
             c-0.447,0-0.864-0.171-1.175-0.481L2.78,20.696c-0.311-0.312-0.482-0.729-0.482-1.178c0-0.447,0.172-0.863,0.482-1.174l4.148-4.149
             c0.311-0.311,0.729-0.483,1.176-0.483c0.268,0,0.525,0.063,0.754,0.18l1.659-1.66c-0.708-0.543-1.56-0.816-2.413-0.816
             c-1.015,0-2.03,0.385-2.799,1.156L1.155,16.72c-1.541,1.54-1.541,4.061,0,5.602l2.522,2.522C4.449,25.614,5.462,26,6.479,26
             c1.015,0,2.031-0.386,2.801-1.156l4.147-4.146c1.418-1.418,1.53-3.664,0.338-5.215L12.108,17.142z M24.843,3.679l-2.521-2.523
             C21.551,0.385,20.535,0,19.521,0c-1.016,0-2.031,0.385-2.802,1.155l-4.148,4.148c-1.417,1.417-1.529,3.664-0.339,5.214l1.66-1.659
             c-0.116-0.229-0.179-0.486-0.179-0.754c0-0.447,0.172-0.865,0.481-1.176l4.149-4.148c0.311-0.311,0.728-0.482,1.177-0.482
             c0.446,0,0.863,0.172,1.176,0.482l2.521,2.523C23.53,5.614,23.7,6.032,23.7,6.479c0,0.447-0.171,0.866-0.481,1.176l-4.147,4.147
             c-0.312,0.312-0.729,0.482-1.175,0.482c-0.27,0-0.524-0.062-0.755-0.178l-1.659,1.659c0.708,0.544,1.561,0.816,2.414,0.816
             c1.016,0,2.028-0.384,2.801-1.156l4.146-4.148C26.385,7.74,26.385,5.219,24.843,3.679z"/>
           </svg>
           '''

svgObject = new SVG(testData)

window.png = pngObject = new PNG(svgObject)

listOfElems = svgObject.elements

svgObjectFromElems = new SVG listOfElems

new Test 'SVG elem should parse its own width', (->
  svgObject.metadata.width), 26

new Test 'SVG elem should parse its own height', (->
  svgObject.metadata.height), 28

new Test 'SVG elem should have 1 element', (->
  svgObject.elements.length), 1

new Test 'SVG\'s elem should be a Path', (->
  svgObject.elements[0].type), 'path'

new Test 'PNG.export', (->
  pngObject.export()), 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAcCAYAAAB/E6/TAAACD0lEQVRIS72V3W3CMBSFMYJ3Nmg2KGyQCnguTFA6QekE0AlKJyidoOEZUJMJygaFDeg7Ij0nspFjnBAnqJas/Nn387n3OBa1K7Rutzuo1+sThGqjb9Dny+XyTQ8tqnL6/f4cMR4scQh7VO8rgXRIHMcLBJ2hj4UQ9xJwgpUGGUo+sPqRWr3xLYGVAuVBbDCofXYGAcL0PMmAKSVmnXq9XiDTuHECAUJXfReBcIx04yfvnUBY4RQrnCAVu9Vq5TGA7/stXFphGG5zFEWlQAgYocA+FQL6RcDhcOjoML2Ox+Nx6AryEZN557VGCO5buP4C5AG053ubWZxAMlVes9lk8BOEYCjkH8EKya2RTIvaeBFqEspASbqUkiKQTJBhYaaIqWnblCAInUi70xSJQdDObH+WOuO3ssOK6aaxWRMqwQJauCZm0Nob0piM11sKlLXjlbts6YLlfQRkr+F7oGqVCXKBUImqmRkw6zlRlAXhZmw0Gj+6EgxnTd4Bu3OBCf03YRYRIA+gxLbKXVgUn28BegFoWliRNnGBiQNzImF4t1ebETXZAnpTBhRLR11MhZHiTlbhbSqFpiiAomFWKgyI1cJ5aRRIBY/eVzkodc6riUUOuku1srkuBbsGJDGTbdUodID3c/QR1CqD5J6mhRRlpEifWwmSUqSiypqNuFfQIxxas/V6TYWVmvN5VJb2b6A/ZmRufCqUZKUAAAAASUVORK5CYII='


