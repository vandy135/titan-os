{pkgs, ...}: {
  home.username = "titan";
  home.homeDirectory = "/home/titan";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "vandy135";
    userEmail = "titan@fob-aspen";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  home.stateVersion = "25.11";
}
