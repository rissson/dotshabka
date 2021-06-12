{
  session_name = "cri";
  start_directory = "~/cri";
  windows = [
    {
      start_directory = "infra/ansible";
      window_name = "ansible";
    }
    {
      start_directory = "iac/undercloud";
      window_name = "under 1";
    }
    {
      start_directory = "iac/undercloud";
      window_name = "under 2";
    }
    {
      start_directory = "iac/overcloud";
      window_name = "over 1";
    }
    {
      start_directory = "iac/overcloud";
      window_name = "over 2";
    }
    {
      start_directory = "packages/kolla-ansible";
      window_name = "kolla";
    }
  ];
}
