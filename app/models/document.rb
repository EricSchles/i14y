class Document
  include Elasticsearch::Persistence::Model
  extend NamespacedIndex

  index_name index_namespace

  attribute :path, String
  validates :path, presence: true
  attribute :language, String
  validates :language, presence: true
  attribute :created, DateTime
  validates :created, presence: true

  attribute :title, String
  attribute :description, String
  attribute :content, String

  attribute :updated, DateTime
  attribute :promote, Boolean
  attribute :tags, String

  LANGUAGE_FIELDS = [:title, :description, :content]

  gateway do
    def serialize(document)
      Serde.serialize_hash(document.to_hash, document.language, LANGUAGE_FIELDS)
    end

    def deserialize(hash)
      doc_hash = hash['_source']
      deserialized_hash = Serde.deserialize_hash(doc_hash, doc_hash['language'], LANGUAGE_FIELDS)

      document = Document.new deserialized_hash
      document.instance_variable_set :@_id, hash['_id']
      document.instance_variable_set :@_index, hash['_index']
      document.instance_variable_set :@_type, hash['_type']
      document.instance_variable_set :@_version, hash['_version']

      document.instance_variable_set :@hit, Hashie::Mash.new(hash.except('_index', '_type', '_id', '_version', '_source'))

      document.instance_variable_set(:@persisted, true)
      document
    end
  end

end