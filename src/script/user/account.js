/*

  The logged-in account

    strings
      email:         user's email address
      session_token: secret token used to verify their logged-in session

    lists
      services: which services they have access to
                default:
                  'local'
                possibly also:
                  'dropbox'
                  (more to come)

      active:     if they should get full account features
      subscribed: if they actually have an active card on file

*/

ui.account = {

  email: "",
  session_token: "",

  services: ['local'],

  valueOf() { return this.email || "anon"; },

  uiAnonymous() {
    // Hide and disable things not available to anonymous users.
    services.dropbox.tease().disable();
    ui.menu.items.shareAsLink.enable();
    ui.menu.items.downloadSVG.enable();
    ui.menu.menus.login.show();
    return ui.menu.menus.register.show();
  },

  uiLoggedIn() {
    services.dropbox.tease().enable();
    ui.menu.items.shareAsLink.enable();
    ui.menu.items.downloadSVG.enable();
    ui.menu.menus.login.groupHide();
    return ui.menu.menus.account.text(this.email).groupShow();
  },

  checkSession() {
    // See if the user is logged in. If so, set up the UI to reflect that.
    this.session_token = localStorage.getItem("session_token");

    // TODO Hackish. Why is this here?
    if (this.session_token) {
      return $.ajax({
        url: `${SETTINGS.MEOWSET.ENDPOINT}/user/persist-session`,
        type: "POST",
        dataType: "json",
        data: {
          session_token: this.session_token
        },
        success: response => {
          if (response.anon != null) {
            this.uiAnonymous();
          } else {
            this.processLogin(response);
          }
          return trackEvent("User", "Persist session");
        },

        error: () => {
          return this.uiAnonymous();
        }
      });

    } else {
      return this.uiAnonymous();
    }
  },

  login(email, passwd) {

    $("#login-mg input").each(function() {
      return $(this).disable();
    });

    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/user/login`,
      type: "POST",
      dataType: "json",
      data: {
        email,
        passwd
      },
      success: response => {
        // Save the session_token for later <3
        this.processLogin(response);

        if ((response.trial_remaining != null) > 0) {
          ui.menu.menus.account.openDropdown();
        }

        $("#login-mg input").each(function() {
          return $(this).enable();
        });

        // Track to GA
        return trackEvent("User", "Login");
      },

      error: data => {
        data = JSON.parse(data.responseText);
        $("#submit-login").error(data.error);
        return trackEvent("User", "Login error", data.error);
      },


      complete() {
        return $("#login-mg input").each(function() {
          return $(this).enable();});
      }

    });
  },

  processLogin(response) {

    $.extend(this, response);

    // Store the session token locally
    localStorage.setItem("session_token", this.session_token);

    ui.menu.menus.login.groupHide();
    ui.menu.menus.register.groupHide();
    ui.menu.menus.account.show().text(this.email);

    ui.menu.closeAllDropdowns();

    this.uiLoggedIn();

    //ui.file.getNewestVersion()

    if (response.services != null) {
      return Array.from(response.services).map((s) =>
        services[s].activate());
    } else {
      // Advertise all the non-default services.
      // For now it's just Dropbox.
      return services.dropbox.tease();
    }
  },



  logout() {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/user/logout`,
      type: "POST",
      dataType: "json",
      data: {
        session_token: this.session_token
      },
      success: response => {
        this.session_token = undefined;
        localStorage.removeItem("session_token");

        // Track to GA
        trackEvent("User", "Logout");

        this.uiAnonymous();

        ui.menu.menus.account.groupHide();
        ui.menu.menus.login.groupShow();
        return ui.menu.menus.register.groupShow();
      }
    });
  },

  checkServices() {
    return $.getJSON(`${SETTINGS.MEOWSET.ENDPOINT}/user/check-services`,
      { session_token: this.session_token },
      function(data) {
        if (data.dropbox) {
          return services.dropbox.activate();
        }
    });
  },


  create(name, email, passwd) {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/user/register`,
      type: "POST",
      dataType: "json",
      data: {
        name,
        email,
        passwd
      },
      success: data => {
        trackEvent("User", "Create", `(${name} , ${email})`);
        this.login(email, passwd);
        return ui.menu.closeAllDropdowns();
      },
      error: data => {
        data = JSON.parse(data.responseText);
        return $("#submit-registration").error(data.error);
      }
    });
  }
};


setup.push(function() {
  ui.account.checkSession();
  return ui.refreshUtilities();
}); // Hackish spot for this

