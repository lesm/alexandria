class QueryOrchestrator
  ACTIONS = [:paginate, :sort, :filter, :eager_load]

  attr_accessor :scope
  attr_reader :actions, :request, :response, :params

  def initialize(scope:, params:, request:, response:, actions: :all)
    @scope = scope
    @params = params
    @request = request
    @response = response
    @actions = (actions == :all) ? ACTIONS : actions
  end

  def run
    actions.each do |action|
      if ACTIONS.exclude?(action)
        raise InvalidBuilderAction, "#{action} not permitted"
      end

      self.scope = send(action)
    end
    scope
  end

  private

  def paginate
    current_url = request.base_url + request.path
    paginator = Paginator.new(scope, request.query_parameters, current_url)
    self.response.headers['Link'] = paginator.links
    paginator.paginate
  end

  def sort
    Sorter.new(scope, params).sort
  end

  def filter
    Filter.new(scope, params.to_unsafe_hash).filter
  end

  def eager_load
    EagerLoader.new(scope, params).load
  end
end
