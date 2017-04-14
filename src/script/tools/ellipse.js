import tools from 'script/tools/tools';
import Tool from 'script/tools/tool';
import ArbitraryShapeTool from 'script/tools/arbitrary-shape';
/*

  Ellipse

*/

tools.ellipse = new ArbitraryShapeTool({
  id: "ellipse",
  template: "M0-0.1c0.055228,0,0.1,0.045,0.1,0.1S0.055,0.1,0,0.1S-0.1,0.055-0.1,0S-0.055-0.1,0-0.1z",
  virgin() { return new Ellipse({
    cx: 0.0,
    cy: 0.0,
    rx: 0.1,
    ry: 0.1
  }); },

  hotkey: 'L'
});
