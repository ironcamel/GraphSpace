CREATE TABLE user (
    id TEXT primary key,
    password TEXT,
    name TEXT,
    email TEXT
);

CREATE TABLE graph (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    json TEXT,
    user_id TEXT,
    FOREIGN KEY(user_id) REFERENCES user(id)
);
create index graph_user_id_idx on graph(user_id);

CREATE TABLE graph_tag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);

CREATE TABLE graph_to_tag (
    graph_id INTEGER,
    tag_id INTEGER,
    PRIMARY KEY (graph_id, tag_id),
    FOREIGN KEY(graph_id) REFERENCES graph(id),
    FOREIGN KEY(tag_id) REFERENCES graph(id)
);

/*
insert into user values ('test', 'test', 'Test Account');
insert into user values ('chrisp', 'chrisp', 'Chris Poirel');
insert into user values ('chrisl', 'chrisl', 'Chris Lasher');
insert into user values ('arjun', 'arjun', 'Arjun');

INSERT INTO graph(id, json) VALUES('5', '{
    "graph": {
       "data": {
          "nodes": [
             { "id": "1" },
             { "id": "2" }
          ],
          "edges" : [
             { "id": "2to1", "source": "2", "target": "1" }
          ]
       }
    "metadata": { "name" : "sample 1" }
    "metadata": { "name": "sample 1" }
}');

*/
