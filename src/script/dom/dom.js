import setup from 'script/setup';
/*

  Commonly accessed DOM elements

*/

let dom = {

  setup() {
    this.$body = $('body');
    this.body = this.$body[0];

    this.$main = $('#main');
    this.main = this.$main[0];

    this.$ui = $('#ui');
    this.ui = this.$ui[0];

    this.$bg = $('#bg');
    this.bg = this.$bg[0];

    this.$annotations = $('#annotations');
    this.annotations = this.$annotations[0];

    this.$hoverTargets = $('#hover-targets');
    this.hoverTargets = this.$hoverTargets[0];

    this.$grid = $('#grid');
    this.grid = this.$grid[0];

    this.$utilities = $('#utilities');
    this.utilities = this.$utilities[0];

    this.$selectionBox = $('#selection-box');
    this.selectionBox = this.$selectionBox[0];

    this.$dragSelection = $('#drag-selection');
    this.dragSelection = this.$dragSelection[0];

    this.$menuBar = $('#menu-bar');
    this.menuBar = this.$menuBar[0];

    this.$currentSwatches = $('#current-swatches');
    this.currentSwatches = this.$currentSwatches[0];

    this.$toolPalette = $('#tool-palette');
    this.toolPalette = this.$toolPalette[0];

    this.$toolCursorPlaceholder = $('#tool-cursor-placeholder');
    this.toolCursorPlaceholder = this.$toolCursorPlaceholder[0];

    this.$canvas = $('#canvas');
    this.canvas = this.$canvas[0];

    this.$logoLeft = $("#logo #left-bar");
    this.$logoMiddle = $("#logo #middle-bar");
    this.$logoRight = $("#logo #right-bar");
    this.logoLeft = this.$logoLeft[0];
    this.logoMiddle = this.$logoMiddle[0];
    this.logoRight = this.$logoRight[0];

    this.$filename = $("#filename-menu");
    this.filename = this.$filename[0];

    this.$login = $("#login-mg");
    this.login = this.$login[0];

    this.$tmpPaste = $('#tmp-paste');
    this.tmpPaste = this.$tmpPaste[0];

    this.$pngSandbox = $('#png-download-sandbox');
    this.pngSandbox = this.$pngSandbox[0];

    this.$currentService = $('#current-service');
    this.currentService = this.$currentService[0];

    this.$serviceLogo = $('.service-logo');
    this.serviceLogo = this.$serviceLogo[0];

    this.$serviceGallery = $('#service-file-gallery');
    this.serviceGallery = this.$serviceGallery[0];

    this.$serviceGalleryThumbs = $('#service-file-gallery-thumbnails');
    this.serviceGalleryThumbs = this.$serviceGalleryThumbs[0];

    this.$serviceBrowser = $('#service-file-browser');
    this.serviceBrowser = this.$serviceBrowser[0];

    this.$registerButton = $('#register-mg');
    this.registerButton = this.$registerButton[0];

    this.$dialogTitle = $("#dialog-title");
    return this.dialogTitle = this.$dialogTitle[0];
  }
};

export default dom;

setup.push(() => dom.setup());
