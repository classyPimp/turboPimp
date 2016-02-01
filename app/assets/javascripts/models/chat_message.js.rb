class ChatMessage < Model

  attributes :id, :user_id, :to_user, :text, :read

  route "create", post: "chat_messages"
  route "Index", get: "chat_messages"
  route "destroy", {delete: "chat_messages/:id"}, {defaults: [:id]}
  route "update", {put: "chat_messages/:id"}, {defaults: [:id]}
  route "Show", {get: "chat_messages/:id"}
  route "Edit", {get: "chat_messages/:id/edit"}

end  