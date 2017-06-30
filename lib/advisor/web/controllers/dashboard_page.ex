defmodule Advisor.Web.DashboardPage do
  use Advisor.Web, :controller
  alias Advisor.Core.People
  alias Advisor.Web.Authentication.User
  alias Advisor.Core.Questionnaire
  alias Advisor.Core.Dashboard

  plug Advisor.Web.Authentication.Gatekeeper

  def index(conn, _params) do
    viewer = User.of(conn)
    group_lead_section = Dashboard.group_lead_section(viewer)
    render conn, "index.html", viewer: viewer,
                               group_lead_section: group_lead_section,
                               person: People.find_by(name: "Uku Taht")
  end
end
