FactoryBot.define do
  factory :photo do
    title { "Sample Photo Title" }
    association :user

    after(:build) do |photo|
      photo.thumbnail.attach(
        io: StringIO.new("dummy"),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
