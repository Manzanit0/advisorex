defmodule Advisor.Web.ProgressPageTest do
  use Advisor.Web.ConnCase
  alias Advisor.Web.QuestionnaireProposal, as: Proposal
  alias Advisor.Web.Links
  alias Advisor.Core.Creator

  @sample_questions [5, 6]

  setup do
    proposal = Proposal.build(for: "Rabea Gleissner",
                              advisors: ["Chris Jordan", "Priya Patil"],
                              group_lead: "Felipe Sere",
                              questions: @sample_questions)
    [proposal: proposal]
  end

  test "shows the progress filling in the questionnaires", %{conn: conn,
                                                             proposal: proposal} do
    {_, progress_page} = proposal
                         |> Creator.create
                         |> Links.generate

    conn
    |> login_as("Felipe Sere")
    |> get(progress_page)
    |> html_response(200)
    |> has_requester("Rabea Gleissner")
    |> has_advisors(["Chris Jordan", "Priya Patil"])
  end

  test "shows that an advisors has completed the advice form", %{conn: conn,
                                                                 proposal: proposal} do
    proposal =  %{proposal | questions: [1]}
    {[%{link: link} | _], progress_page} = proposal
                                           |> Creator.create
                                           |> Links.generate

    conn
    |> login_as("Chris Jordan")
    |> post(link, ["1": "someting"])

    conn
    |> login_as("Felipe Sere")
    |> get(progress_page)
    |> html_response(200)
    |> has_completed_advice()
    |> has_continue_button_with("Waiting for further responses")
  end

  test "all completed feedback", %{conn: conn, proposal: proposal} do
    {[%{link: cj}, %{link: priya}], progress_page} = proposal
                                                    |> Creator.create
                                                    |> Links.generate

    answers = ["1": "something", "2": "else"]

    conn
    |> login_as("Chris Jordan")
    |> post(cj, answers)

    conn
    |> login_as("Priya Patil")
    |> post(priya, answers)

    conn
    |> login_as("Felipe Sere")
    |> get(progress_page)
    |> html_response(200)
    |> has_continue_button_with("We are good to go")
  end

  def has_continue_button_with(html, text) do
    button = html
             |> Floki.find(".button")
             |> Floki.text

    assert button =~ text
    html
  end

  def has_requester(html, requester_name) do
    assert requester(html) =~ requester_name
    html
  end

  def has_advisors(html, advisors_names) do
    assert advisors(html) == advisors_names
    html
  end

  def has_completed_advice(html) do
    assert html
           |> Floki.find(".completeness")
           |> Enum.map(&Floki.text/1)
           |> Enum.any?(&(&1 =~ "Completed"))

    html
  end

  def requester(html) do
    html
    |> Floki.find(".progress-requester")
    |> Floki.text
  end

  def advisors(html) do
    html
    |> Floki.find(".advisor")
    |> Enum.map(&Floki.text/1)
  end
end