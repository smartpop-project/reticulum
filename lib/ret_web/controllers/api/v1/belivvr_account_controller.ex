defmodule RetWeb.Api.V1.BelivvrAccountController do
  use RetWeb, :controller

  require Logger

  import Canada, only: [can?: 2]
  alias Ret.{Statix, LoginToken, Account, Crypto, Guardian}

  #이메일 인증 우회하기위해서 함수 추가.
  def create(conn, %{"email_id" => email_id} = param) do
    Logger.info("\nReceived email_id: #{email_id}\n")  # 이메일 ID 수신 로그
    email = email_id
    account = email |> Account.account_for_email()

    Logger.info("Account lookup for email: #{email}")  # 계정 조회 로그
    account_disabled = account && account.state == :disabled

    if !account_disabled && (can?(nil, create_account(nil)) || !!account) do
      Logger.info("Account is valid and not disabled.")  # 계정 유효성 확인 로그

      # Create token
      %LoginToken{token: token, payload_key: payload_key} = LoginToken.new_login_token_for_email(email)
      Logger.info("Generated token for email: #{email}")  # 토큰 생성 로그

      encrypted_payload = %{"email" => email} |> Poison.encode!() |> Crypto.encrypt(payload_key) |> :base64.encode()
      Logger.info("Encrypted payload for email: #{email}")  # 암호화된 페이로드 로그

      Statix.increment("ret.emails.auth.attempted", 1)

      case LoginToken.lookup_by_token(token) do
        %LoginToken{identifier_hash: identifier_hash, payload_key: payload_key} ->
          Logger.info("Token lookup successful. Identifier hash: #{identifier_hash}")  # 토큰 조회 성공 로그

          decrypted_payload = encrypted_payload |> :base64.decode() |> Ret.Crypto.decrypt(payload_key) |> Poison.decode!()
          Logger.info("Decrypted payload: #{inspect(decrypted_payload)}")  # 복호화된 페이로드 로그
          Logger.info("Credentials generated for identifier hash: #{identifier_hash}")  # 자격 증명 생성 로그

          credentials = credentials_and_payload(identifier_hash, decrypted_payload)

          Logger.info("Credentialsh: #{credentials}")  #

          LoginToken.expire(token)
          Logger.info("Token expired: #{token}")  # 토큰 만료 로그

          case Guardian.decode_and_verify(credentials) do
            {:ok, claims} ->
              Logger.info("\nToken successfully decoded. Claims: #{inspect(claims)}")  # 토큰 디코딩 성공 로그
              Logger.info("Token: #{inspect(credentials)}")  # 토큰 로그
              Logger.info("Account ID: #{inspect(claims["sub"])}\n")  # 계정 ID 로그

              conn |> send_resp(200, Jason.encode!(%{"status" => "ok", "token" => credentials, "account_id" => claims["sub"]}))

            {:error, _} ->
              Logger.error("Failed to decode token. Unauthorized access attempt.")  # 토큰 디코딩 실패 로그
              conn
              |> put_status(401)
              |> json(%{error: "Unauthorized"})
          end
        _ ->
          Logger.error("Token lookup failed. Invalid token.")  # 토큰 조회 실패 로그
          conn
          |> put_status(401)
          |> json(%{error: "Unauthorized"})
      end
    else
      Logger.error("Account is disabled or invalid.")  # 계정이 비활성화되었거나 유효하지 않음 로그
      conn
      |> put_status(401)
      |> json(%{error: "Unauthorized"})
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
    Logger.info("Received identifier hash: #{inspect(identifier_hash)}")  # identifier_hash 로그

    # account 조회
    account = identifier_hash |> Account.account_for_login_identifier_hash(can?(nil, create_account(nil)))

    if account do

      Logger.info("Account found for identifier hash: #{inspect(identifier_hash)}")  # 계정 조회 성공 로그

      # credentials 생성
      Logger.info("account: #{inspect(account)}")
      credentials = account |> Account.credentials_for_account()
      Logger.info("Generated credentials for account: #{inspect(credentials)}")  # 생성된 자격 증명 로그

      credentials
    else
      Logger.error("No account found for identifier hash: #{inspect(identifier_hash)}")  # 계정 없음 로그
      nil
    end
  end
end
