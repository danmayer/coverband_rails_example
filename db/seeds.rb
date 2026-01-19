# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create sample posts
posts_data = [
  { title: "Getting Started with Coverband", author: "Dan Mayer", content: "Coverband is a powerful tool for tracking code coverage in production..." },
  { title: "Understanding View Tracking", author: "Demo User", content: "View tracking helps you identify which views are actually being rendered..." },
  { title: "Translation Key Analysis", author: "I18n Expert", content: "Learn how to use Coverband to find unused translation keys..." },
  { title: "Performance Optimization Tips", author: "Performance Guru", content: "Here are some tips for optimizing your Coverband configuration..." },
  { title: "Router Tracking Best Practices", author: "Rails Developer", content: "Discover which routes are unused and can be safely removed..." }
]

posts_data.each do |post_attrs|
  Post.find_or_create_by!(title: post_attrs[:title]) do |post|
    post.author = post_attrs[:author]
    post.content = post_attrs[:content]
  end
end

# Create sample books
books_data = [
  { title: "The Pragmatic Programmer", author: "Dave Thomas, Andy Hunt", content: "A classic guide to software craftsmanship and best practices..." },
  { title: "Clean Code", author: "Robert C. Martin", content: "Essential reading for writing maintainable and elegant code..." },
  { title: "Design Patterns", author: "Gang of Four", content: "Fundamental patterns for object-oriented software design..." },
  { title: "Refactoring", author: "Martin Fowler", content: "Improving the design of existing code through systematic changes..." },
  { title: "Working Effectively with Legacy Code", author: "Michael Feathers", content: "Strategies for dealing with and improving existing codebases..." }
]

books_data.each do |book_attrs|
  Book.find_or_create_by!(title: book_attrs[:title]) do |book|
    book.author = book_attrs[:author]
    book.content = book_attrs[:content]
  end
end

puts "Created #{Post.count} posts and #{Book.count} books"
puts "Seeding complete!"
