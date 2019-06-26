class BasePresenter < SimpleDelegator
  class << self
    @build_attributes = []
    attr_reader :build_attributes

    def build_with *args
      @build_attributes = args.map(&:to_s)
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
end
