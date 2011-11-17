use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'GraphSpace',
    VERSION_FROM => 'lib/GraphSpace.pm',
    PREREQ_PM => {
       'Dancer'                 => '1.3080',
       'Dancer::Plugin::DBIC'   => '0',
       'DBIx::Class::TimeStamp' => '0',
       'File::Slurp'            => '0',
       'JSON'                   => '0',
       'Math::Random::Secure'   => '0',
       'Plack'                  => '0',
       'SQL::Translator'        => '0.11006',
       'Starman'                => '0',
       'Template'               => '0',
       'YAML'                   => '0',
    },
    LICENSE => 'perl',
);
