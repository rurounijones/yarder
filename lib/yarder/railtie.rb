require 'yarder/action_controller/log_subscriber'
require 'yarder/action_view/log_subscriber'
require 'yarder/active_record/log_subscriber' if defined?(ActiveRecord)
require 'yarder/active_resource/log_subscriber' if defined?(ActiveResource)

module Yarder

  # Railtie to hook Yarder into Rails
  #
  # This Railtie hooks Yarder into Rails by adding middleware and loggers as well as 
  # adding a completely new set of LogSubscribers which parallel the default rails ones but
  # are JSON based rather than string based
  class Railtie < Rails::Railtie

    initializer "yarder.swap_rack_logger_middleware" do |app|
      app.middleware.swap(Rails::Rack::Logger, Yarder::Rack::Logger, app.config.log_tags)
    end

    # We need to do the following in an after_initialize block to make sure we get all the
    # subscribers. Ideally rails would allow us the ability to stop the LogSubscribers from
    # registering themselves using a config option.
    config.after_initialize do

      # Kludge the removal of the default LogSubscribers for the moment. We will use the yarder
      # LogSubscribers (since they subscribe to the same hooks in the public methods) to create
      # a list of hooks we want to unsubscribe current subscribers from.
      modules = ["ActionController", "ActionView"]
      modules << "ActiveRecord" if defined?(ActiveRecord)
      modules << "ActiveResource" if defined?(ActiveResource)

      notifier = ActiveSupport::Notifications.notifier

      modules.each do |mod|
        "Yarder::#{mod}::LogSubscriber".constantize.instance_methods(false).each do |method|
          notifier.listeners_for("#{method}.#{mod.underscore}").each do |subscriber|
            ActiveSupport::Notifications.unsubscribe subscriber
          end
        end
      end

      # We then subscribe using the yarder versions of the default rails LogSubscribers
      Yarder::ActionController::LogSubscriber.attach_to :action_controller
      Yarder::ActionView::LogSubscriber.attach_to :action_view
      Yarder::ActiveRecord::LogSubscriber.attach_to :active_record if defined?(ActiveRecord)
      Yarder::ActiveResource::LogSubscriber.attach_to :active_resource if defined?(ActiveResource)

    end

  end

end
