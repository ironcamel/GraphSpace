CREATE TABLE user (
    id VARCHAR(100) primary key,
    password TEXT,
    name TEXT,
    email TEXT
);

CREATE TABLE graph (
    id VARCHAR(500),
    user_id VARCHAR(100),
    json TEXT,
    created TIMESTAMP,
    modified TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES user(id)
);

CREATE TABLE graph_tag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);

CREATE TABLE graph_to_tag (
    graph_id VARCHAR(500),
    tag_id INTEGER,
    PRIMARY KEY (graph_id, tag_id),
    FOREIGN KEY(graph_id) REFERENCES graph(id),
    FOREIGN KEY(tag_id) REFERENCES graph(id)
);
