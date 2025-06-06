class BasePresenter < SimpleDelegator
  include ActiveSupport::ToJsonWithActiveSupportEncoder
  include Rails.application.routes.url_helpers

  CLASS_ATTRIBUTES = {
    build_with: :build_attributes,
    related_to: :relations,
    sort_by:    :sort_attributes,
    filter_by:  :filter_attributes
  }

  class << self
    attr_accessor *CLASS_ATTRIBUTES.values

    CLASS_ATTRIBUTES.each do |method, instace|
      define_method method do |*args|
        instance_variable_set("@#{instace}", args.map(&:to_s))
      end
    end
  end

  attr_accessor :object, :params, :data

  def initialize(object, params, options = {})
    @object  = object
    @params  = params
    @options = options
    @data    = HashWithIndifferentAccess.new
    super(@object)
  end

  def as_json(*)
    data
  end

  def build actions
    actions.each { |action| send(action) }
    self
  end

  def fields
    FieldPicker.new(self).pick
  end

  def embeds
    EmbedPicker.new(self).embed
  end
end
