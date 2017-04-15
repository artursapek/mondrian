/*

  Setup

  Bind $(document).ready
  Global exports

*/

window.appLoaded = false;

let setup = [];

// For state preservation, run setup functions
// after everything is initialized with the DOM
let secondRoundSetup = [];

$(document).ajaxSend(() => ui.logo.animate());

$(document).ajaxComplete(() => ui.logo.stopAnimating());

$(document).ready(function() {
  for (var procedure of Array.from(setup)) {
    procedure();
  }

  window.appLoaded = true;

  for (procedure of Array.from(secondRoundSetup)) {
    procedure();
  }

  // Make damn sure the window isnt off somehow because
  // they wont be able to undo it
  return setTimeout(() => window.scrollTo(0, 0)
  , 500);
});

export default setup;
