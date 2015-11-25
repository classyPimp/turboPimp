class PagesController < BaseController


  def handle_inputs_for_new
    c.collect_inputs
    unless c.state.form_model.has_errors?
      c.state.form_model.create.then do |model|
        if model.has_errors?
          c.set_state form_model: model
        else
          c.set_state page_saved: true
        end
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

  def restart_new
    c.state.page_saved = false
    c.set_state form_model: Page.new
  end

  

  def handle_inputs_for_update
    c.collect_inputs
    unless c.state.form_model.has_errors?
      c.state.form_model.update.then do |model|
        if model.has_errors?
          c.set_state form_model: model
        else
          c.set_state page_saved: true
        end
      end
    else
      c.set_state form_model: c.state.form_model
    end
  end

end