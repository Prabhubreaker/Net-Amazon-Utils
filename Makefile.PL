use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Net::Amazon::Utils',
    AUTHOR           => q{Gonzalo Barco <gbarco uy at gmail com, no spaces>},
    VERSION_FROM     => 'lib/Net/Amazon/Utils.pm',
    ABSTRACT_FROM    => 'lib/Net/Amazon/Utils.pm',
    LICENSE          => 'gpl, artistic',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Net-Amazon-Utils-*' },
);
