defmodule Ret.Account do
  use Ecto.Schema
  require Logger

  import Ecto.Query

  alias Ret.{Repo, Account, Identity, Login, Guardian}

  import Canada, only: [can?: 2]

  @type id :: pos_integer
  @type t :: %__MODULE__{}

  @account_preloads [:login, :identity]

  @schema_prefix "ret0"
  @primary_key {:account_id, :id, autogenerate: true}
  schema "accounts" do
    field :min_token_issued_at, :utc_datetime
    field :is_admin, :boolean
    field :state, Account.State

    has_one :login, Login, foreign_key: :account_id
    has_one :identity, Identity, foreign_key: :account_id

    has_many :owned_files, Ret.OwnedFile, foreign_key: :account_id
    has_many :created_hubs, Ret.Hub, foreign_key: :created_by_account_id
    has_many :oauth_providers, Ret.OAuthProvider, foreign_key: :account_id
    has_many :projects, Ret.Project, foreign_key: :created_by_account_id
    has_many :assets, Ret.Asset, foreign_key: :account_id

    timestamps()
  end

  def query do
    from(Account)
  end

  def where_account_id_is(query, id) do
    from account in query, where: account.account_id == ^id
  end

  def has_accounts?,
    do: Repo.exists?(Account)

  def has_admin_accounts?,
    do: Repo.exists?(from a in Account, where: a.is_admin)

  def exists_for_email?(email), do: account_for_email(email) != nil

  def account_for_email(email, create_if_not_exists \\ false) do
    email |> identifier_hash_for_email |> account_for_login_identifier_hash(create_if_not_exists)
  end

  def find_or_create_account_for_email(email), do: account_for_email(email, true)

  def account_for_login_identifier_hash(identifier_hash, create_if_not_exists \\ false) do
    Logger.info("Looking up login for identifier hash: #{identifier_hash}")  # identifier_hash 조회 로그
    login = Repo.one(from l in Login, where: l.identifier_hash == ^identifier_hash)

    Logger.info("login: #{inspect(login)}")  # identifier_hash 조회 로그

    cond do
      login != nil ->
        Account |> Repo.get(login.account_id) |> Repo.preload(@account_preloads)


      create_if_not_exists === true ->
        # Set the account to be an administrator if admin_email matches
        is_admin =
          with admin_email when is_binary(admin_email) <- module_config(:admin_email) do
            identifier_hash === admin_email |> identifier_hash_for_email
          else
            _ -> false
          end
        Logger.info("is_admin: #{inspect(is_admin)}")  # is_admin 로그
        Repo.insert!(%Account{login: %Login{identifier_hash: identifier_hash}, is_admin: is_admin})

      true ->
        nil
    end

  end

  def credentials_for_account(nil), do: nil

  def credentials_for_account(account) do
    Logger.info("Generating JWT for account: #{inspect(account)}")  # 입력 account 로그

    {:ok, token, _claims} = account |> Guardian.encode_and_sign()

    Logger.info("Generated JWT token: #{token}")  # 출력 token 로그
    token
  end

  def identifier_hash_for_email(email) do
    email |> String.downcase() |> Ret.Crypto.hash()
  end

  def get_global_perms_for_account(account), do: %{} |> add_global_perms_for_account(account)

  def add_global_perms_for_account(perms, account) do
    perms
    |> Map.put(:tweet, !!oauth_provider_for_source(account, :twitter))
    |> Map.put(:create_hub, account |> can?(create_hub(nil)))
    |> maybe_add_global_admin_perms_for_account(account)
  end

  def maybe_add_global_admin_perms_for_account(perms, %Ret.Account{is_admin: true}) do
    perms
    |> Map.put(:postgrest_role, :ret_admin)
  end

  def maybe_add_global_admin_perms_for_account(perms, _account), do: perms

  def matching_oauth_providers(nil, _), do: []
  def matching_oauth_providers(_, nil), do: []

  def matching_oauth_providers(%Ret.Account{} = account, %Ret.Hub{} = hub) do
    account.oauth_providers
    |> Enum.filter(fn provider ->
      hub.hub_bindings |> Enum.any?(&(&1.type == provider.source))
    end)
  end

  def oauth_provider_for_source(%Ret.Account{} = account, oauth_provider_source)
      when is_atom(oauth_provider_source) do
    account.oauth_providers
    |> Enum.find(fn provider ->
      provider.source == oauth_provider_source
    end)
  end

  def oauth_provider_for_source(nil, _source), do: nil

  def set_identity!(%Account{} = account, name) do
    account
    |> revoke_identity!
    |> Identity.changeset_for_new(%{name: name})
    |> Repo.insert!()

    Repo.preload(account, @account_preloads, force: true)
  end

  def revoke_identity!(%Account{account_id: account_id} = account) do
    Repo.delete_all(from i in Identity, where: i.account_id == ^account_id)
    Repo.preload(account, @account_preloads, force: true)
  end

  defp module_config(key) do
    Application.get_env(:ret, __MODULE__)[key]
  end
end
