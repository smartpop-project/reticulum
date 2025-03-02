defmodule RetWeb.SessionSocket do
  use Phoenix.Socket

  channel "ret", RetWeb.RetChannel
  channel "hub:*", RetWeb.HubChannel
  channel "link:*", RetWeb.LinkChannel
  channel "auth:*", RetWeb.AuthChannel
  #빌리버용 채널 등록(웹소켓을 사용하여 공간,씬, 전체 공지사항을 채팅에서 보여주기 위함.)
  channel "belivvr", RetWeb.BelivvrChannel

  def id(socket) do
    "session:#{socket.assigns.session_id}"
  end

  def connect(%{"session_token" => session_token, "user_agent" => user_agent, "ip" => ip}, socket) do
    socket =
      socket
      |> assign(:session_id, session_token |> session_id_for_token || generate_session_id())
      |> assign(:started_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
      |> assign(:user_agent, user_agent)
      |> assign(:ip, ip)

    {:ok, socket}
  end

  def connect(%{}, socket) do
    socket =
      socket
      |> assign(:session_id, generate_session_id())
      |> assign(:started_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))

    {:ok, socket}
  end

  defp session_id_for_token(session_token) do
    case session_token |> Ret.SessionToken.decode_and_verify() do
      {:ok, %{"session_id" => session_id}} -> session_id
      _ -> nil
    end
  end

  defp generate_session_id(), do: SecureRandom.uuid()
end
