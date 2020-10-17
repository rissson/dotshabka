{ ... }:

{
  minio-1 = import ./minio-1 { };

  postgres-1 = import ./postgres-1 { };

  reverse-2 = import ./reverse-2 { };

  virt = import ./virt { };

  hub = import ./hub { };

  lewdax = import ./lewdax { };
}
