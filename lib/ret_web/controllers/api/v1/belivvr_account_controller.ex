defmodule RetWeb.Api.V1.BelivvrAccountController do
  use RetWeb, :controller

  require Logger

  import Canada, only: [can?: 2]
  alias Ret.{Statix, LoginToken, Account, Crypto, Guardian}

  #이메일 인증 우회하기위해서 함수 추가.
  def create(conn, %{"email_id" => email_id} = param) do
    email = email_id
    account = email |> Account.account_for_email()
    account_disabled = account && account.state == :disabled

    if !account_disabled && (can?(nil, create_account(nil)) || !!account) do
      # Create token
      %LoginToken{token: token, payload_key: payload_key} = LoginToken.new_login_token_for_email(email)

      encrypted_payload = %{"email" => email} |> Poison.encode!() |> Crypto.encrypt(payload_key) |> :base64.encode()

      Statix.increment("ret.emails.auth.attempted", 1)

      case LoginToken.lookup_by_token(token) do
        %LoginToken{identifier_hash: identifier_hash, payload_key: payload_key} ->
          decrypted_payload = encrypted_payload |> :base64.decode() |> Ret.Crypto.decrypt(payload_key) |> Poison.decode!()

          credentials = credentials_and_payload(identifier_hash, decrypted_payload)

          LoginToken.expire(token)

          case Guardian.decode_and_verify(credentials) do
            {:ok, claims} ->
              conn |> send_resp(200, Jason.encode!(%{"status" => "ok", "token" => credentials, "account_id" =>  claims["sub"]}))

            {:error, _} ->
              conn
              |> put_status(401)
              |> json(%{error: "Unauthorized"})
          end
      end
    end
  end

  #토큰을 사용해서 account_id를 조회하기 위해서 추가.
  def show(conn, %{"token" => token} = param) do

    Logger.info(
      "allowed_origins :: #{ Application.get_env(:ret, RetWeb.Endpoint)[:allowed_origins]}"
    )

    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        claims["sub"]
        conn |> send_resp(200, Jason.encode!(%{"status" => "ok", "account_id" => claims["sub"]}))

      {:error, _} ->
        conn
        |> put_status(401)
        |> json(%{error: "Unauthorized"})
    end
  end

  defp credentials_and_payload(nil, _payload, _socket), do: nil

  defp credentials_and_payload(identifier_hash, payload) do
    account = identifier_hash |> Account.account_for_login_identifier_hash(can?(nil, create_account(nil)))
    credentials = account |> Account.credentials_for_account()

    credentials
  end
end
