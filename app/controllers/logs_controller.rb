class LogsController < ApplicationController
  def index
    @darts_data = Dart.all
  end
end
