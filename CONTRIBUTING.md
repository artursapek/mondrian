## Contributing

Editors like Inkscape and Adobe Illustrator tower over Mondrian in their features and abilities.
While a big goal in Mondrian is to avoid feature creep and keep it visually bare, it's definitely
still missing a lot. Contributors are encouraged to develop new tools and utilities they feel are missing
as well as optimizing the performance of those that already exist.

All significant contributions will get credit under the "About" menu within the app.

### Do

- Follow the 15 minute rule. If you can't figure something out after 15 minutes,
contact Artur at [me@artur.co](mailto:me@artur.co) with your confusion.
Make sure to be clear about what you don't understand. Help me help you!


### Don't

- Track new files in the /build directory unless instructed.


### Todo

If you want to contribute, there's a lot that can be done to help move the project forward.
Check the issues for bugs and feature requests, or you can pick something off of this laundry list:

- Set up a good unit test suite with Phantomjs or another headless browser
- Add support for missing SVG elements
  - Quadratic bezier (convert to cubic with two matching control points)
  - Elliptical arc
- More file format import/export abilities (will probably require converter on backend)
  - PDF
  - AI
- Refactor the monolithic `ui/ui.coffee` into smaller files
  - UI states
  - Mouse event routing
  - Tool management
- Clean up hacks and rushed features
- Pathfinder shape manipulation (union, subtraction, overlap)
- More tools for manipulating bezier curvers
- Guide lines, a more solid grid system
- Responsive layout for smaller screens

However feel free to open Pull Requests dealing with any part of the app. It's a fun project in general.
