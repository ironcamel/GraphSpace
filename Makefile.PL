use inc::Module::Install;
 
name           'GraphSpace';
all_from       'lib/GraphSpace.pm';
 
requires       'Dancer'               => '0';
requires       'Dancer::Plugin::DBIC' => '0';
requires       'JSON'                 => '0';
requires       'Plack'                => '0';
requires       'SQL::Translator'      => '0.11006';
requires       'Template'             => '0';
requires       'YAML'                 => '0';
 
WriteAll;
