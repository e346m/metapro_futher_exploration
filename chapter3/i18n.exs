defmodule I18n do
  use Translator
  locale "en",
    flash: [
      hello: "Hello %{first} %{last}!",
      bye: "Bye, %{name}!"
    ],
    title: [
      users: %{
        none: "",
        single: "user",
        plural: "users"
      }
    ]

  locale "fr",
    flash: [
      hello: "Salut %{first} %{last}!",
      bye: "Au revoir, %{name}!"
    ],
    users: [
      title: "Utilisateurs",
    ]
end
