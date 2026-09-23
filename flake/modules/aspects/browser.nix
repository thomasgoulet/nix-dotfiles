{ den, inputs, ... }:
{
  den.aspects.browser = {

    includes = [
      den.aspects.niri
    ];

    homeManager =
      { ... }:
      {
        imports = [
          inputs.zen-browser.homeModules.beta
        ];

        programs.zen-browser = {
          enable = true;
          setAsDefaultBrowser = true;

          # Catppuccin theme (catppuccin/zen-browser), symlinked into the profile's
          # chrome/catppuccin and loaded via userChrome/userContent imports.
          profiles.default.presets.catppuccin = {
            enable = true;
            flavor = "Mocha"; # Frappe | Latte | Macchiato | Mocha
            accent = "Blue"; # Blue, Flamingo, Green, Lavender, Maroon, Mauve, ...
          };

          # [github:yokooffling/Betterfox](https://github.com/yokoffing/Betterfox)
          # profiles.default.presets.betterfox.enable = true;

          # [github:arkenfox:user.js](https://github.com/arkenfox/user.js/wiki/2.1-User.js)
          # profiles.default.presets.arkenfox.enable = true;
        };

        programs.zen-browser.policies = {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
        };
      };
  };

}
