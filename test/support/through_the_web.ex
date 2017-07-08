defmodule ThroughTheWeb do
  use Phoenix.ConnTest
  @endpoint Advisor.Web.Endpoint

  def answer!(conn, links, answers) do
    Enum.each(links, fn (link) ->
      conn
      |> login_as(link.person.name)
      |> post(link.link, answers)
    end)
  end

  def login_as(conn, name) when is_binary(name) do
    person = Advisor.Core.People.find_by(name: name)
    assign(conn, :user_id, person.id)
  end
  def login_as(conn, id) do
    assign(conn, :user_id, id)
  end
end
