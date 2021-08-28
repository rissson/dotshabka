{
  session_name = "cri";
  start_directory = "~/cri";
  windows = [
    {
      start_directory = "iac/infrastructure/undercloud";
      window_name = "under 1";
    }
    {
      start_directory = "iac/infrastructure/undercloud";
      window_name = "under 2";
    }
    {
      start_directory = "iac/infrastructure/kolla";
      window_name = "kolla";
    }
    {
      start_directory = "iac/infrastructure/overcloud";
      window_name = "over 1";
    }
    {
      start_directory = "iac/infrastructure/overcloud/terraform";
      window_name = "over 2";
    }
    {
      start_directory = "iac/infrastructure/k8s/argocd";
      window_name = "argocd";
    }
    {
      start_directory = "iac/infrastructure/k8s/clusters/apps";
      window_name = "cluster apps";
    }
    {
      start_directory = "iac/infrastructure/k8s/clusters/others";
      window_name = "cluster others";
    }
    {
      start_directory = "iac/infrastructure/k8s/apps";
      window_name = "apps";
    }
    {
      start_directory = "iac/infrastructure/k8s/secrets";
      window_name = "secrets";
    }
    {
      start_directory = "packages/kolla-ansible";
      window_name = "kolla-ansible";
    }
  ];
}
