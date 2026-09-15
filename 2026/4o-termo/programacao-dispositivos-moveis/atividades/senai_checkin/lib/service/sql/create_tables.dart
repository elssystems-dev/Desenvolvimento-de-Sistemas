const String createLogScript = 
'''
CREATE TABLE user_logs (
  id INTEGER PRIMARY KEY
  created_at DATETIME DEFAULT (strftime('%Y-%m-%d %H:%M:%f', 'NOW', 'localtime'))
  media_path TEXT NOT NULL
  latitude  REAL NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
  longitude REAL NOT NULL CHECK (longitude BETWEEN -180 AND 180)
  notes TEXT
);
''';