use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Business::TPGPost',
    VERSION_FROM => 'lib/Business/TPGPost.pm', # finds \$VERSION
    AUTHOR       => 'M. Blom (blom@cpan.org)',
    ABSTRACT     => 'Calculate Dutch (TPG Post) shipping costs',
    PREREQ_PM    => {
                     'Carp'         => 0,
                     'List::Util'   => 0,
                     'Test::Simple' => 0.44,
                     'YAML'         => 0,
                    },
);
