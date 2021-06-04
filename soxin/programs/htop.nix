{ mode, config, pkgs, lib, ... }:

with lib;

let
  cfg = config.soxin.programs.htop;
in
{
  options = {
    soxin.programs.htop = {
      enable = mkEnableOption "Whether to enable htop.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (optionalAttrs (mode == "NixOS") {
      environment.systemPackages = [ pkgs.htop ];
    })

    (optionalAttrs (mode == "home-manager") {
      programs.htop = {
        enable = true;

        settings = {
          color_scheme = 0;
          header_margin = false;

          highlight_base_name = true;
          highlight_megabytes = false;
          highlight_threads = true;
          show_program_path = false;
          show_thread_names = false;

          delay = 15;
          cpu_count_from_zero = false;
          detailed_cpu_time = false;
          hide_kernel_threads = false;
          hide_userland_threads = false;
          shadow_other_users = false;
          update_process_names = false;

          sort_key = with config.lib.htop.fields; PERCENT_CPU;
          sort_direction = 1;
          tree_view = false;

          fields = with config.lib.htop.fields; [ PID USER PRIORITY NICE M_SIZE M_RESIDENT M_SHARE STATE PERCENT_CPU PERCENT_MEM TIME COMM ];
        } // (with config.lib.htop; leftMeters [
          (bar "LeftCPUs")
          (bar "Memory")
          (bar "Swap")
          (bar "CPU")
        ]) // (with config.lib.htop; rightMeters [
          (bar "RightCPUs")
          (text "Tasks")
          (text "LoadAverage")
          (text "Uptime")
        ]);
      };
    })
  ]);
}
