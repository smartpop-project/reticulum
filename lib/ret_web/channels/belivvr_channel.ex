#공지사항 전파를 위한 빌리버 채널모듈_session_socket에 등록하여 사용
defmodule RetWeb.BelivvrChannel do

  use RetWeb, :channel

  alias Ret.{Account, Statix}
  alias RetWeb.{Presence}

  #클라이언트에서 해당 belivvr 토픽으로 구독하면 토큰을 사용해서 유저를 찾은다음 조인함.
  def join("belivvr", %{"token" => token}, socket) do
    case Ret.Guardian.resource_from_token(token) do
      {:ok, %Account{} = account, _claims} ->
        socket
        |> Guardian.Phoenix.Socket.put_current_resource(account)
        |> handle_join()

      {:error, reason} ->
        {:error, %{message: "Sign in failed", reason: reason}}
    end
  end

  #클라이언트에서 해당 토픽으로 구독하면 조인함.
  def join("belivvr", %{}, socket) do
    socket |> handle_join()
  end

  defp handle_join(socket) do
    Statix.increment("ret.belivvr.channels.joins.ok")

    send(self(), {:begin_tracking, socket.assigns.session_id})
    {:ok, %{session_id: socket.assigns.session_id}, socket}
  end
end
