use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'GraphSpace',
    PREREQ_PM => {
       'Dancer'               => '0',
       'Dancer::Plugin::DBIC' => '0',
       'JSON'                 => '0',
       'Plack'                => '0',
       'SQL::Translator'      => '0.11006',
       'Template'             => '0',
       'YAML'                 => '0',
    },
    LICENSE => 'perl',
);
