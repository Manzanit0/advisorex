defmodule Advisor.Web.ProgressPage do
  use Advisor.Web, :controller
  alias Advisor.Core.{People, AdvisoryFinder, AnswerFinder, QuestionnaireFinder}

  plug  Advisor.Web.Authentication.Gatekeeper, only: :group_leads

  def index(conn, %{"id" => id}) do
    advisories = AdvisoryFinder.gather_for_questionnaire(id)
    questionnaire = QuestionnaireFinder.find(id)
    requester = People.find_by(id: questionnaire.requester_id)

    by_completion = advisories
                    |> AnswerFinder.gather
                    |> Enum.group_by(&(completed?(&1.answers, questionnaire)),
                                     &(People.find_by(&1.advisory)))

    completed = Map.get(by_completion, true, [])
    incomplete = Map.get(by_completion, false, [])

    render conn, "index.html", requester: requester,
                               completed: completed,
                               incomplete: incomplete,
                               all_complete:  incomplete == [],
                               questionnaire: questionnaire

  end

  defp completed?(answers, questionnaire) do
    length(answers) == length(questionnaire.question_ids)
  end
end