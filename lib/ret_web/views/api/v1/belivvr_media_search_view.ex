defmodule RetWeb.Api.V1.BelivvrMediaSearchView do
  use RetWeb, :view

  def render("index.json", %{results: results}) do
    results
  end
end