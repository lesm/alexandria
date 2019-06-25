Book.delete_all
Publisher.delete_all
Author.delete_all

author1 = Author.create!(given_name: 'Pat',
                         family_name: 'Shaughnessy')
author2 = Author.create!(given_name: 'Michael',
                         family_name: 'Hartl')
author3 = Author.create!(given_name: 'San',
                         family_name: 'Ruby')

publisher = Publisher.create!(name: "O'Reilly")

Book.create!(title: 'Ruby Under a Microscope',
             subtitle: 'An illustrated Guide to Ruby Internals',
             isbn_10: '1234567890',
             isbn_13: '0123456789012',
             description: 'Ruby Under a Microscope is a cool book',
             released_on: '2013-09-01',
             publisher: publisher,
             author: author1)

Book.create!(title: 'Ruby on Rails Tutorial',
             subtitle: 'Learn Web Development with Rails',
             isbn_10: '1234567891',
             isbn_13: '0123456789013',
             description: 'The Rails Tutorial is great!',
             released_on: '2013-05-09',
             publisher: nil,
             author: author2)

Book.create!(title: 'Agile Web Development with Rails 4',
             subtitle: '',
             isbn_10: '1234567892',
             isbn_13: '0123456789014',
             description: 'Stay agile!',
             released_on: '2013-10-11',
             publisher: publisher,
             author: author3)
