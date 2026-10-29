defmodule CinderUI.Docs.SampleData do
  @moduledoc false

  @characters [
                {"fry", "Philip J. Fry", "Delivery boy", "Planet Express", "human courier"},
                {"leela", "Turanga Leela", "Ship captain", "Planet Express", "mutant pilot"},
                {"bender", "Bender Rodríguez", "Bending unit", "Planet Express", "robot bending"},
                {"amy", "Amy Wong", "Engineering intern", "Planet Express", "human engineer"},
                {"hermes", "Hermes Conrad", "Bureaucrat", "Planet Express", "human accountant"},
                {"zoidberg", "Dr. John Zoidberg", "Staff physician", "Planet Express",
                 "decapodian doctor"},
                {"farnsworth", "Professor Farnsworth", "Scientist", "Planet Express",
                 "human inventor hubert"},
                {"scruffy", "Scruffy", "Janitor", "Planet Express", "human maintenance"},
                {"nibbler", "Nibbler", "Ambassador", "Planet Express", "nibblonian intelligence"},
                {"zapp", "Zapp Brannigan", "Starship captain", "DOOP", "human commander"},
                {"kif", "Kif Kroker", "Lieutenant", "DOOP", "amphibiosan officer"},
                {"mom", "Mom", "Chief executive", "MomCorp", "human carol miller"},
                {"calculon", "Calculon", "Actor", "Entertainment", "robot television"},
                {"morbo", "Morbo", "News anchor", "Entertainment", "alien television"},
                {"elzar", "Elzar", "Chef", "Entertainment", "neptunian restaurant"},
                {"lrrr", "Lrrr", "Ruler", "Omicron Persei 8", "omicronian leader"},
                {"ndnd", "Ndnd", "Ruler", "Omicron Persei 8", "omicronian leader"},
                {"robot-devil", "Robot Devil", "Musician", "Robot community",
                 "robot beelzebot violin"},
                {"robot-santa", "Robot Santa", "Gift inspector", "Robot community",
                 "robot holidays"},
                {"hedonismbot", "Hedonismbot", "Patron of the arts", "Robot community",
                 "robot opera"},
                {"flexo", "Flexo", "Bending unit", "Robot community", "robot bending"},
                {"roberto", "Roberto", "Bank robber", "Robot community", "robot"},
                {"donbot", "Donbot", "Robot Mafia boss", "Robot community", "robot leader"},
                {"clamps", "Clamps", "Robot Mafia enforcer", "Robot community", "robot francis"}
              ]
              |> Enum.with_index()
              |> Enum.map(fn {{id, label, description, group, terms}, index} ->
                avatar_path = Path.expand("../../../assets/docs/avatars/#{id}.webp", __DIR__)
                @external_resource avatar_path

                %{
                  id: id,
                  avatar: "data:image/webp;base64," <> Base.encode64(File.read!(avatar_path)),
                  label: label,
                  description: description,
                  group: group,
                  keywords: [description, group | String.split(terms)],
                  email: "#{id}@planetexpress.example",
                  status: Enum.at([:active, :away, :offline], rem(index, 3))
                }
              end)

  def characters, do: @characters
  def crew, do: Enum.filter(@characters, &(&1.group == "Planet Express"))

  def countries do
    for {id, label} <- [
        {"au", "Australia"},
        {"nz", "New Zealand"},
        {"us", "United States"},
        {"ca", "Canada"},
        {"gb", "United Kingdom"},
        {"de", "Germany"},
        {"fr", "France"},
        {"jp", "Japan"},
        {"in", "India"},
        {"br", "Brazil"},
        {"mx", "Mexico"},
        {"za", "South Africa"}
        ],
        do: %{id: id, label: label}
  end

  def orders do
    for {character, id} <- Enum.with_index(@characters, 1001) do
      %{
        id: id,
        number: "ORD-#{id}",
        customer: character.label,
        status: if(rem(id, 3) == 0, do: :pending, else: :paid),
        total: "$#{48 + rem(id * 37, 300)}.00"
      }
    end
  end
end
