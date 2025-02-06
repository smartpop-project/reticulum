import Config

host = "203.245.41.211"
db_host = "203.245.41.211"
config :ret, :logging_url, "https://xrcloud-api.oogame.com/logs"
config :ret, RetWeb.Plugs.PostgrestProxy, 
  hostname: System.get_env("POSTGREST_INTERNAL_HOSTNAME", host)

case config_env() do
  :dev ->
    db_hostname = System.get_env("DB_HOST", db_host)
    dialog_hostname = System.get_env("DIALOG_HOSTNAME", "dev-janus.reticulum.io")
    hubs_admin_internal_hostname = System.get_env("HUBS_ADMIN_INTERNAL_HOSTNAME", "hubs.local")
    hubs_client_internal_hostname = System.get_env("HUBS_CLIENT_INTERNAL_HOSTNAME", "hubs.local")
    spoke_internal_hostname = System.get_env("SPOKE_INTERNAL_HOSTNAME", "hubs.local")

    dialog_port =
      "DIALOG_PORT"
      |> System.get_env("4443")
      |> String.to_integer()

    perms_key =
      "PERMS_KEY"
      |> System.get_env("")
      |> String.replace("\\n", "\n")

    config :ret, Ret.JanusLoadStatus, default_janus_host: dialog_hostname, janus_port: dialog_port

    config :ret, Ret.Locking,
      session_lock_db: [
        database: "ret_dev",
        hostname: db_hostname,
        username: "postgres",
        password: "postgres"
      ]

    # config :ret, Ret.PermsToken, perms_key: perms_key
    config :ret, Ret.PermsToken, perms_key: "-----BEGIN RSA PRIVATE KEY-----MIICWwIBAAKBgQCnam+yXrWXYiDp2HROYLeLU0xaClD/CJq6bZ2I1qhAPG9AqLgi9r7E85x/2pX9FhzXyGIMHIUsk1FntBY/Im/Z5t6K0ohS7fAZxkxVwG9XF9JgWCAwDY6bQ9SuJjwVepCfiOBnOf3VYBdmbP+b3RI8bEgAV7CwNQgQLwWvnqCV1wIDAQABAoGAUAXiSiJXLnsrPFvIjEZStXglgMx5ls4oF4CZ0nS4i6vXidKb4aqL2VyQq9Rx6T2On94ab6uaRIpOWQGNuLPfPkQT1qDghfFnYTX4s7FAU16GEcGkKPTFUxf7GP8xiw/06TpvTM7zbyNMwEIQk5j8/qyDW/oon4AmLk2yzkgvlcECQQDigkVOsPiGz7YFGKEBKJcuVuxEtf/YGqAJMnFzd/p/eGmx14ro/67hsfm8NhLzFjgnXt8E9ho5GpiGQtDBq3+HAkEAvTaLEf59rKC4PlFj08Fsrh/f0csWp7aiYyp5i6qKeBRLWrdGu1OUvv1U5yyRQMzdxCJQj94nXCHplGMgR/KrMQJAYcTZJZ49p/MAHjMDS/y5RMdANGhahmz3pwCe97hR57OR67Gdw/SZB9JKeXLduw9cLaJFoV6Y8w0HyOwOL4pXAQJAGJkmq0gyfmbGjRN3rufOgTSTnGqSn2sW4V18P7QEHGhHA5wgDepnxAybJRKeL5ZynjT31DxFUaz2+NuKLtBVgQJAYruu1eq82q/3Up+B4tPsIz2kKPnF3apqylunO/XyzL7OglK0KqEyR+5vRbkrnWGM7T436t8L+kh/Ksl+pPG2pw==-----END RSA PRIVATE KEY-----"

    config :ret, Ret.PageOriginWarmer,
      admin_page_origin: "https://#{hubs_admin_internal_hostname}:8989",
      hubs_page_origin: "https://#{hubs_client_internal_hostname}:8080",
      spoke_page_origin: "https://#{spoke_internal_hostname}:9090"

    config :ret, Ret.Repo, hostname: db_hostname

    config :ret, Ret.SessionLockRepo, hostname: db_hostname

  :test ->
    db_credentials = System.get_env("DB_CREDENTIALS", "admin")
    db_hostname = System.get_env("DB_HOST", db_host)

    config :ret, Ret.Repo,
      hostname: db_hostname,
      password: db_credentials,
      username: db_credentials

    config :ret, Ret.SessionLockRepo,
      hostname: db_hostname,
      password: db_credentials,
      username: db_credentials

    config :ret, Ret.Locking,
      session_lock_db: [
        database: "ret_test",
        hostname: db_hostname,
        password: db_credentials,
        username: db_credentials
      ]

  _ ->
    :ok
end
