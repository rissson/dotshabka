{ mode, config, pkgs, lib, ... }:

with pkgs;
with lib;

let

  grovboxVersion = "3.0.1-rc.0";

  grovboxSrc = fetchFromGitHub {
    owner = "morhetz";
    repo = "gruvbox";
    rev = "v${grovboxVersion}";
    sha256 = "01as1pkrlbzhcn1kyscy476w8im3g3wmphpcm4lrx7nwdq8ch7h1";
  };

in {
  config = (mkMerge [
    (optionalAttrs (mode == "home-manager") {
      # Originally found this at
      # https://github.com/a-schaefers/i3-wm-gruvbox-theme/blob/f6e570d6ab11b00b950e993c8619ac253bbb03ea/i3/config#L101
      #
      # TODO(low): import the green variation from
      # https://github.com/a-schaefers/i3-wm-gruvbox-theme/blob/f6e570d6ab11b00b950e993c8619ac253bbb03ea/i3/config#L136-L141
      xsession = optionalAttrs stdenv.isLinux {
        windowManager = {
          inherit (config.soxin.themes.gruvbox-dark) i3;
        };
      };

      services.polybar.config = {
        inherit (config.soxin.themes.gruvbox-dark.polybar.extraConfig) colors;
      };

      # Taken from https://github.com/x4121/dotfiles/blob/4e73c297afe7675bc5490fbb73b8f2481cf3ca95/etc/gruvbox-dark-256.taskwarrior.theme
      programs.taskwarrior.extraConfig = ''
        ################################################################################
        #
        # Copyright 2017, Armin Grodon.
        # Copyright 2006 - 2016, Paul Beckingham, Federico Hernandez.
        #
        # Permission is hereby granted, free of charge, to any person obtaining a copy
        # of this software and associated documentation files (the "Software"), to deal
        # in the Software without restriction, including without limitation the rights
        # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        # copies of the Software, and to permit persons to whom the Software is
        # furnished to do so, subject to the following conditions:
        #
        # The above copyright notice and this permission notice shall be included
        # in all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
        # THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        # SOFTWARE.
        #
        # http://www.opensource.org/licenses/mit-license.php
        #
        ###############################################################################

        rule.precedence.color=deleted,completed,active,keyword.,tag.,project.,overdue,scheduled,due.today,due,blocked,blocking,recurring,tagged,uda.

        # General decoration
        color.label=
        color.label.sort=
        color.alternate=on color237
        color.header=color4
        color.footnote=color6
        color.warning=color0 on color3
        color.error=color1
        color.debug=color5

        # Task state
        color.completed=
        color.deleted=
        color.active=color11
        color.recurring=color4
        color.scheduled=
        color.until=
        color.blocked=color0 on color3
        color.blocking=color9 on color3

        # Project
        color.project.none=

        # Priority
        color.uda.priority.H=color13
        color.uda.priority.M=color12
        color.uda.priority.L=color14

        # Tags
        color.tag.next=
        color.tag.none=
        color.tagged=color10

        # Due
        color.due=color9
        color.due.today=color1
        color.overdue=color5

        # Report: burndown
        color.burndown.done=color0 on color2
        color.burndown.pending=color0 on color1
        color.burndown.started=color0 on color3

        # Report: history
        color.history.add=color0 on color1
        color.history.delete=color0 on color3
        color.history.done=color0 on color2

        # Report: summary
        color.summary.background=on color0
        color.summary.bar=color0 on color2

        # Command: calendar
        color.calendar.due=color0 on color3
        color.calendar.due.today=color0 on color166
        color.calendar.overdue=color0 on color1
        color.calendar.holiday=color0 on color6
        color.calendar.today=color0 on color4
        color.calendar.weekend=color14 on color0
        color.calendar.weeknumber=color12

        # Command: sync
        color.sync.added=color10
        color.sync.changed=color11
        color.sync.rejected=color9

        # Command: undo
        color.undo.after=color2
        color.undo.before=color1
      '';
    })
  ]);
}
