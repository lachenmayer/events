create user1 = { name: 'Alex Rozanski', username: 'anr11', password: '', joindate: '27-05-2013' },
  user2 = { name: 'Thomas Rooney', username: 'tr111', password: '', joindate: '27-05-2013' },
  cinemasoc = { name: 'CineSoc', username: '', password: '', joindate: '' },
  event1 = { summary: 'Iron Man 3', description: 'lets all watch iron man 3', from: '16:00-28-05-2013', to: '19:00-28-05-2013' },
  location1 = { description: 'Union Hall' },
  tag1 = { tagName: 'free' },
  tag2 = { tagName: 'cinemasoc' },
  tag3 = { tagName: 'movies' },
  (user1)-[:subscribedTo]->(tag1),
  (user2)-[:subscribedTo]->(tag2),
  (user2)-[:subscribedTo]->(tag3),
  cinemasoc-[:Host]->event1,
  event1-[:taggedWith]->tag1,
  event1-[:taggedWith]->tag2,
  event1-[:taggedWith]->tag3,
  event1-[:locatedAt]->location1

