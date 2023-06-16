require "faker"

5.times.with_index do |index|
  Post.create(
    title: "BackyPost#{index}",
    body: Faker::Lorem.paragraph
  )
end
