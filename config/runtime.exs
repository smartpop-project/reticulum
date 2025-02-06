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
    config :ret, Ret.PermsToken, perms_key: "-----BEGIN RSA PRIVATE KEY-----\nMIICWgIBAAKBgHpmAuVZld+ZyqySUTD9h4QksxNbT42VLZ9WSCJpElW3qwe8uWVe\n5QfSIv3UItWAuSA19EuNkvjqXISlCK/32iUzcvF7kUg3gpR29OrqnAJvwKQwhK6z\nKgjkIAbIKbbx+J4anmskd3JiETxGyCUhtiG7KF8qg9c2JFyaIj4RFL3JAgMBAAEC\ngYAaP2IDmPCA4NQLqdzrapLzDYOxdPVcYU9FShVx+6JI63gr0pbXXEA1KyUB1coa\nit4oQCnBQfzwkCGC+Hkicz4+S21xQTHWYhhzdaUYSBGq9WJ5JGycSSpAjRjl4f8X\niLT2FephctPXWJSnm8X8/o2CCsX8FI2xa3PGeleS2lxiAQJBAMptCiD36HvV9Yh5\niOMKLOLKhbmalFbXiKwLbo6mvMp/2eGUOhO0gFHCBbHiuLmInmvzNIXdtEMETTO+\nt/aj3ekCQQCayt+LzCFBXEx8lr5u/3j15Iy5em3mmqz304wvqFPQdzjSenJmiGXe\nsMWQrXOcQ8w9LIRThX6yxDgXVS9KJJThAkB0l+Gho6kwysgl13rU6uN3rZbglPyk\nGHkMP3lqiPds278vgyUAfJL8hHirQR+NHffBzc+O22gcwbmF+HAVi8UhAkBbXtd3\n8MXMjAwGGwFMCfc/xmoe7hrDXZguLax5UTYwPr/G1kqDJY5kVho4nXo5yndbwNRX\nbNxt749gjoL8k/1hAkB7yzs2kbtSpVdkz0GqDmjBvooMUV+sShul8hZysgyelchQ\nlOzO9DSeOMFJN4CX355mIryg/l9T3yIvqce4lTjv\n-----END RSA PRIVATE KEY-----"

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
