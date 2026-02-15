{
  config,
  lib,
  pkgs,
  pkgs-stable,
  pkgs-edge,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.terminal.zellij;
  themeEnabled = config.modules.theme.enable or false;
  palette = config.modules.theme.palette or {};
  channels = import ../lib/channels.nix {
    inherit lib pkgs pkgs-stable pkgs-edge pkgs-unstable;
  };
in
  channels.mkChannelModule {
    inherit cfg;
    optionPath = [ "modules" "terminal" "zellij" ];
    description = "Zellij terminal multiplexer";
    mkConfig = {channelPkgs, ...}: {
      environment.systemPackages = [
        channelPkgs.zellij
      ];

      home-manager.sharedModules = [
        ({...}: {
          programs.zellij = {
            enable = true;
          };

          xdg.configFile."zellij/config.kdl".text = ''
            // Zellij config — Ctrl+Space leader
            keybinds clear-defaults=true {
              shared_except "locked" {
                bind "Ctrl Space" { SwitchToMode "tmux"; }
              }
              tmux {
                // Panes
                bind "|" "v" { NewPane "Right"; SwitchToMode "Normal"; }
                bind "-" "s" { NewPane "Down"; SwitchToMode "Normal"; }
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
                bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
                bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
                bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
                bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }

                // Tabs
                bind "c" { NewTab; SwitchToMode "Normal"; }
                bind "n" { GoToNextTab; SwitchToMode "Normal"; }
                bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
                bind "," { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                bind "6" { GoToTab 6; SwitchToMode "Normal"; }
                bind "7" { GoToTab 7; SwitchToMode "Normal"; }
                bind "8" { GoToTab 8; SwitchToMode "Normal"; }
                bind "9" { GoToTab 9; SwitchToMode "Normal"; }

                // Session
                bind "d" { Detach; }
                bind "w" { LaunchOrFocusPlugin "session-manager" { floating true; move_to_focused_tab true; }; SwitchToMode "Normal"; }

                // Modes
                bind "r" { SwitchToMode "Resize"; }
                bind "[" { SwitchToMode "Scroll"; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }

                bind "Esc" { SwitchToMode "Normal"; }
                bind "q" { Quit; }
              }

              resize {
                bind "h" { Resize "Increase Left"; }
                bind "j" { Resize "Increase Down"; }
                bind "k" { Resize "Increase Up"; }
                bind "l" { Resize "Increase Right"; }
                bind "H" { Resize "Decrease Left"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
                bind "L" { Resize "Decrease Right"; }
                bind "Esc" { SwitchToMode "Normal"; }
              }

              scroll {
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "Esc" { SwitchToMode "Normal"; }
              }

              entersearch {
                bind "Enter" { SwitchToMode "Search"; }
                bind "Esc" { SwitchToMode "Normal"; }
              }

              search {
                bind "n" { Search "down"; }
                bind "N" { Search "up"; }
                bind "Esc" { SwitchToMode "Normal"; }
              }

              renametab {
                bind "Enter" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
              }

              locked {
                bind "Ctrl Space" { SwitchToMode "tmux"; }
              }
            }

            // Appearance
            default_layout "compact"
            pane_frames false
            mouse_mode true
            copy_on_select true
            scrollback_lines_to_serialize 10000
          '' + optionalString themeEnabled ''

            // Theme
            themes {
              titan {
                fg "${palette.text}"
                bg "${palette.base}"
                black "${palette.surface0}"
                red "${palette.error}"
                green "${palette.success}"
                yellow "${palette.warning}"
                blue "${palette.primary}"
                magenta "${palette.accent}"
                cyan "${palette.info}"
                white "${palette.text}"
                orange "${palette.warning}"
              }
            }
            theme "titan"
          '';
        })
      ];
    };
  }
