defmodule Formex.Type do

  @moduledoc """
  In order to create a form, you need to create the Type file. It's similar to
  [Symfony's](https://symfony.com/doc/current/forms.html#creating-form-classes)
  way of creating forms.

  Example:

  ```
  defmodule App.ArticleType do
    use Formex.Type
    alias Formex.CustomField.SelectAssoc

    def build_form(form) do
      form
      |> add(:text_input, :title, label: "Title")
      |> add(:textarea, :content, label: "Content", phoenix_opts: [
        rows: 4
      ])
      |> add(:checkbox, :hidden, label: "Is hidden", required: false)
      |> add(SelectAssoc, :category_id, label: "Category", phoenix_opts: [
        prompt: "Choose category"
      ])
    end

    # optional
    def changeset_after_create_callback(changeset) do
      # do extra validation and return a new changeset
      changeset
    end
  end
  ```
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Type

      def changeset_after_create_callback( changeset ) do
        changeset
      end

      def add(form, type_or_module, name, opts) do

        # check if type_or_module is atom or module
        field = if :erlang.function_exported(type_or_module, :module_info, 0) do
          type_or_module.create_field(form, name, opts)
        else
          Formex.Field.create_field(form, type_or_module, name, opts)
        end

        Formex.Form.put_field(form, field)
      end

      defoverridable [changeset_after_create_callback: 1]
    end
  end

  @doc """
  In this callback you have to add fields to a Form.
  """
  @callback build_form(form :: Formex.Form.t) :: Formex.Form.t

  @doc """
  Callback that will be called after changeset creation. In this function you can
  for example add extra validation to your changeset.
  """
  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t) :: Ecto.Changeset.t

  @doc """
  Adds a field to a form. More: `Formex.Field.create_field/4`
  """
  @callback add(form :: Form.t, type :: Atom.t, name :: Atom.t, opts :: Map.t) :: Form.t

end
