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
    graphml TEXT,
    user_id TEXT,
    FOREIGN KEY(user_id) REFERENCES user(id)
);

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
insert into user values ('test', 'test', 'test');
insert into user values ('arjun', 'arjun', 'Arjun');
INSERT INTO graph(id, graphml) VALUES('1','<graphml>
  <key id="label" for="all" attr.name="label" attr.type="string"/>
  <key id="graph_id" for="all" attr.name="graph_id" attr.type="string"/>
  <graph>
    <node id="1">
      <data key="label">1</data>
      <data key="graph_id">1</data>
    </node>
    <node id="2">
      <data key="label">2</data>
      <data key="graph_id">2</data>
    </node>
    <edge target="1" source="2"/>
  </graph>
</graphml>');

INSERT INTO graph(id, graphml) VALUES('2','<graphml>
  <key id="label" for="all" attr.name="label" attr.type="string"/>
  <key id="graph_id" for="all" attr.name="graph_id" attr.type="string"/>
  <graph>
    <node id="1">
      <data key="label">1</data>
      <data key="graph_id">1</data>
    </node>
    <node id="2">
      <data key="label">2</data>
      <data key="graph_id">2</data>
    </node>
    <node id="3">
      <data key="label">3</data>
      <data key="graph_id">3</data>
    </node>
    <edge target="1" source="2"/>
    <edge target="1" source="3"/>
    <edge target="2" source="3"/>
  </graph>
</graphml>');

INSERT INTO graph(id, graphml) VALUES('3','<graphml>
  <key id="label" for="all" attr.name="label" attr.type="string"/>
  <key id="graph_id" for="all" attr.name="graph_id" attr.type="string"/>
  <graph>
    <node id="1">
      <data key="label">1</data>
      <data key="graph_id">1</data>
    </node>
    <node id="2">
      <data key="label">2</data>
      <data key="graph_id">2</data>
    </node>
    <node id="3">
      <data key="label">3</data>
      <data key="graph_id">3</data>
    </node>
    <node id="4">
      <data key="label">4</data>
      <data key="graph_id">4</data>
    </node>
    <edge target="1" source="2"/>
    <edge target="1" source="3"/>
    <edge target="2" source="3"/>
    <edge target="3" source="4"/>
  </graph>
</graphml>
');

INSERT INTO graph(id, graphml) VALUES('4','<graphml>
  <key id="label" for="all" attr.name="label" attr.type="string"/>
  <key id="graph_id" for="all" attr.name="graph_id" attr.type="string"/>
  <graph>
    <node id="1">
      <data key="label">1</data>
      <data key="graph_id">1</data>
    </node>
    <node id="2">
      <data key="label">2</data>
      <data key="graph_id">2</data>
    </node>
    <node id="3">
      <data key="label">3</data>
      <data key="graph_id">3</data>
    </node>
    <node id="4">
      <data key="label">4</data>
      <data key="graph_id">4</data>
    </node>
    <edge target="1" source="2"/>
    <edge target="2" source="3"/>
    <edge target="3" source="4"/>
    <edge target="4" source="1"/>
  </graph>
</graphml>');

INSERT INTO graph(id, json) VALUES('5', '{
    "graph": {
       "data" : {
          "nodes" : [
             {
                "id" : "1"
             },
             {
                "id" : "2"
             }
          ],
          "edges" : [
             {
                "source" : "2",
                "target" : "1",
                "id" : "2to1"
             }
          ]
       }
    },
    "metadata": { }
}');

*/
