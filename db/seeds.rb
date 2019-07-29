FactoryBot.create_list :book, 1000 if Book.count.zero?
FactoryBot.create_list :user, 5 if User.count.zero?
