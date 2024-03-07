defmodule RetWeb.HubObjectsController do
  alias Ret.{ Hub, Repo, RoomObject, Guardian, Account, OwnedFile }
  import Ecto.Query
  import Ecto.Changeset

  require Logger
  use RetWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "model/gltf+json; charset=utf-8")
    |> send_resp(200, "test")
  end

  def createNetworkId() do
    :rand.uniform(1_000_000_000)
      |> Integer.to_string(36)
      |> String.slice(0..6)
      |> String.downcase()
  end

  def hexRandom(bytes \\ 16) do
    :crypto.strong_rand_bytes(bytes)
    |> Base.encode16()
    |> String.downcase()
  end

  def getHub(hubSid) do
      Hub
      |> Repo.get_by(hub_sid: hubSid)
      |> Repo.preload([:hub_bindings, :hub_role_memberships])
  end

  def getJsonNode(networkId, file, position, rotation, scale, objectName) do
    hex = hexRandom()
    updated_scale = if String.ends_with?(file, ".glb") do
      Enum.map(scale, fn x -> x * 2 end)
    else
      scale
    end

    %{
      "extensions" => %{
        "HUBS_components" => %{
          "media" => %{
            "contentSubtype" => nil,
            "id" => networkId,
            "src" => "#{file}?token=#{hex}",
            "version" => 1
          },
          "pinnable" => %{"pinned" => true}
        }
      },
      "name" => objectName,
      "rotation" => rotation,
      "scale" => updated_scale,
      "translation" => position,
      "role" => "admin"
    }
  end

  def findEmptyFrame(json_str, objectName) do
    {:ok, data} = Jason.decode(json_str)
    entities = Map.get(data, "entities")

    entities
    |> Enum.find(fn {_key, value} ->
      Map.get(value, "name", []) == objectName
    end)
  end

  def getTransformProps(entity_details) do
    components = Map.get(entity_details, "components", [])

    transform_component = Enum.find(components, fn component ->
      Map.get(component, "name") == "transform"
    end)

    Map.get(transform_component, "props", %{})
  end

  def getTransfomation(entity_details) do
    props = getTransformProps(entity_details)

    position = Map.get(props, "position", %{})
    rotation = Map.get(props, "rotation", %{})
    scale = Map.get(props, "scale", %{})

    {position, rotation, scale}
  end

  def extractValuesFromList(list) do
    list
    |> Enum.into(%{})
    |> Map.values()
  end

  def euler_to_quaternion(roll, pitch, yaw) do
    cy = :math.cos(yaw * 0.5)
    sy = :math.sin(yaw * 0.5)
    cp = :math.cos(pitch * 0.5)
    sp = :math.sin(pitch * 0.5)
    cr = :math.cos(roll * 0.5)
    sr = :math.sin(roll * 0.5)

    w = cr * cp * cy + sr * sp * sy
    x = sr * cp * cy - cr * sp * sy
    y = cr * sp * cy + sr * cp * sy
    z = cr * cp * sy - sr * sp * cy

    [x, y, z, w]
  end

  def create(conn, %{"file" => file, "objectName" => objectName}) do
    conn = Plug.Conn.fetch_query_params(conn)
    auth_header = Plug.Conn.get_req_header(conn, "authorization")
    hubSid = conn.params["hubSid"]
    bearerToken = Enum.at(auth_header, 0)
    token = String.replace(bearerToken, "Bearer ", "")

    findHub =
        Hub
        |> Repo.get_by(hub_sid: hubSid)
        |> Repo.preload([:scene])

    case findHub do
      nil -> send_resp(conn, 404, "해당하는 허브를 찾을 수 없습니다.")
      _ ->
    end

    url = Application.get_env(:ret, Ret.Storage)[:host]
    ownedFileId = findHub.scene.scene_owned_file_id
    owendFile = OwnedFile
      |> Repo.get_by(owned_file_id: ownedFileId)
    owendFileUUID = owendFile.owned_file_uuid

    response = HTTPoison.get!("#{url}/files/#{owendFileUUID}.json")
    result = findEmptyFrame(response.body, objectName)

    case result do
      nil -> send_resp(conn, 404, "#{("#{objectName} 컴포넌트를 찾을 수 없습니다.")}")
      {entity_id, entity_details} ->
      end

    {entity_id, entity_details} = result
    {position, rotation, scale} = getTransfomation(entity_details)
    mapPosition = extractValuesFromList(position)
    mapRotation = extractValuesFromList(rotation)
    mapScale = extractValuesFromList(scale)
    [x, y, z] = mapRotation

    quaternionRotation = euler_to_quaternion(x, y, z)

    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        networkId = createNetworkId()
        gltf_node = getJsonNode(networkId, file, mapPosition, quaternionRotation, mapScale, objectName)
        hub = getHub(hubSid)
        account = Account
          |> Repo.get_by(account_id: claims["sub"])

        RoomObject.perform_pin!(hub, account, %{object_id: networkId, gltf_node: gltf_node})

        conn
        |> send_resp(201, "")

      {:error, _} ->
        conn
        |> put_status(401)
        |> json(%{error: "Unauthorized token"})
    end
  end

  @spec getAll(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def getAll(conn, _params) do
    conn = Plug.Conn.fetch_query_params(conn)
    url = Application.get_env(:ret, Ret.Storage)[:host]
    hubSid = conn.params["hubSid"]
    response = HTTPoison.get!("#{url}/#{hubSid}/objects.gltf")

    if response.body === "bad Room ID" do
      conn
      |> send_resp(404, "해당하는 허브를 찾을 수 없습니다.")
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response.body)
    end
  end

  def removeObject(conn, %{"objectId" => objectId}) do
    conn = Plug.Conn.fetch_query_params(conn)
    authHeader = Plug.Conn.get_req_header(conn, "authorization")
    bearerToken = Enum.at(authHeader, 0)
    token = String.replace(bearerToken, "Bearer ", "")
    hubSid = conn.params["hubSid"]

    Logger.info("conn: #{inspect(conn, pretty: true)}")


    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        hub = getHub(hubSid)
        target =
        Repo.one(
          from object in RoomObject,
            where: object.hub_id == ^hub.hub_id,
            where: object.object_id == ^objectId,
            preload: [:hub]
        )

        case target do
          nil -> conn
          |> send_resp(404, "해당하는 오브젝트를 찾을 수 없습니다.")
          _ ->
            RoomObject.perform_unpin(hub, objectId)
            conn
            |> send_resp(200, "")
        end

      {:error, _} ->
        conn
        |> put_status(401)
        |> json(%{error: "Unauthorized token"})
    end
  end
end
