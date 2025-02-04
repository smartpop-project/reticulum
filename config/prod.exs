use Mix.Config

# Production Config from
# https://github.com/albirrkarim/mozilla-hubs-installation-detailed

# Change this
host = "oogame.com"
db_name = "ret_dev"
storage_outside_github_workflow = "/home/admin/hubs_projects/storage/reticulum/storage"

# Dont change this
cors_proxy_host = "hubs-proxy.local"
assets_host = "hubs-assets.local"
link_host = "hubs-link.local"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ret, RetWeb.Endpoint,
  url: [scheme: "https", host: host, port: 443],
  static_url: [scheme: "https", host: host, port: 443],
  https: [
    port: 4000,
    otp_app: :ret,
    cipher_suite: :strong,
    keyfile: "/etc/letsencrypt/live/#{host}/privkey.pem",
    certfile: "/etc/letsencrypt/live/#{host}/cert.pem"
  ],
  cors_proxy_url: [scheme: "https", host: cors_proxy_host, port: 443],
  assets_url: [scheme: "https", host: assets_host, port: 443],
  link_url: [scheme: "https", host: link_host, port: 443],
  imgproxy_url: [scheme: "http", host: host, port: 5000],
  debug_errors: true,
  # this is important
  code_reloader: false,
  check_origin: false,
  # This config value is for local development only.
  secret_key_base: "txlMOtlaY5x3crvOCko4uV5PM29ul3zGo1oBGNO3cDXx+7GHLKqt0gR9qzgThxb5",
  allowed_origins: "*",
  allow_crawlers: true

# Configure your database
config :ret, Ret.Repo,
  username: "postgres",
  password: "postgres",
  database: db_name,
  hostname: "localhost",
  template: "template0",
  pool_size: 10

config :ret, Ret.SessionLockRepo,
  username: "postgres",
  password: "postgres",
  database: db_name,
  hostname: "localhost",
  template: "template0",
  pool_size: 10

config :ret, Ret.Locking,
  lock_timeout_ms: 1000 * 60 * 15,
  session_lock_db: [
    username: "postgres",
    password: "postgres",
    database: db_name,
    hostname: "localhost"
  ]

# Place the storage outside github workflow
config :ret, Ret.Storage,
  host: "https://#{host}:4000",
  storage_path: "/home/admin/hubs_projects/reticulum/storage",
  ttl: 60 * 60 * 24

config :ret, Ret.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtpdm-ap-southeast-1.aliyun.com",
  port: 465,
  username: "your_email@xxx.com",
  password: "your_password123",
  tls: :if_available,
  ssl: true,
  retries: 1,
  debug_mode: true

config :ret, RetWeb.Email, from: "your_email@xxx.com"

# config :ret, Ret.PermsToken, perms_key: (System.get_env("PERMS_KEY") || "") |> String.replace("\\n", "\n")

config :ret, Ret.PermsToken,
  perms_key:
    "-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEA1ySZnNhzLUZQSo5m7vjWMhq4cChla6M2yfpgWaL5eR/K7Qgrnm0a5u3gvvgNVcvtcAN/A7MWPUCrm+EE4AeBV/lJF6+JjFJ4iMcie76ufgmiRLwZIeD/1hc9SFj56OFpS/7ifnw62hLITqRbCezqiG/MkM7pGQt1I+Ba5KKuj9xZ9r5B0UntIiBjj3BJX5JxaFPC5K7Jdkh/Yjfm4jJhaknLCtb0vQI6TEgjFSs2NJTNp4gZFjh6xicDAZA/0el3JPW5ogyB6ZNH1A3MD0mAkWTqW+IJy4dNDhKcgXHcfIA6Vl0tJKdH5QLjYQ3OlJtcOU0HwU99mAabcx262bBDBwIDAQABAoIBAEPOPjfHpC09vupwjRJ+DIwIDd8TbDuLWiY4Kgu2KKg7E+q2q4Cn5FWp3S5y4UkMF445G9vfon+1lSBwv+eXlfVTFO1JHrHCAEkjccPMahRBFwpQuh8KWbdw5ZiaqlDyUgxojZvNrYKzbrwSYrrzF0ve6HsvKxoAmW+wMxViDGA8P1akSx3t8mlRrsjQspR0GJ63qgqFkBr8ZplcztEo6mSaQvSZg0RxBzMzlFc2CfknWU4V49Ze+gGMBmfAzDZSanHT2isy2znWHJI7SJLotaTpGuLnA0SwsRiwZFp9AFkUX4GzTMSBdoFXyIgyA2bHd4JErRRoGBVfmhMsv2QiyFkCgYEA+G9yLx0baAxDnu74UFl1DvX6Ijbl+nGLlFHQn+iX5fdGadIRDLG6f42RQrV5QjkBNxpCyRwPJSfBEVGfErkGJJNCoH+mCUcHtOBOlPF+fhj8F78MRYlEmzijOHkI9nd4g5VeWpLWXSpxW7uGiR5nRvQt+JV2tg4KMqbeDe77rDsCgYEA3bGj04QXgx+zvgoVy1MymjKXY/ILKKuq8IU5oKi5EGH2lQfijQKQQHMZyXjc4kgUzaA03cywmVI5RsAtA+kAdsTu3/wNefPYpdlP6Ab7/yQbooLVXi9MTX+y+afkfpPZyVgYHPLu7221iUhqzp4KKaYwh9bSN4a3w+wHhfBXs6UCgYEApQ296elHrRAA2RXhadiVOfRYU+TvVD2dw1O77JGmYYWwhVuoMiveQSI38P8KaeHfmdFbr6txsHjB/5Sfv9unZiNkL6e/Ewja6OPhsXjkVjiZO9mU+JnjN9EgN8PKHZ1wNtPFFR3bR5iMKarkDjNh4DUYWcBLV1bqlY5hlxZApMMCgYEAmNk+S7oZ/+Tep1sKtbnx/JB/AoDCItNhMx2XouZRWjNAsHXUREaNMHJrSBZVrInoFfGsIXRcGgmvxdD/+F8wW7Lhw3pjzD5Mk+RljGMsYTgC+aPc+mf/4rr1qd2Q05iaopBjZ6ozBM8OR82vHi+mcBrOAQoiu/fdQW69rSINRaUCgYEAiklwsl/9SF61AqzpadLIFBggLAE5utBnOjw7EMFB4+oUHOx4a0gN45EhbET5v8s76nC1Cy6SIIpIImU+6Gso2KPQGXd8h5T8EyM973DS/ollQlzCXDhmU6DH2t2V6BAqDFhY6aDJUN8kwE5sCtSqQnpeUiCV+nM9rbpuWLme/9c=-----END RSA PRIVATE KEY-----"

# config :ret, Ret.JanusLoadStatus, default_janus_host: host, janus_port: 443
config :ret, Ret.JanusLoadStatus, default_janus_host: host, janus_port: 4443

# Do not include metadata nor timestamps in development logs
# config :logger, :console, format: "[$level] $message\n"
# Do not print debug messages in production
config :logger, level: :info
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :ret, RetWeb.Plugs.HeaderAuthorization,
  header_name: "x-ret-admin-access-key",
  header_value: "admin-only"

config :ret, Ret.SlackClient,
  client_id: "",
  client_secret: "",
  bot_token: ""

# Token is our randomly generated auth token to append to Slacks slash command
# As a query param "token"
config :ret, RetWeb.Api.V1.SlackController, token: ""

config :ret, Ret.DiscordClient,
  client_id: "",
  client_secret: "",
  bot_token: ""

# Allow any origin for API access in dev
config :cors_plug, origin: ["*"]

config :ret,
  # This config value is for local development only.
  upload_encryption_key: "a8dedeb57adafa7821027d546f016efef5a501bd",
  bot_access_key: ""

config :ret, Ret.PageOriginWarmer,
  hubs_page_origin: "https://#{host}:8080",
  admin_page_origin: "https://#{host}:8989",
  spoke_page_origin: "https://#{host}:9090",
  insecure_ssl: true

# config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.Scheduler,
  jobs: [
    # Send stats to StatsD every 5 seconds
    {{:extended, "*/5 * * * *"}, {Ret.StatsJob, :send_statsd_gauges, []}},

    # Flush stats to db every 5 minutes
    {{:cron, "*/5 * * * *"}, {Ret.StatsJob, :save_node_stats, []}},

    # Keep database warm when connected users
    {{:cron, "*/3 * * * *"}, {Ret.DbWarmerJob, :warm_db_if_has_ccu, []}},

    # Rotate TURN secrets if enabled
    {{:cron, "*/5 * * * *"}, {Ret.Coturn, :rotate_secrets, []}},

    # Various maintenence routines
    {{:cron, "0 10 * * *"}, {Ret.Storage, :vacuum, []}},
    {{:cron, "3 10 * * *"}, {Ret.Storage, :demote_inactive_owned_files, []}},
    {{:cron, "4 10 * * *"}, {Ret.LoginToken, :expire_stale, []}},
    {{:cron, "5 10 * * *"}, {Ret.Hub, :vacuum_entry_codes, []}},
    {{:cron, "6 10 * * *"}, {Ret.Hub, :vacuum_hosts, []}},
    {{:cron, "7 10 * * *"}, {Ret.CachedFile, :vacuum, []}}
  ]

config :ret, Ret.MediaResolver,
  giphy_api_key: nil,
  deviantart_client_id: nil,
  deviantart_client_secret: nil,
  imgur_mashape_api_key: nil,
  imgur_client_id: nil,
  youtube_api_key: nil,
  sketchfab_api_key: nil,
  ytdl_host: nil,
  photomnemonic_endpoint: "https://uvnsm9nzhe.execute-api.us-west-1.amazonaws.com/public"

config :ret, Ret.Speelycaptor,
  speelycaptor_endpoint: "https://1dhaogh2hd.execute-api.us-west-1.amazonaws.com/public"

asset_hosts =
  "https://localhost:4000 https://localhost:8080 " <>
    "https://#{host} https://#{host}:4000 https://#{host}:8080 https://#{host}:3000 https://#{host}:8989 https://#{host}:9090 https://#{cors_proxy_host}:4000 " <>
    "https://assets-prod.reticulum.io https://asset-bundles-dev.reticulum.io https://asset-bundles-prod.reticulum.io"

websocket_hosts =
  "https://localhost:4000 https://localhost:8080 wss://localhost:4000 " <>
    "https://#{host}:4000 https://#{host}:8080 wss://#{host}:4000 wss://#{host}:8080 wss://#{host}:8989 wss://#{host}:9090 " <>
    "wss://#{host}:4000 wss://#{host}:8080 https://#{host}:8080 https://localhost:8080 wss://localhost:8080"

config :ret, RetWeb.Plugs.AddCSP,
  script_src: asset_hosts,
  font_src: asset_hosts,
  style_src: asset_hosts,
  connect_src:
    "https://#{host}:8080 https://sentry.prod.mozaws.net #{asset_hosts} #{websocket_hosts} https://www.mozilla.org",
  img_src: asset_hosts,
  media_src: asset_hosts,
  manifest_src: asset_hosts

config :ret, Ret.OAuthToken, oauth_token_key: ""

config :ret, Ret.Guardian,
  issuer: "ret",
  # This config value is for local development only.
  secret_key: "47iqPEdWcfE7xRnyaxKDLt9OGEtkQG3SycHBEMOuT2qARmoESnhc76IgCUjaQIwX",
  ttl: {12, :weeks}

config :web_push_encryption, :vapid_details,
  subject: "mailto:admin@mozilla.com",
  public_key:
    "BAb03820kHYuqIvtP6QuCKZRshvv_zp5eDtqkuwCUAxASBZMQbFZXzv8kjYOuLGF16A3k8qYnIN10_4asB-Aw7w",
  # This config value is for local development only.
  private_key: "w76tXh1d3RBdVQ5eINevXRwW6Ow6uRcBa8tBDOXfmxM"

config :sentry,
  environment_name: :prod,
  json_library: Poison,
  included_environments: [:prod],
  tags: %{
    env: "prod"
  }

config :ret, Ret.Habitat, ip: "127.0.0.1", http_port: 9631

config :ret, Ret.RoomAssigner, balancer_weights: [{600, 1}, {300, 50}, {0, 500}]

config :ret, RetWeb.PageController,
  skip_cache: true,
  assets_path: "storage/assets",
  docs_path: "storage/docs"

config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.Meta, phx_host: host

config :ret, Ret.Repo.Migrations.AdminSchemaInit, postgrest_password: "password"
config :ret, Ret.StatsJob, node_stats_enabled: false, node_gauges_enabled: false
config :ret, Ret.Coturn, realm: "ret"
