{ pkgs, ... }:

let
  nixpkgs = import (import <shabka> {}).external.nixpkgs.release-unstable.path {};
in {
  /*imports = [
    ./module.nix
  ];*/

  nixpkgs.overlays = [
    (self: super: {
      mattermost = pkgs.callPackage ./package.nix {
        inherit (nixpkgs) stdenv fetchurl fetchFromGitHub buildEnv;
        buildGoPackage = nixpkgs.buildGo114Package;
      };
    })
  ];

  services.mattermost = {
    enable = true;
    listenAddress = ":19065";
    localDatabaseCreate = true;
    localDatabaseName = "mattermost";
    localDatabaseUser = "mattermost";
    mutableConfig = false;
    siteName = "Chat | Lama Corp.";
    siteUrl = "https://new.chat.lama-corp.space";
    statePath = "/srv/mattermost";
    extraConfig = {
      ServiceSettings = {
        EnableOAuthServiceProvider = false;
        EnableIncomingWebhooks = true;
        EnableOutgoingWebhooks = true;
        EnableCommands = true;
        EnableOnlyAdminIntegrations = true;
        EnablePostUsernameOverride = true;
        EnablePostIconOverride = true;
        EnableLinkPreviews = true;
        EnableSecurityFixAlert = true;
        EnableMultifactorAuthentication = true;
        EnableUserAccessTokens = true;
        RestrictCustomEmojiCreation = "all";
        RestrictPostDelete = "all";
        AllowEditPost = "always";
        EnableUserTypingMessages = true;
        EnableChannelViewedMessages = true;
        EnableUserStatuses = true;
        ExperimentalEnableAuthenticationTransfer = true;
        EnablePreviewFeatures = true;
        EnableTutorial = true;
        ExperimentalEnableDefaultChannelLeaveJoinMessages = true;
        DisableLegacyMFA = true;
        EnableEmailInvitations = false;
        DisableBotsWhenOwnerIsDeactivated = true;
        EnableSVGs = true;
        EnableLatex = true;
        EnableCustomEmoji = true;
      };
      TeamSettings = {
        MaxUsersPerTeam = 50;
        EnableTeamCreation = true;
        EnableUserCreation = true;
        EnableOpenServer = true;
        EnableUserDeactivation = true;
        EnableCustomBrand = true;
        CustomBrandText = "Lamas are the best in the world!";
        CustomDescriptionText = "Lamas truly are the best in the world!";
        RestrictDirectMessage = "team";
        RestrictTeamInvite = "all";
        MaxChannelsPerTeam = 2000;
        MaxNotificationsPerChannel = 1000000;
        EnableConfirmNotificationsToChannel = true;
        TeammateNameDisplay = "nickname_full_name";
        ExperimentalViewArchivedChannels = true;
        ExperimentalEnableAutomaticReplies = true;
        LockTeammateNameDisplay = false;
      };
      PasswordSettings = {
        MinimumLength = 16;
        Lowercase = true;
        Number = true;
        Uppercase = true;
        Symbol = true;
      };
      FileSettings = {
        EnableFileAttachments = true;
        EnableMobileUpload = true;
        EnableMobileDownload = true;
        MaxFileSize = 52428800;
        DriverName = "amazons3";
        AmazonS3Endpoint = "static.lama-corp.space";
        AmazonS3Bucket = "chat.lama-corp.space";
        EnablePublicLink = true;
      };
      EmailSettings = {
        EnableSignUpWithEmail = true;
        EnableSignInWithEmail = true;
        EnableSignInWithUsername = true;
        SendEmailNotifications = true;
        UseChannelInEmailNotifications = false;
        RequireEmailVerification = true;
        FeedbackName = "Notifications - Chat | Lama Corp.";
        FeedbackEmail = "server@lama-corp.space";
        FeedbackOrganization = "Lama Corp.";
        SendPushNotifications = true;
        PushNotificationServer = "https://push-test.mattermost.com";
        PushNotificationContents = "full";
        EnableEmailBatching = false;
        EmailNotificationContentsType = "full";
        LoginButtonColor = "#0000";
        LoginButtonBorderColor = "#2389D7";
        LoginButtonTextColor = "#2389D7";
      };
      PrivacySettings = {
        ShowEmailAddress = true;
        ShowFullName = true;
      };
      SupportSettings = {
        SupportEmail = "server@lama-corp.space";
      };
      ThemeSettings = {
        EnableThemeSelection = true;
        DefaultTheme = "mattermostDark";
        AllowCustomThemes = true;
      };
      LocalizationSettings = {
        DefaultServerLocale = "en";
        DefaultClientLocale = "en";
        AvailableLocales = "fr,en,de";
      };
      DataRetentionSettings = {
        EnableMessageDeletion = false;
        EnableFileDeletion = true;
        FileRetentionDays = 365;
      };
      PluginSettings = {
        Enable = true;
        EnableUploads = true;
        AllowInsecureDownloadUrl = false;
        EnableHealthCheck = true;
        Plugins = {
          "com.github.manland.mattermost-plugin-gitlab" = {
            enableprivaterepo = true;
            gitlabgroup = "";
            gitlaburl = "https://gitlab.com";
          };
        };
        PluginStates = {
          "com.github.manland.mattermost-plugin-gitlab" = {
            Enable = true;
          };
        };
        EnableMarketplace = true;
        EnableRemoteMarketplace = true;
        AutomaticPrepackagedPlugins = true;
      };
    };
  };

  security.acme.certs."new.chat.lama-corp.space".email = "server@lama-corp.space";
  services.nginx.virtualHosts."new.chat.lama-corp.space" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      access_log /var/log/nginx/access-chat.lama-corp.space.log netdata;
    '';
    locations = {
      "~ /api/v[0-9]+/(users/)?websocket$" = {
        proxyPass = "http://localhost:19065";
        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          client_max_body_size 50M;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Frame-Options SAMEORIGIN;
          proxy_buffers 256 16k;
          proxy_buffer_size 16k;
          client_body_timeout 60;
          send_timeout 300;
          lingering_timeout 5;
          proxy_connect_timeout 90;
          proxy_send_timeout 300;
          proxy_read_timeout 90s;
        '';
      };
      "/" = {
        proxyPass = "http://localhost:19065";
        # TODO: enable cache?
        extraConfig = ''
          client_max_body_size 50M;
          proxy_set_header Connection "";
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Frame-Options SAMEORIGIN;
          proxy_buffers 256 16k;
          proxy_buffer_size 16k;
          proxy_read_timeout 600s;
          #proxy_cache mattermost_cache;
          #proxy_cache_revalidate on;
          #proxy_cache_min_uses 2;
          #proxy_cache_use_stale timeout;
          #proxy_cache_lock on;
          #proxy_http_version 1.1;
        '';
      };
    };
  };
}
