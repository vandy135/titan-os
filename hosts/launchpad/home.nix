{pkgs, ...}: {
  home.username = "titan";
  home.homeDirectory = "/home/titan";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "vandy135";
      user.email = "titan@fob-aspen";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  home.stateVersion = "25.11";
}
