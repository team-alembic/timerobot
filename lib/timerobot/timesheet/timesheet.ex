defmodule Timerobot.Timesheet do
  @moduledoc """
  The boundary for the Timesheet system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Timerobot.Repo

  alias Timerobot.Timesheet.Client
  alias Timerobot.Timesheet.Project
  alias Timerobot.Timesheet.Person
  alias Timerobot.Timesheet.Entry

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def all_clients do
    Client
    |> order_by([c], c.name)
    |> Repo.all
  end

  def all_clients_dropdown do
    Client
    |> select([c], {c.name, c.id})
    |> order_by([c], c.name)
    |> Repo.all
  end

  @doc """
  Gets a single client.

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

  """
  def get_client!(slug) do
    Client
    |> preload([:projects, entries: [:person, :project]])
    |> Repo.get_by!(slug: slug)
  end

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    slug = Slugger.slugify_downcase(attrs["name"])

    %Client{}
    |> client_changeset(Map.put(attrs, "slug", slug))
    |> Repo.insert()
  end

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> client_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Client.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{source: %Client{}}

  """
  def change_client(%Client{} = client) do
    client_changeset(client, %{})
  end

  defp client_changeset(%Client{} = client, attrs) do
    client
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  @doc """
  Returns the list of project.

  ## Examples

      iex> list_project()
      [%Project{}, ...]

  """
  def all_projects do
    Project
    |> order_by([p], [p.client_id, p.name])
    |> preload([:client, :entries])
    |> Repo.all
  end

  def all_projects_dropdown do
    Project
    |> join(:inner, [p], c in assoc(p, :client), p.client_id == c.id)
    |> select([p, c], {c.name, p.name, p.id})
    |> order_by([p, c], [c.name, p.name])
    |> Repo.all
    |> Enum.map(fn({client_name, project_name, project_id}) ->
      {"#{client_name} / #{project_name}", project_id}
    end)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(slug) do
    Project
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:client, entries: [:person]])
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    slug = Slugger.slugify_downcase(attrs["name"])

    %Project{}
    |> project_changeset(Map.put(attrs, "slug", slug))
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> project_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    project_changeset(project, %{})
  end

  def change_project(%Project{} = project, attrs) do
    project_changeset(project, attrs)
  end

  defp project_changeset(%Project{} = project, attrs) do
    project
    |> cast(attrs, [:name, :slug, :client_id])
    |> validate_required([:name, :slug, :client_id])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  @doc """
  Returns the list of person.

  ## Examples

      iex> list_person()
      [%Person{}, ...]

  """
  def list_person do
    Person
    |> order_by([p], p.name)
    |> Repo.all
  end

  def all_people_dropdown do
    Person
    |> select([p], {p.name, p.id})
    |> order_by([p], p.name)
    |> Repo.all
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person!(slug) do
    Person
    |> Repo.get_by!(slug: slug)
    |> Repo.preload(entries: [:project])
  end

  @doc """
  Creates a person.

  ## Examples

      iex> create_person(%{field: value})
      {:ok, %Person{}}

      iex> create_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person(attrs \\ %{}) do
    slug = Slugger.slugify_downcase(attrs["name"])

    %Person{}
    |> person_changeset(Map.put(attrs, "slug", slug))
    |> Repo.insert()
  end

  @doc """
  Updates a person.

  ## Examples

      iex> update_person(person, %{field: new_value})
      {:ok, %Person{}}

      iex> update_person(person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person(%Person{} = person, attrs) do
    person
    |> person_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Person.

  ## Examples

      iex> delete_person(person)
      {:ok, %Person{}}

      iex> delete_person(person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person(person)
      %Ecto.Changeset{source: %Person{}}

  """
  def change_person(%Person{} = person) do
    person_changeset(person, %{})
  end

  defp person_changeset(%Person{} = person, attrs) do
    person
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> cast(attrs, ~w(password)a)
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset,
                  :encrypted_password,
                  Comeonin.Bcrypt.hashpwsalt(password))
        _ -> changeset
    end
  end

  @doc """
  Returns the list of entry.

  ## Examples

      iex> list_entry()
      [%Entry{}, ...]

  """
  def list_entry do
    Entry
    |> preload([[project: :client], :person])
    |> order_by([e], desc: e.date)
    |> order_by([e], e.project_id)
    |> Repo.all
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id) do
    Entry
    |> Repo.get!(id)
    |> Repo.preload([:project, :person])
  end

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> entry_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> entry_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{source: %Entry{}}

  """
  def change_entry(%Entry{} = entry) do
    entry_changeset(entry, %{})
  end

  def change_entry(%Entry{} = entry, attrs) do
    entry_changeset(entry, attrs)
  end

  defp entry_changeset(%Entry{} = entry, attrs) do
    entry
    |> cast(attrs, [:date, :hours, :person_id, :project_id])
    |> validate_required([:date, :hours, :person_id, :project_id])
  end

  def weeks(num_weeks \\ 3) do
    {bow, _} = week_for_date(Timex.now)
    0..num_weeks-1 |> Enum.map(fn offset ->
      Timex.shift(bow, weeks: -offset)
    end)
    |> Enum.map(&Timex.to_date/1)
    |> Enum.map(fn(date) -> {Timex.format!(date, "{WDfull} {D} {Mfull} {YYYY}"), to_string(date)} end)
  end

  def week_for_date(date) do
    beginning_of_week = Timex.beginning_of_week(date, :mon)
    end_of_week = Timex.shift(beginning_of_week, days: 6)
    {beginning_of_week, end_of_week}
  end

  def entries_for_week(date) do
    {beginning_of_week, end_of_week} = week_for_date(date)
    Entry
    |> preload([[project: :client], :person])
    |> where([e], e.date >= ^beginning_of_week and e.date <= ^end_of_week)
    |> Repo.all
  end

  def entries_for_report(entries) do
    entries
    |> Enum.group_by(& &1.project, &{&1.person.name, &1.hours})
    |> Enum.map(fn {project, times} ->
      {
        project,
        Enum.group_by(times,
          fn {p, _hours} -> p end,
          fn {_p, hours} -> hours end
        ) |> Enum.map(fn {p, hours} -> {p, Enum.sum(hours)} end)
      }
    end)
    |> Enum.group_by(& elem(&1, 0).client.name)
  end

  def entries_for_person(entries) do
    entries
    |> Enum.group_by(&Timex.beginning_of_week(&1.date), &{&1.project, &1.date, &1.hours})
    |> Enum.map(fn {week, times} ->
      {
        week,
        Enum.group_by(times,
          fn {p, date, _hours} -> {p, date} end,
          fn {_p, _date, hours} -> hours end
        )
        |> Enum.map(fn {{p, date}, hours} ->
          {date, p, Enum.sum(hours)}
        end)
        |> Enum.sort_by(fn {date, _, _} -> to_string(date) end, &</2)
      }
    end)
    |> Enum.sort_by(fn {bow, _} -> to_string(bow) end, &>=/2)
  end

  def entries_for_project(entries) do
    entries
    |> Enum.group_by(&Timex.beginning_of_week(&1.date), &{&1.person, &1.date, &1.hours})
    |> Enum.map(fn {week, times} ->
      {
        week,
        Enum.group_by(times,
          fn {p, date, _hours} -> {p, date} end,
          fn {_p, _date, hours} -> hours end
        )
        |> Enum.map(fn {{p, date}, hours} ->
          {date, p, Enum.sum(hours)}
        end)
        |> Enum.sort_by(fn {date, _, _} -> to_string(date) end, &</2)
      }
    end)
    |> Enum.sort_by(fn {bow, _} -> to_string(bow) end, &>=/2)
  end

  def entry_index_sort(entries) do
    entries
    |> Enum.group_by(&Timex.beginning_of_week(&1.date))
    |> Enum.sort_by(fn {bow, _entries} -> to_string(bow) end, &>=/2)
  end

  def sort_person_entries(slug) do
    get_person!(slug).entries
    |> entries_for_person
  end

  def sort_project_entries(slug) do
    get_project!(slug).entries
    |> entries_for_project
  end

  def sort_client_entries(slug) do
    get_client!(slug).entries
    |> entries_for_project
  end

  def sort_entries() do
    list_entry()
    |> entry_index_sort
  end

  def calculate_totals(times) do
    times
    |> Enum.reduce(0, fn({_date, _project, hours}, sum) -> sum + hours end)
  end

  @default_hours_in_day 8
  @granularity 4

  def calculate_days(times, hours_in_day \\ @default_hours_in_day, granularity \\ @granularity) do
    hours = calculate_totals(times)
    days = hours/hours_in_day
    Float.ceil(days * granularity) / granularity
  end

  def total_project_hours(client_slug) do
    from(
      p in "timesheet_project",
      join: e in "timesheet_entry", on: e.project_id == p.id,
      join: c in "timesheet_client", on: p.client_id == c.id,
      where: c.slug == ^client_slug,
      group_by: [c.slug, p.name, p.slug],
      select: {
        p.name,
        p.slug,
        sum(e.hours)
      }
    )
    |> Timerobot.Repo.all
  end

  def total_client_hours(project_list) do
    project_list
    |> Enum.reduce(0, fn({_name, _slug, hours}, sum) -> sum + hours end)
  end

  def project_days(count, hours_in_day \\ @default_hours_in_day, granularity \\ @granularity) do
    days = count/hours_in_day
    Float.ceil(days * granularity) / granularity
  end
end
