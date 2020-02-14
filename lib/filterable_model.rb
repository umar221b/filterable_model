require "filterable_model/version"

module FilterableModel
  class Error < StandardError; end
  class FilterNotSupported < Error; end

  extend ActiveSupport::Concern
  included {}

  class_methods do
    def filter(filters)
      relations = build_relations(filters.as_json)
      result = send('all')
      relations.each { |relation| result.merge!(relation) }
      result
    end

    # array of strings of model attributes that support being filtered through a basic where statement
    def filterable_attributes
      []
    end

    def add_filter(filter_name, &block)
      filter_name = filter_name.to_s
      custom_filters[filter_name] = block
    end

    private

    def custom_filters
      @custom_filters ||= {}
    end

    def build_relations(filters)
      filters.map do |filter_name, value|
        get_relation(filter_name, value)
      end
    end

    def get_relation(filter_name, value)
      if custom_filters.key?(filter_name)
        custom_filters[filter_name].call(value)
      elsif filterable_attributes.include?(filter_name)
        where(filter_name => value)
      else
        raise FilterNotSupported, "Filtering by '#{filter_name}' is not supported."
      end
    end
  end
end
