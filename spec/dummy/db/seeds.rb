require "faker"

5.times do |index|
  Post.create(
    title: "BackyPost#{index}",
    body: Faker::Lorem.paragraph
  )
end
