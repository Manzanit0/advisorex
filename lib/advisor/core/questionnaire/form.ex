defmodule Advisor.Core.Questionnaire.Form do
  alias Advisor.Core.People
  alias Advisor.Core.Questions.PhrasesCatalog

  def data_for(person) do
    everybody = People.everybody_but(person)
    group_leads = Enum.filter(everybody, fn person -> person.is_group_lead end)
    questions = PhrasesCatalog.all()

    # TODO: Try to eliminate the forced ordering
    {everybody, group_leads, questions}
  end
end
