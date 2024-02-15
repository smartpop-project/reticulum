defmodule RetWeb.Api.V1.BelivvrNoticeController do
  use RetWeb, :controller

  # Limit to 1 TPS
  #plug RetWeb.Plugs.RateLimit

  #공지사항을 모든 공간에 전파한다.
  def create(conn, payload) do
    RetWeb.Endpoint.broadcast("belivvr", "all", payload)
    conn |> send_resp(200, "")
  end

  #공지사항을 해당 scene_id를 구독하는 모든 공간에 전파한다.
  def create_by_scene_id(conn, payload) do
    RetWeb.Endpoint.broadcast("belivvr", conn.params["scene_id"], payload)
    conn |> send_resp(200, "")
  end

  #공지사항을 해당 공간에만 전파한다.
  def create_by_hub_id(conn, payload) do
    RetWeb.Endpoint.broadcast("belivvr", conn.params["hub_id"], payload)
    conn |> send_resp(200, "")
  end
end
