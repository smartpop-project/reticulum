import Config

# NOTE: this file contains some security keys/certs that are *not* secrets, and are only used for local development purposes.

host = "xrcloud-room.dev.belivvr.com"
cors_proxy_host = "xrcloud-room.dev.belivvr.com"
# host = "hubs.local"
# cors_proxy_host = "hubs-proxy.local"
assets_host = "hubs-assets.local"
link_host = "hubs-link.local"

# To run reticulum across a LAN for local testing, uncomment and change the line below to the LAN IP
host = cors_proxy_host = "oogame.com"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ret, RetWeb.Endpoint,
  url: [scheme: "https", host: host, port: 4000],
  static_url: [scheme: "https", host: host, port: 4000],
  https: [
    port: 4000,
    otp_app: :ret,
    cipher_suite: :strong,
    keyfile: "#{File.cwd!()}/certs/key.pem",
    certfile: "#{File.cwd!()}/certs/cert.pem"
  ],
  cors_proxy_url: [scheme: "https", host: cors_proxy_host, port: 4080],
  assets_url: [scheme: "https", host: assets_host, port: 4000],
  link_url: [scheme: "https", host: link_host, port: 4000],
  imgproxy_url: [scheme: "http", host: host, port: 5000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  # This config value is for local development only.
  secret_key_base: "txlMOtlaY5x3crvOCko4uV5PM29ul3zGo1oBGNO3cDXx+7GHLKqt0gR9qzgThxb5",
  allowed_origins: "*",
  allow_crawlers: true

# add
config :ret, Ret.PermsToken, perms_key: "-----BEGIN RSA PRIVATE KEY-----MIICWwIBAAKBgQCnam+yXrWXYiDp2HROYLeLU0xaClD/CJq6bZ2I1qhAPG9AqLgi9r7E85x/2pX9FhzXyGIMHIUsk1FntBY/Im/Z5t6K0ohS7fAZxkxVwG9XF9JgWCAwDY6bQ9SuJjwVepCfiOBnOf3VYBdmbP+b3RI8bEgAV7CwNQgQLwWvnqCV1wIDAQABAoGAUAXiSiJXLnsrPFvIjEZStXglgMx5ls4oF4CZ0nS4i6vXidKb4aqL2VyQq9Rx6T2On94ab6uaRIpOWQGNuLPfPkQT1qDghfFnYTX4s7FAU16GEcGkKPTFUxf7GP8xiw/06TpvTM7zbyNMwEIQk5j8/qyDW/oon4AmLk2yzkgvlcECQQDigkVOsPiGz7YFGKEBKJcuVuxEtf/YGqAJMnFzd/p/eGmx14ro/67hsfm8NhLzFjgnXt8E9ho5GpiGQtDBq3+HAkEAvTaLEf59rKC4PlFj08Fsrh/f0csWp7aiYyp5i6qKeBRLWrdGu1OUvv1U5yyRQMzdxCJQj94nXCHplGMgR/KrMQJAYcTZJZ49p/MAHjMDS/y5RMdANGhahmz3pwCe97hR57OR67Gdw/SZB9JKeXLduw9cLaJFoV6Y8w0HyOwOL4pXAQJAGJkmq0gyfmbGjRN3rufOgTSTnGqSn2sW4V18P7QEHGhHA5wgDepnxAybJRKeL5ZynjT31DxFUaz2+NuKLtBVgQJAYruu1eq82q/3Up+B4tPsIz2kKPnF3apqylunO/XyzL7OglK0KqEyR+5vRbkrnWGM7T436t8L+kh/Ksl+pPG2pw==-----END RSA PRIVATE KEY-----"

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem

# The `http:` config above can be replaced with:

#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :ret, RetWeb.Endpoint,
  # static_url: [scheme: "https", host: "assets-prod.reticulum.io", port: 443],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/ret_web/views/.*(ex)$},
      ~r{lib/ret_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :ret, Ret.Repo,
  username: "postgres",
  password: "postgres",
  database: "ret_dev",
  template: "template0",
  pool_size: 10

config :ret, Ret.SessionLockRepo,
  username: "postgres",
  password: "postgres",
  database: "ret_dev",
  template: "template0",
  pool_size: 10

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

config :ret, RetWeb.Api.V1.WhatsNewController, token: ""

config :ret, RetWeb.Plugs.DashboardHeaderAuthorization, dashboard_access_key: ""

# Allow any origin for API access in dev
config :cors_plug, origin: ["*"]

config :ret,
  # This config value is for local development only.
  upload_encryption_key: "a8dedeb57adafa7821027d546f016efef5a501bd",
  bot_access_key: ""

config :ret, Ret.PageOriginWarmer, insecure_ssl: true

config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.MediaResolver,
  giphy_api_key: nil,
  deviantart_client_id: nil,
  deviantart_client_secret: nil,
  imgur_mashape_api_key: nil,
  imgur_client_id: nil,
  youtube_api_key: nil,
  sketchfab_api_key: "49ca9db0c1944fcb974d13e007dba18c",
  ytdl_host: nil,
  photomnemonic_endpoint: "https://uvnsm9nzhe.execute-api.us-west-1.amazonaws.com/public"

config :ret, Ret.Speelycaptor,
  speelycaptor_endpoint: "https://1dhaogh2hd.execute-api.us-west-1.amazonaws.com/public"

config :ret, Ret.Storage,
  host: "https://#{host}:4000",
  storage_path: "/home/admin/hubs_projects/reticulum/storage/storage/dev",
  ttl: 60 * 60 * 24

asset_hosts =
  "https://localhost:4000 https://localhost:8080 " <>
    "https://#{host}:4000 https://#{host}:8080 https://#{host}:3000 https://#{host}:8989 https://#{host}:9090 https://#{cors_proxy_host}:4000 https://#{cors_proxy_host}:4080 " <>
    "https://assets-prod.reticulum.io https://asset-bundles-dev.reticulum.io https://asset-bundles-prod.reticulum.io"

websocket_hosts =
  "https://localhost:4000 https://localhost:8080 wss://localhost:4000 " <>
    "https://#{host}:4000 https://#{host}:8080 wss://#{host}:4000 wss://#{host}:8080 wss://#{host}:8989 wss://#{host}:9090 " <>
    "wss://#{host}:4000 wss://#{host}:8080 https://#{host}:8080 https://hubs.local:8080 wss://hubs.local:8080"

config :ret, RetWeb.Plugs.AddCSP,
  script_src: asset_hosts,
  font_src: asset_hosts,
  style_src: asset_hosts,
  connect_src:
    "https://#{host}:8080 https://sentry.prod.mozaws.net #{asset_hosts} #{websocket_hosts} https://www.mozilla.org",
  img_src: asset_hosts,
  media_src: asset_hosts,
  manifest_src: asset_hosts

config :ret, Ret.Mailer, adapter: Bamboo.LocalAdapter

config :ret, RetWeb.Email, from: "info@hubs-mail.com"

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
  environment_name: :dev,
  json_library: Poison,
  included_environments: [],
  tags: %{
    env: "dev"
  }

config :ret, Ret.Habitat, ip: "127.0.0.1", http_port: 9631

config :ret, Ret.RoomAssigner, balancer_weights: [{600, 1}, {300, 50}, {0, 500}]

config :ret, RetWeb.PageController,
  skip_cache: true,
  assets_path: "storage/assets",
  docs_path: "storage/docs"

config :ret, Ret.HttpUtils, insecure_ssl: true

config :ret, Ret.Meta, phx_host: host

config :ret, Ret.Locking, lock_timeout_ms: 1000 * 60 * 15

config :ret, Ret.Repo.Migrations.AdminSchemaInit, postgrest_password: "postgres"
config :ret, Ret.StatsJob, node_stats_enabled: false, node_gauges_enabled: false
config :ret, Ret.Coturn, realm: "ret"
config :ret, :logging_url, "https://xrcloud-api.dev.belivvr.com/logs"
