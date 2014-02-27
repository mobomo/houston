if Group.count == 0
  Group.create!(name: 'Demo', from: 'no-reply@houstonize.com', display: true)
  puts "Demo group created."
end
