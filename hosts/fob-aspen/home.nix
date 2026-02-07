{pkgs, ...}: {
  home.username = "titan";
  home.homeDirectory = "/home/titan";

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
