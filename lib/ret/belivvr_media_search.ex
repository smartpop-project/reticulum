defmodule Ret.BelivvrMediaHubSearchQuery do
  @enforce_keys [:source]
  defstruct [:source, :type, :user, :collection, :filter, :q, :similar_to, :cursor, :page_size, :locale, :scene_sid, :hub_sids, :allow_remixing, :account_id, :name]
end

defmodule Ret.BelivvrMediaSearch do

  require Logger

  import Ret.HttpUtils
  import Ecto.Query

  alias Ret.{
    AccountFavorite,
    Asset,
    Avatar,
    AvatarListing,
    Hub,
    OwnedFile,
    Project,
    Repo,
    Scene,
    SceneListing,
    MediaSearchQuery,
    MediaSearchResult,
    MediaSearchResultMeta
  }


  @page_size 10
  # HACK for now to reduce page size for scene listings -- real fix will be to expose page_size to API
  @scene_page_size 23
  @max_face_count 60000
  @max_collection_face_count 200_000

  def search(%Ret.BelivvrMediaHubSearchQuery{source: "rooms", cursor: cursor, page_size: page_size, scene_sid: scene_sid, hub_sids: hub_sids}) do
    cursor = cursor |> Integer.parse() |> elem(0)
    page_size = page_size |> Integer.parse() |> elem(0)

    ecto_query =
      from h in Hub,
        left_join: scene in Scene, on: h.scene_id == scene.scene_id,
        preload: [
          scene: [:screenshot_owned_file],
          scene_listing: [:scene, :screenshot_owned_file]
        ],
        order_by: [desc: :inserted_at]

    results =
      ecto_query
      |> add_scene_sid_filter(scene_sid)
      |> add_hub_sid_filter(hub_sids)
      |> Repo.paginate(%{page: cursor, page_size: page_size})
      |> result_for_page(cursor, :rooms, &hub_to_entry/1)

    {:commit, results}
  end

  def search(%Ret.BelivvrMediaHubSearchQuery{source: "scenes", cursor: cursor, page_size: page_size, account_id: account_id, allow_remixing: allow_remixing, name: name}) do
    cursor = cursor |> Integer.parse() |> elem(0)
    page_size = page_size |> Integer.parse() |> elem(0)

    ecto_query =
      if name do
        from s in Scene,
          where: s.account_id == ^account_id and ilike(s.name, ^"%#{name}%"),
          preload: [:screenshot_owned_file, :model_owned_file, :scene_owned_file, :project]
      else
        from s in Scene,
          where: s.account_id == ^account_id,
          preload: [:screenshot_owned_file, :model_owned_file, :scene_owned_file, :project]
      end

    # 여기에서 변경된 ecto_query를 콘솔에 출력합니다.
    IO.inspect(ecto_query, label: "Generated Query After")

    results =
      ecto_query
      |> add_allow_remixing_filter(allow_remixing)
      |> Repo.paginate(%{page: cursor, page_size: page_size})
      |> result_for_page(cursor, :scenes, &scene_or_scene_listing_to_entry/1)

    {:commit, results}
  end

  defp result_for_page(page, page_number, source, entry_fn) do
    %Ret.MediaSearchResult{
      meta: %Ret.MediaSearchResultMeta{
        next_cursor:
          if page.total_pages > page_number do
            page_number + 1
          else
            nil
          end,
        source: source
      },
      entries:
        page.entries
        |> Enum.map(entry_fn)
    }
  end

  defp hub_to_entry(%Hub{} = hub) when hub != nil do
    scene_or_scene_listing = hub.scene || hub.scene_listing

    images =
      if scene_or_scene_listing do
        %{
          preview: %{
            url:
              scene_or_scene_listing.screenshot_owned_file
              |> OwnedFile.uri_for()
              |> URI.to_string()
          }
        }
      else
        %{preview: %{url: "#{RetWeb.Endpoint.url()}/app-thumbnail.png"}}
      end

    scene_id =
      if scene_or_scene_listing do
        Scene.to_sid(scene_or_scene_listing)
      else
        nil
      end

    %{
      id: hub.hub_sid,
      url: hub |> Hub.url_for(),
      type: :room,
      room_size: hub |> Hub.room_size_for(),
      member_count: hub |> Hub.member_count_for(),
      lobby_count: hub |> Hub.lobby_count_for(),
      name: hub.name,
      description: hub.description,
      scene_id: scene_id,
      user_data: hub.user_data,
      images: images
    }
  end

  defp scene_or_scene_listing_to_entry(s) do
    %{
      id: s |> Scene.to_sid(),
      url: s |> Scene.to_url(),
      type: :scene,
      name: s.name,
      description: s.description,
      attributions: s.attributions,
      project_id: s.project |> Project.to_sid(),
      images: %{
        preview: %{url: s.screenshot_owned_file |> OwnedFile.uri_for() |> URI.to_string()}
      }
    }
  end

  defp add_scene_sid_filter(query, nil), do: query

  defp add_scene_sid_filter(query, scene_sid) do
    query |> where([h, scene], scene.scene_sid == ^scene_sid)
  end

  defp add_hub_sid_filter(query, nil), do: query

  defp add_hub_sid_filter(query, hub_sids) do
    hub_sids = String.split(hub_sids, ",")
    where(query, [h], h.hub_sid in ^hub_sids)
  end

  defp add_allow_remixing_filter(query, nil), do: query

  defp add_allow_remixing_filter(query, allow_remixing) do
    query |> where([s], s.allow_remixing == ^allow_remixing)
  end

end
