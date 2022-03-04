//
// acdc.risson.space
//
resource "minio_s3_bucket" "acdc_risson_space" {
  bucket = "acdc.risson.space"
  acl    = "public-read"
}

//
// cache.nix.lama-corp.space
//
resource "random_password" "minio_cache_nix_lama-corp_space" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "cache_nix_lama-corp_space" {
  name = "cache.nix.lama-corp.space"
  secret = random_password.minion_cache_nix_lama-corp_space[0].result
  tags = {
    app = "cache_nix_lama-corp_space"
  }
}
resource "minio_iam_policy" "cache_nix_lama-corp_space-full" {
  name = "cache.nix.lama-corp.space-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.cache_nix_lama-corp_space.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "cache_nix_lama-corp_space-full" {
  user_name   = minio_iam_user.cache_nix_lama-corp_space.name
  policy_name = minio_iam_policy.cache_nix_lama-corp_space-full.name
}
*/
resource "minio_s3_bucket" "cache_nix_lama-corp_space" {
  bucket = "cache.nix.lama-corp.space"
  acl    = "public-read"
}

//
// catcdc
//
resource "random_password" "minio_catcdc" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "catcdc" {
  name = "catcdc"
  secret = random_password.minio_catcdc[0].result
  tags = {
    app = "catcdc"
  }
}
resource "minio_iam_policy" "cats.acdc.risson.space-full" {
  name = "catcdc-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.catcdc.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "catcdc_cats.acdc.risson.space-full" {
  user_name   = minio_iam_user.catcdc.name
  policy_name = minio_iam_policy.cats.acdc.risson.space-full.name
}
*/
resource "minio_s3_bucket" "catcdc" {
  bucket = "cats.acdc.risson.space"
  acl    = "public-read"
}

//
// gitlab
//
locals {
  gitlab_buckets = [
    "gitlab-artifacts",
    "gitlab-backup",
    "gitlab-externaldiffs",
    "gitlab-lfs",
    "gitlab-packages",
    "gitlab-pseudonymizer",
    "gitlab-registry",
    "gitlab-terraform",
    "gitlab-tmp",
    "gitlab-uploads",
  ]
}
resource "random_password" "minio_gitlab" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "gitlab" {
  name = "gitlab"
  secret = random_password.minio_gitlab[0].result
  tags = {
    app = "gitlab"
  }
}
resource "minio_iam_policy" "gitlab-full" {
  // TODO: add for_each here
  name = "gitlab-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.gitlab.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "gitlab_gitlab-full" {
  user_name   = minio_iam_user.gitlab.name
  policy_name = minio_iam_policy.gitlab-full.name
}
*/
resource "minio_s3_bucket" "gitlab" {
  for_each = toset(local.gitlab_buckets)

  bucket = each.value
  acl    = "private"
}

//
// hedgedoc
//
resource "random_password" "minio_hedgedoc" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "hedgedoc" {
  name = "hedgedoc"
  secret = random_password.minio_hedgedoc[0].result
  tags = {
    app = "hedgedoc"
  }
}
resource "minio_iam_policy" "hedgedoc-full" {
  name = "hedgedoc-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.hedgedoc.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "hedgedoc_hedgedoc-full" {
  user_name   = minio_iam_user.hedgedoc.name
  policy_name = minio_iam_policy.hedgedoc-full.name
}
*/
resource "minio_s3_bucket" "hedgedoc" {
  bucket = "hedgedoc"
  acl    = "public-read"
}

//
// intranet
//
resource "random_password" "minio_intranet" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "intranet" {
  name = "intranet"
  secret = random_password.minio_intranet[0].result
  tags = {
    app = "intranet"
  }
}
resource "minio_iam_policy" "intranet-full" {
  name = "intranet-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.intranet.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "intranet_intranet-full" {
  user_name   = minio_iam_user.intranet.name
  policy_name = minio_iam_policy.intranet-full.name
}
*/
resource "minio_s3_bucket" "intranet" {
  bucket = "intranet"
  acl    = "public-read"
}

//
// jdmi.risson.space
//
resource "minio_s3_bucket" "jdmi_risson_space" {
  bucket = "jdmi.risson.space"
  acl    = "public-read"
}

//
// lama-corp.space
//
resource "minio_s3_bucket" "lama-corp_space" {
  bucket = "lama-corp.space"
  acl    = "public-read"
}

//
// Mattermost
//
resource "random_password" "minio_mattermost" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_mattermost_s3" {
  path         = "fsn-k3s/mattermost/s3"
  disable_read = true
  data_json = jsonencode({
    bite = random_password.minio_mattermost[0].result
  })
}
/*
resource "minio_iam_user" "mattermost" {
  name = "mattermost"
  secret = random_password.minio_mattermost[0].result
  tags = {
    app = "mattermost"
  }
}
resource "minio_iam_policy" "mattermost-full" {
  name = "mattermost-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.mattermost.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "mattermost_mattermost-full" {
  user_name   = minio_iam_user.mattermost.name
  policy_name = minio_iam_policy.mattermost-full.name
}
*/
resource "minio_s3_bucket" "mattermost" {
  bucket = "mattermost"
  acl    = "private"
}

//
// postgres
//
resource "random_password" "minio_postgres" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "postgres" {
  name = "postgres"
  secret = random_password.minio_postgres[0].result
  tags = {
    app = "postgres"
  }
}
resource "minio_iam_policy" "postgres-full" {
  name = "postgres-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.postgres_k3s.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "postgres_postgres-full" {
  user_name   = minio_iam_user.postgres.name
  policy_name = minio_iam_policy.postgres-full.name
}
*/
resource "minio_s3_bucket" "postgres_k3s" {
  bucket = "postgres.k3s.lama-corp.space"
  acl    = "private"
}

//
// scoreboard-seedbox-cri
//
resource "random_password" "minio_scoreboard-seedbox-cri" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "scoreboard-seedbox-cri" {
  name = "scoreboard-seedbox-cri"
  secret = random_password.minio_scoreboard-seedbox-cri[0].result
  tags = {
    app = "scoreboard-seedbox-cri"
  }
}
resource "minio_iam_policy" "scoreboard-seedbox-cri-full" {
  name = "scoreboard-seedbox-cri-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.scoreboard-seedbox-cri.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "scoreboard-seedbox-cri_scoreboard-seedbox-cri-full" {
  user_name   = minio_iam_user.scoreboard-seedbox-cri.name
  policy_name = minio_iam_policy.scoreboard-seedbox-cri-full.name
}
*/
resource "minio_s3_bucket" "scoreboard-seedbox-cri" {
  bucket = "scoreboard-seedbox-cri"
  acl    = "public-read"
}

//
// thanos-fsn-k8s
//
resource "random_password" "minio_thanos-fsn-k8s" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "thanos-fsn-k8s" {
  name = "thanos-fsn-k8s"
  secret = random_password.minio_thanos-fsn-k8s[0].result
  tags = {
    app = "thanos-fsn-k8s"
  }
}
resource "minio_iam_policy" "thanos-fsn-k8s-full" {
  name = "thanos-fsn-k8s-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.thanos-fsn-k8s.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "thanos-fsn-k8s-full" {
  user_name   = minio_iam_user.thanos-fsn-k8s.name
  policy_name = minio_iam_policy.thanos-fsn-k8s-full.name
}
*/
resource "minio_s3_bucket" "thanos-fsn-k8s" {
  bucket = "thanos-fsn-k8s"
  acl    = "private"
}

//
// risson.space
//
resource "random_password" "minio_risson_space-gitlab-ci" {
  count   = 1
  length  = 64
  special = false
}
/*
resource "minio_iam_user" "risson_space-gitlab-ci" {
  name = "risson.space-gitlab-ci"
  secret = random_password.minio_risson_space-gitlab-ci[0].result
  tags = {
    app = "risson.space"
  }
}
resource "minio_iam_policy" "risson_space-full" {
  name = "risson.space-full"
  policy = templatefile("${path.module}/minio-policies/allow-full-access.tmpl", {
    RESOURCE_ARN_LIST = toset(["arn:aws:s3:::${minio_s3_bucket.risson_space.bucket}/*"])
  })
}
resource "minio_iam_user_policy_attachment" "risson_space-gitlab-ci_risson_space-full" {
  user_name   = minio_iam_user.risson_space-gitlab-ci.name
  policy_name = minio_iam_policy.risson_space-full.name
}
*/
resource "minio_s3_bucket" "risson_space" {
  bucket = "risson.space"
  acl    = "public-read"
}
