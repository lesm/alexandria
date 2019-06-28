class EagerLoader
  attr_accessor :scope
  attr_reader :embed, :associations, :presenter

  def initialize(scope, params)
    @scope        = scope
    @presenter    = "#{@scope.model}Presenter".constantize
    @embed        = params[:embed] ? params[:embed].split(',') : []
    @associations = params[:include] ? params[:include].split(',') : []
  end

  def load
    return scope if embed.empty? && associations.empty?

    validate!('embed', embed)
    validate!('include', associations)

    (embed + associations).each do |relation|
      self.scope = scope.includes(relation)
    end
    scope
  end

  private

  def validate!(name, params)
    params.each do |param|
      if presenter.relations.exclude?(param)
        raise QueryBuilderError.new("#{name}=#{param}"),
          "Invalid #{name}. Allowed relations: #{presenter.relations.join(',')}"
      end
    end
  end
end
