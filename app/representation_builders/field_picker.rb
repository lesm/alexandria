class FieldPicker
  attr_reader :presenter

  def initialize(presenter)
    @presenter = presenter
  end

  def pick
    build_fields
    presenter
  end

  def fields
    @fields ||= validate_fields
  end

  private

  def validate_fields
    return pickable if presenter.params[:fields].blank?

    fields = presenter.params[:fields].split(',')

    fields.each do |field|
      error!(field) if pickable.exclude?(field)
    end

    fields
  end

  def build_fields
    fields.each do |field|
      presenter.data[field] = presenter.send(field)
    end
  end

  def error! field
    build_attributes = presenter.class.build_attributes.join(',')

    raise RepresentationBuilderError.new("fields=#{field}"),
      "Invalid Field Pick. Allowed fields: (#{build_attributes})"
  end

  def pickable
    @pickable ||= presenter.class.build_attributes
  end
end
