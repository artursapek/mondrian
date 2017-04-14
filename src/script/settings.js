/*

  Settings

  Production/development-dependent settings

  Meowset is Mondrian's backend server.

*/

const SETTINGS = {};
  // Flag: are we in production?

SETTINGS.PRODUCTION = (/mondrian/.test(document.location.host));

SETTINGS.MEOWSET = {
  // Show UI for backend features?
  // TODO implement
  AVAILABLE: true,
  // Backend endpoint
  ENDPOINT: SETTINGS.PRODUCTION ? "http://meowset.mondrian.io" : "http://localhost:8000"
};

SETTINGS.BONITA =
  // New replacement app backend for Meowset
  {ENDPOINT: SETTINGS.PRODUCTION ? "http://bonita.mondrian.io" : "http://localhost:8080"};

SETTINGS.EMBED = {
  AVAILABLE: true,
  ENDPOINT: SETTINGS.PRODUCTION ? "http://embed.mondrian.io" : "http://localhost:8000"
};

  // Maths
SETTINGS.MATH = {
  POINT_DECIMAL_PLACES: 5,
  POINT_ROUND_DGAF: 1e-5
};
  // Cursor
SETTINGS.DOUBLE_CLICK_THRESHOLD = 600;

SETTINGS.DRAG_THRESHOLD = 3;

