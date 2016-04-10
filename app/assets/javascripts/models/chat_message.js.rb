class ChatMessage < Model

  attributes :id, :user_id, :to_user, :text, :read, :chat_id, :created_at

  route "create", post: "chat_messages"
  route "Index", get: "chat_messages"
  route "destroy", {delete: "chat_messages/:id"}, {defaults: [:id]}
  route "update", {put: "chat_messages/:id"}, {defaults: [:id]}
  route "Show", {get: "chat_messages/:id"}
  route "Edit", {get: "chat_messages/:id/edit"}
  route "Poll_index", {post: "chat_messages/poll_index"}
  route "Set_read", {post: "chat_messages/set_read"}

  def self.responses_on_poll_index(r)
    self.responses_on_index(r)
  end

end  