class BookSerializer < BookBasicSerializer
  has_many :authors, serializer: ObjectPreviewSerializer
  has_many :genres, serializer: ObjectPreviewSerializer
  has_one :publisher, serializer: ObjectPreviewSerializer
end
