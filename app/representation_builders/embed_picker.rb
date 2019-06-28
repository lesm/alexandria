class EmbedPicker
  attr_reader :presenter

  def initialize(presenter)
    @presenter = presenter
  end

  def embed
    return presenter if embeds.empty?
    embeds.each { |embed| build_embed(embed) }
    presenter
  end

  def embeds
    @embeds ||= validate_embeds
  end

  private

  def validate_embeds
    embeds = presenter.params[:embed].to_s.split(',')
    return [] if embeds.empty?

    embeds.each do |embed|
      error!(embed) if presenter.class.relations.exclude?(embed)
    end

    embeds
  end

  def build_embed embed
    embed_presenter = "#{relations[embed].class_name}Presenter".constantize
    entity = presenter.object.send(embed)

    presenter.data[embed] = if relations[embed].collection?
      entity.order(:id).map do |embeded_entity|
        FieldPicker.new(embed_presenter.new(embeded_entity, {})).pick.data
      end
    else
      entity ? FieldPicker.new(embed_presenter.new(entity, {})).pick.data : {}
    end
  end

  def error! embed
    raise RepresentationBuilderError.new("embed=#{embed}"),
      "Invalid Embed. Allowed relations: (#{presenter.class.relations})"
  end


  def relations
    @relations ||= compute_relations
  end

  def compute_relations
    associations = presenter.object.class.reflect_on_all_associations

    associations.each_with_object({}) do |r, hash|
      hash["#{r.name}"] = r
    end
  end
end
