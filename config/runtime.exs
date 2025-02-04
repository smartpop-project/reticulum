import Config

config :ret, :logging_url, "https://xrcloud-api.oogame.com/logs"
config :ret, RetWeb.Plugs.PostgrestProxy, 
  hostname: System.get_env("POSTGREST_INTERNAL_HOSTNAME", "localhost")

case config_env() do
  :dev ->
    db_hostname = System.get_env("DB_HOST", "localhost")
    dialog_hostname = System.get_env("DIALOG_HOSTNAME", "dev-janus.reticulum.io")
    hubs_admin_internal_hostname = System.get_env("HUBS_ADMIN_INTERNAL_HOSTNAME", "hubs.local")
    hubs_client_internal_hostname = System.get_env("HUBS_CLIENT_INTERNAL_HOSTNAME", "hubs.local")
    spoke_internal_hostname = System.get_env("SPOKE_INTERNAL_HOSTNAME", "hubs.local")

    dialog_port =
      "DIALOG_PORT"
      |> System.get_env("4443")
      |> String.to_integer()

    perms_key =
      "-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEA1ySZnNhzLUZQSo5m7vjWMhq4cChla6M2yfpgWaL5eR/K7Qgrnm0a5u3gvvgNVcvtcAN/A7MWPUCrm+EE4AeBV/lJF6+JjFJ4iMcie76ufgmiRLwZIeD/1hc9SFj56OFpS/7ifnw62hLITqRbCezqiG/MkM7pGQt1I+Ba5KKuj9xZ9r5B0UntIiBjj3BJX5JxaFPC5K7Jdkh/Yjfm4jJhaknLCtb0vQI6TEgjFSs2NJTNp4gZFjh6xicDAZA/0el3JPW5ogyB6ZNH1A3MD0mAkWTqW+IJy4dNDhKcgXHcfIA6Vl0tJKdH5QLjYQ3OlJtcOU0HwU99mAabcx262bBDBwIDAQABAoIBAEPOPjfHpC09vupwjRJ+DIwIDd8TbDuLWiY4Kgu2KKg7E+q2q4Cn5FWp3S5y4UkMF445G9vfon+1lSBwv+eXlfVTFO1JHrHCAEkjccPMahRBFwpQuh8KWbdw5ZiaqlDyUgxojZvNrYKzbrwSYrrzF0ve6HsvKxoAmW+wMxViDGA8P1akSx3t8mlRrsjQspR0GJ63qgqFkBr8ZplcztEo6mSaQvSZg0RxBzMzlFc2CfknWU4V49Ze+gGMBmfAzDZSanHT2isy2znWHJI7SJLotaTpGuLnA0SwsRiwZFp9AFkUX4GzTMSBdoFXyIgyA2bHd4JErRRoGBVfmhMsv2QiyFkCgYEA+G9yLx0baAxDnu74UFl1DvX6Ijbl+nGLlFHQn+iX5fdGadIRDLG6f42RQrV5QjkBNxpCyRwPJSfBEVGfErkGJJNCoH+mCUcHtOBOlPF+fhj8F78MRYlEmzijOHkI9nd4g5VeWpLWXSpxW7uGiR5nRvQt+JV2tg4KMqbeDe77rDsCgYEA3bGj04QXgx+zvgoVy1MymjKXY/ILKKuq8IU5oKi5EGH2lQfijQKQQHMZyXjc4kgUzaA03cywmVI5RsAtA+kAdsTu3/wNefPYpdlP6Ab7/yQbooLVXi9MTX+y+afkfpPZyVgYHPLu7221iUhqzp4KKaYwh9bSN4a3w+wHhfBXs6UCgYEApQ296elHrRAA2RXhadiVOfRYU+TvVD2dw1O77JGmYYWwhVuoMiveQSI38P8KaeHfmdFbr6txsHjB/5Sfv9unZiNkL6e/Ewja6OPhsXjkVjiZO9mU+JnjN9EgN8PKHZ1wNtPFFR3bR5iMKarkDjNh4DUYWcBLV1bqlY5hlxZApMMCgYEAmNk+S7oZ/+Tep1sKtbnx/JB/AoDCItNhMx2XouZRWjNAsHXUREaNMHJrSBZVrInoFfGsIXRcGgmvxdD/+F8wW7Lhw3pjzD5Mk+RljGMsYTgC+aPc+mf/4rr1qd2Q05iaopBjZ6ozBM8OR82vHi+mcBrOAQoiu/fdQW69rSINRaUCgYEAiklwsl/9SF61AqzpadLIFBggLAE5utBnOjw7EMFB4+oUHOx4a0gN45EhbET5v8s76nC1Cy6SIIpIImU+6Gso2KPQGXd8h5T8EyM973DS/ollQlzCXDhmU6DH2t2V6BAqDFhY6aDJUN8kwE5sCtSqQnpeUiCV+nM9rbpuWLme/9c=-----END RSA PRIVATE KEY-----"
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

    config :ret, Ret.PermsToken, perms_key: perms_key

    config :ret, Ret.PageOriginWarmer,
      admin_page_origin: "https://#{hubs_admin_internal_hostname}:8989",
      hubs_page_origin: "https://#{hubs_client_internal_hostname}:8080",
      spoke_page_origin: "https://#{spoke_internal_hostname}:9090"

    config :ret, Ret.Repo, hostname: db_hostname

    config :ret, Ret.SessionLockRepo, hostname: db_hostname

  :test ->
    db_credentials = System.get_env("DB_CREDENTIALS", "admin")
    db_hostname = System.get_env("DB_HOST", "localhost")

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
