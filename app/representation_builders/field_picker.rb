class FieldPicker
  attr_reader :fields, :presenter

  def initialize(presenter)
    @presenter = presenter
    @fields    = @presenter.params[:fields].to_s
  end

  def pick
    valid_fields.each do |field|
      presenter.data[field] = presenter.send(field)
    end
    presenter
  end

  private

  def valid_fields
    validated = fields.split(',').select { |f| pickable.include?(f) }
    validated.any? ? validated : pickable
  end

  def pickable
    @pickable ||= presenter.class.build_attributes
  end
end
