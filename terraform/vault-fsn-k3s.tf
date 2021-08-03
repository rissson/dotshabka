resource "vault_mount" "fsn-k3s" {
  path = "fsn-k3s"
  type = "kv"
  options = {
    version = 2
  }
}

//
// Bitwarden
//
resource "random_password" "fsn-k3s_bitwarden_admin" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_bitwarden_admin" {
  path = "fsn-k3s/bitwarden/admin"
  data_json = jsonencode({
    token = random_password.fsn-k3s_bitwarden_admin[0].result
  })
}
resource "vault_generic_secret" "fsn-k3s_bitwarden_yubico-api-creds" {
  path         = "fsn-k3s/bitwarden/yubico-api-creds"
  disable_read = true
  data_json = jsonencode({
    client_id = ""
    secret_id = ""
  })
}

//
// cAtCDC
//
resource "random_password" "fsn-k3s_catcdc_django-secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_catcdc_django-secrets" {
  path = "fsn-k3s/catcdc/django-secrets"
  data_json = jsonencode({
    DJANGO_SECRET_KEY = random_password.fsn-k3s_catcdc_django-secrets[0].result
  })
}
resource "vault_generic_secret" "fsn-k3s_catcdc_epita-oidc" {
  path         = "fsn-k3s/catcdc/epita-oidc"
  disable_read = true
  data_json = jsonencode({
    SOCIAL_AUTH_EPITA_KEY    = ""
    SOCIAL_AUTH_EPITA_SECRET = ""
  })
}
resource "vault_generic_secret" "fsn-k3s_catcdc_s3" {
  path = "fsn-k3s/catcdc/s3"
  data_json = jsonencode({
    S3_ACCESS_KEY = "catcdc"                               # minio_iam_user.catcdc.name
    S3_SECRET_KEY = random_password.minio_catcdc[0].result # minio_iam_user.catcdc.secret
  })
}

//
// cert-manager.io
//
resource "vault_generic_secret" "fsn-k3s_cert-manager_cloudflare-lama-corp-api-token" {
  path         = "fsn-k3s/cert-manager/cloudflare-lama-corp-api-token"
  disable_read = true
  data_json = jsonencode({
    api-token = ""
  })
}

//
// Gatus
//
resource "vault_generic_secret" "fsn-k3s_gatus_devoups_slack-webhook" {
  path         = "fsn-k3s/gatus/devoups/slack-webhook"
  disable_read = true
  data_json = jsonencode({
    SLACK_WEBHOOK_URL = ""
  })
}

//
// GitLab
//
resource "vault_generic_secret" "fsn-k3s_gitlab_oidc-lama-corp" {
  path         = "fsn-k3s/gitlab/oidc-lama-corp"
  disable_read = true
  data_json = jsonencode({
    provider = jsonencode({
      name  = "openid_connect"
      label = "Lama Corp."
      args = {
        name               = "openid_connect"
        scope              = ["openid", "profile", "email"]
        response_type      = "code"
        issuer             = "https://intra.lama-corp.space"
        discovery          = true
        client_auth_method = "query"
        uid_field          = "username"
        client_options = {
          identifier   = "FILL ME"
          secret       = "FILL ME"
          redirect_uri = "https://gitlab.lama-corp.space/users/auth/openid_connect/callback"
        }
      }
    })
  })
}
resource "vault_generic_secret" "fsn-k3s_gitlab_objectstore" {
  path         = "fsn-k3s/gitlab/objectstore"
  disable_read = true
  data_json = jsonencode({
    # should use minio_iam_user.gitlab.name and minio_iam_user.gitlab.secret
    connection = <<EOF
provider: AWS
aws_access_key_id: gitlab
aws_secret_access_key: ${random_password.minio_gitlab[0].result}
aws_signature_version: 4
host: https://s3.lama-corp.space
endpoint: https://s3.lama-corp.space
path_style: true
EOF
  })
}
resource "vault_generic_secret" "fsn-k3s_gitlab_s3cmd-config" {
  path         = "fsn-k3s/gitlab/s3cmd-config"
  disable_read = true
  data_json = jsonencode({
    # should use minio_iam_user.gitlab.name and minio_iam_user.gitlab.secret
    config = <<EOF
[default]
host_base = https://s3.lama-corp.space
host_bucket = https://s3.lama-corp.space
use_https = True
signature_v2 = True
access_key = gitlab
secret_key = ${random_password.minio_gitlab[0].result}
EOF
  })
}
resource "vault_generic_secret" "fsn-k3s_gitlab_registry-storage" {
  path         = "fsn-k3s/gitlab/registry-storage"
  disable_read = true
  data_json = jsonencode({
    # should use minio_iam_user.gitlab.name and minio_iam_user.gitlab.secret
    config = <<EOF
s3:
  bucket: gitlab-registry
  access_key: gitlab
  secret_key: ${random_password.minio_gitlab[0].result}
  region: us-east-1
  host: s3.lama-corp.space
  regionendpoint: https://s3.lama-corp.space
  v4auth: true
EOF
  })
}

//
// Hedgedoc
//
resource "random_password" "fsn-k3s_hedgedoc_session" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_hedgedoc_session" {
  path = "fsn-k3s/hedgedoc/session"
  data_json = jsonencode({
    secret = random_password.fsn-k3s_hedgedoc_session[0].result
  })
}
resource "vault_generic_secret" "fsn-k3s_hedgedoc_s3" {
  path = "fsn-k3s/hedgedoc/s3"
  data_json = jsonencode({
    S3_ACCESS_KEY = "hedgedoc"
    S3_SECRET_KEY = random_password.minio_hedgedoc[0].result
  })
}

//
// Intranet
//
resource "vault_generic_secret" "fsn-k3s_intranet_intranet-keytab" {
  path         = "fsn-k3s/intranet/intranet-keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = ""
  })
}
resource "vault_generic_secret" "fsn-k3s_intranet_ldap-keytab" {
  path         = "fsn-k3s/intranet/ldap-keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = ""
  })
}
resource "vault_generic_secret" "fsn-k3s_intranet_spnego-keytab" {
  path         = "fsn-k3s/intranet/spnego-keytab"
  disable_read = true
  data_json = jsonencode({
    keytab = ""
  })
}
resource "vault_generic_secret" "fsn-k3s_intranet_algolia" {
  path         = "fsn-k3s/intranet/algolia"
  disable_read = true
  data_json = jsonencode({
    DJANGO_ALGOLIA_API_KEY        = ""
    DJANGO_ALGOLIA_APP_ID         = ""
    DJANGO_ALGOLIA_SEARCH_API_KEY = ""
  })
}
resource "random_password" "fsn-k3s_intranet_django-secrets" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_intranet_django-secrets" {
  path = "fsn-k3s/intranet/django-secrets"
  data_json = jsonencode({
    DJANGO_DEFAULT_ADMIN_PASSWORD = random_password.fsn-k3s_intranet_django-secrets[0].result
    DJANGO_SECRET_KEY             = random_password.fsn-k3s_intranet_django-secrets[1].result
  })
}
resource "vault_generic_secret" "fsn-k3s_intranet_s3" {
  path = "fsn-k3s/intranet/s3"
  data_json = jsonencode({
    S3_ACCESS_KEY = "intranet"                               # minio_iam_user.intranet.name
    S3_SECRET_KEY = random_password.minio_intranet[0].result # minio_iam_user.intranet.secret
  })
}
resource "random_password" "fsn-k3s_intranet_kerberos" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_intranet_kerberos" {
  path = "fsn-k3s/intranet/kerberos"
  data_json = jsonencode({
    adm-service-password = random_password.fsn-k3s_intranet_kerberos[0].result
    kdc-service-password = random_password.fsn-k3s_intranet_kerberos[1].result
  })
}
resource "random_password" "fsn-k3s_intranet_kerberos-admin-password" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_intranet_kerberos-admin-password" {
  path = "fsn-k3s/intranet/kerberos-admin-password"
  data_json = jsonencode({
    KRB5_ADMIN_PASSWORD = random_password.fsn-k3s_intranet_kerberos-admin-password[0].result
  })
}
resource "random_password" "fsn-k3s_intranet_ldap-admin-password" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_intranet_ldap-admin-password" {
  path = "fsn-k3s/intranet/ldap-admin-password"
  data_json = jsonencode({
    LDAP_ADMIN_PASSWORD = random_password.fsn-k3s_intranet_ldap-admin-password[0].result
  })
}
resource "random_password" "fsn-k3s_intranet_ldap-config-password" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_intranet_ldap-config-password" {
  path = "fsn-k3s/intranet/ldap-config-password"
  data_json = jsonencode({
    LDAP_CONFIG_PASSWORD = random_password.fsn-k3s_intranet_ldap-config-password[0].result
  })
}

//
// Matrix
//
resource "random_password" "fsn-k3s_matrix_facebook-bridge_as-hs-tokens" {
  count   = 2
  length  = 64
  special = false
}
resource "random_password" "fsn-k3s_matrix_slack-bridge_as-hs-tokens" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_matrix_appservice-facebook" {
  path = "fsn-k3s/matrix/appservice-facebook"
  data_json = jsonencode({
    "facebook.yaml" = jsonencode({
      id       = "facebook"
      url      = "http://facebook-bridge.matrix.svc.cluster.local:5858"
      as_token = random_password.fsn-k3s_matrix_facebook-bridge_as-hs-tokens[0].result
      hs_token = random_password.fsn-k3s_matrix_facebook-bridge_as-hs-tokens[1].result
      namespaces = {
        users = [
          {
            regex     = "@facebook_.*:lama\\-corp\\.space"
            exclusive = true
          },
          {
            regex     = "@facebookbot:lama\\-corp\\.space"
            exclusive = true
          },
        ]
      }
      sender_localpart = "yfOl_Z_RRRGmX09x86izQyPITUvOh4XIIykB0nfhGgEhxekSLZQyRpbIWZdw_2AX"
      rate_limited     = false
      push_ephemeral   = true
    })
  })
}
resource "vault_generic_secret" "fsn-k3s_matrix_appservice-slack" {
  path = "fsn-k3s/matrix/appservice-slack"
  data_json = jsonencode({
    "slack.yaml" = jsonencode({
      id       = "4935d77bef61191cb3339cd5696eb2bdc368decbe8ec117da84f4b6b372bf4e2"
      url      = "http://slack-bridge.matrix.svc.cluster.local:5858"
      as_token = random_password.fsn-k3s_matrix_slack-bridge_as-hs-tokens[0].result
      hs_token = random_password.fsn-k3s_matrix_slack-bridge_as-hs-tokens[1].result
      namespaces = {
        users = [
          {
            regex     = "@slack_.*:lama\\-corp\\.space"
            exclusive = true
          },
        ]
      }
      sender_localpart = "slackbot"
    })
  })
}
resource "vault_generic_secret" "fsn-k3s_matrix_facebook-bridge-secret-files" {
  path         = "fsn-k3s/matrix/facebook-bridge-secret-files"
  disable_read = true
  data_json = jsonencode({
    "as-hs-tokens.yml" = jsonencode({
      appservice = {
        as_token = random_password.fsn-k3s_matrix_facebook-bridge_as-hs-tokens[0].result
        hs_token = random_password.fsn-k3s_matrix_facebook-bridge_as-hs-tokens[1].result
      }
    })
    "database.yml" = jsonencode({
      appservice = {
        database = "postgres://matrix_facebook_bridge:FIXME@acid-main-cluster.postgres.svc.cluster.local/matrix_slack_bridge?sslmode=require"
      }
    })
    "public-shared-secret.yml" = jsonencode({
      appservice = {
        public = {
          shared_secret = "FIXME"
        }
      }
    })
  })
}
resource "random_password" "fsn-k3s_matrix_maubot_admin" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_matrix_maubot-secret-files" {
  path         = "fsn-k3s/matrix/maubot-secret-files"
  disable_read = true
  data_json = jsonencode({
    "admins.yml" = jsonencode({
      admins = {
        admin = random_password.fsn-k3s_matrix_maubot_admin[0].result
      }
    })
    "database.yml" = jsonencode({
      database = "postgres://matrix_maubot:FIXME@acid-main-cluster.postgres.svc.cluster.local/matrix_maubot"
    })
    "registration-shared-secret.yml" = jsonencode({
      registration_secrets = {
        "lama-corp.space" = {
          secret = random_password.fsn-k3s_matrix_registration-shared-secret.result
        }
      }
    })
    "unshared-secret.yml" = jsonencode({
      server = {
        unshared_secret = "FIXME"
      }
    })
  })
}
resource "vault_generic_secret" "fsn-k3s_matrix_slack-bridge-secret-files" {
  path         = "fsn-k3s/matrix/slack-bridge-secret-files"
  disable_read = true
  data_json = jsonencode({
    "database.yml" = jsonencode({
      db = {
        connectionString = "postgresql://matrix_slack_bridge:FIXME@acid-main-cluster.postgres.svc.cluster.local/matrix_slack_bridge?sslmode=no-verify"
      }
    })
    "oauth2.yml" = jsonencode({
      oauth2 = {
        client_id     = "FIXME"
        client_secret = "FIXME"
      }
    })
  })
}
resource "random_password" "fsn-k3s_matrix_registration-shared-secret" {
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_matrix_synapse-secret-files" {
  path         = "fsn-k3s/matrix/synapse-secret-files"
  disable_read = true
  data_json = jsonencode({
    "database.yaml" = jsonencode({
      database = {
        name = "psycopg2"
        args = {
          database = "matrix"
          host     = "acid-main-cluster.postgres.svc.cluster.local"
          user     = "matrix"
          password = "FIXME"
        }
      }
    })
    "form_secret.yaml" = jsonencode({
      # a secret which is used to calculate HMACs for form values, to stop
      # falsification of values. Must be specified for the User Consent
      # forms to work.
      form_secret = "FIXME"
    })
    "macaroon_secret_key.yaml" = jsonencode({
      # a secret which is used to sign access tokens. If none is specified,
      # the registration_shared_secret is used, if one is given; otherwise,
      # a secret key is derived from the signing key.
      macaroon_secret_key = "FIXME"
    })
    "oidc_providers.yaml" = jsonencode({
      oidc_providers = [{
        idp_id        = "intranet"
        idp_name      = "Intranet"
        issuer        = "https://intra.lama-corp.space"
        client_id     = "FIXME"
        client_secret = "FIXME"
        scopes        = ["openid", "profile", "email"]
        user_mapping_provider = {
          config = {
            localpart_template    = "{{ user.sub }}"
            display_name_template = "{{ user.preferred_username }}"
          }
        }
      }]
    })
    "registration_shared_secret.yaml" = jsonencode({
      # If set, allows registration of standard or admin accounts by anyone who
      # has the shared secret, even if registration is otherwise disabled.
      registration_shared_secret = random_password.fsn-k3s_matrix_registration-shared-secret.result
    })
    "signing.key" = "FIXME"
  })
}

//
// Minio
//
resource "random_password" "fsn-k3s_minio_admin-creds" {
  count   = 2
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_minio_admin-creds" {
  path = "fsn-k3s/minio/admin-creds"
  data_json = jsonencode({
    accesskey = random_password.fsn-k3s_minio_admin-creds[0].result
    secretkey = random_password.fsn-k3s_minio_admin-creds[1].result
  })
}

//
// Monitoring
//
resource "random_password" "fsn-k3s_monitoring_grafana-admin-creds" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_monitoring_grafana-admin-creds" {
  path = "fsn-k3s/monitoring/grafana-admin-creds"
  data_json = jsonencode({
    username = "admin"
    password = random_password.fsn-k3s_monitoring_grafana-admin-creds[0].result
  })
}

//
// Netbox
//
resource "random_password" "fsn-k3s_netbox_django-secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_netbox_django-secrets" {
  path = "fsn-k3s/netbox/django-secrets"
  data_json = jsonencode({
    DJANGO_SECRET_KEY = random_password.fsn-k3s_netbox_django-secrets[0].result
  })
}

//
// Nextcloud
//
resource "random_password" "fsn-k3s_nextcloud_admin-user" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_nextcloud_admin-user" {
  path = "fsn-k3s/nextcloud/admin-user"
  data_json = jsonencode({
    username = "admin"
    password = random_password.fsn-k3s_nextcloud_admin-user[0].result
  })
}

//
// Postgres
//
resource "vault_generic_secret" "fsn-k3s_postgres_pod-secrets" {
  path = "fsn-k3s/postgres/pod-secrets"
  data_json = jsonencode({
    AWS_ACCESS_KEY_ID     = "postgres"                               # minio_iam_user.postgres.name
    AWS_SECRET_ACCESS_KEY = random_password.minio_postgres[0].result # minio_iam_user.postgres.secret
  })
}

//
// Renovate
//
resource "vault_generic_secret" "fsn-k3s_renovate_env" {
  path         = "fsn-k3s/renovate/env"
  disable_read = true
  data_json = jsonencode({
    RENOVATE_TOKEN   = ""
    GITHUB_COM_TOKEN = ""
  })
}

//
// scoreboard-seedbox-cri
//
resource "random_password" "fsn-k3s_scoreboard-seedbox-cri_django-secrets" {
  count   = 1
  length  = 64
  special = false
}
resource "vault_generic_secret" "fsn-k3s_scoreboard-seedbox-cri_django-secrets" {
  path = "fsn-k3s/scoreboard-seedbox-cri/django-secrets"
  data_json = jsonencode({
    DJANGO_SECRET_KEY = random_password.fsn-k3s_scoreboard-seedbox-cri_django-secrets[0].result
  })
}
resource "vault_generic_secret" "fsn-k3s_scoreboard-seedbox-cri_epita-oidc" {
  path         = "fsn-k3s/scoreboard-seedbox-cri/epita-oidc"
  disable_read = true
  data_json = jsonencode({
    SOCIAL_AUTH_EPITA_KEY    = ""
    SOCIAL_AUTH_EPITA_SECRET = ""
  })
}
resource "vault_generic_secret" "fsn-k3s_scoreboard-seedbox-cri_s3" {
  path = "fsn-k3s/scoreboard-seedbox-cri/s3"
  data_json = jsonencode({
    S3_ACCESS_KEY = "scoreboard-seedbox-cri"                               # minio_iam_user.scoreboard-seedbox-cri.name
    S3_SECRET_KEY = random_password.minio_scoreboard-seedbox-cri[0].result # minio_iam_user.scoreboard-seedbox-cri.secret
  })
}

//
// thefractal.space
//
resource "vault_generic_secret" "fsn-k3s_thefractalspace_twitter-creds" {
  path         = "fsn-k3s/thefractalspace/twitter-creds"
  disable_read = true
  data_json = jsonencode({
    TWITTER_CONSUMER_KEY    = ""
    TWITTER_CONSUMER_SECRET = ""
    TWITTER_ACCESS_KEY      = ""
    TWITTER_ACCESS_SECRET   = ""
  })
}
