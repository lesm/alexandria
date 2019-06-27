class Sorter
  DIRECTIONS = %w(asc desc)
  attr_reader :scope, :column, :direction, :presenter

  def initialize(scope, params)
    @scope     = scope
    @presenter = "#{@scope.model}Presenter".constantize
    @column    = params[:sort]
    @direction = params[:dir]
  end

  def sort
    return scope if column.nil? && direction.nil?

    error!('sort', column) if presenter.sort_attributes.exclude?(column)
    error!('dir', direction) if DIRECTIONS.exclude?(direction)

    scope.order("#{column} #{direction}")
  end

  private

  def error!(name, value)
    columns    = presenter.sort_attributes.join(',')
    directions = DIRECTIONS.join(',')
    raise QueryBuilderError.new("#{name}=#{value}"),
      "Invalid sorting params. sort: (#{columns}), 'dir': (#{directions})"
  end
end
