# frozen_string_literal: true

CodeWithSense::App.controllers :page, provides: [:html] do
  get :home, '/' do
    render 'home', layout: :static
  end
end
