#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::TempDir;

use File::Spec::Functions;

my $dir = tempdir;

use Test::Requires {
    'JSON::Any' => 0.01, # skip all if not installed
};

BEGIN {
    plan tests => 10;
    use_ok('MooseX::Storage');
}

{
    package Foo;
    use Moose;
    use MooseX::Storage;
    
    with Storage(
        format => 'JSON',
        io     => 'File',
    );
    
    has 'number' => (is => 'ro', isa => 'Int');
    has 'string' => (is => 'ro', isa => 'Str');
    has 'float'  => (is => 'ro', isa => 'Num');        
    has 'array'  => (is => 'ro', isa => 'ArrayRef');
    has 'hash'   => (is => 'ro', isa => 'HashRef');    
	has 'object' => (is => 'ro', isa => 'Object');    
}

my $file = catfile($dir, 'temp.json');

{
    my $foo = Foo->new(
        number => 10,
        string => 'foo',
        float  => 10.5,
        array  => [ 1 .. 10 ],
        hash   => { map { $_ => undef } (1 .. 10) },
    	object => Foo->new( number => 2 ),
    );
    isa_ok($foo, 'Foo');

    $foo->store($file);
}

{
    my $foo = Foo->load($file);
    isa_ok($foo, 'Foo');

    is($foo->number, 10, '... got the right number');
    is($foo->string, 'foo', '... got the right string');
    is($foo->float, 10.5, '... got the right float');
    is_deeply($foo->array, [ 1 .. 10], '... got the right array');
    is_deeply($foo->hash, { map { $_ => undef } (1 .. 10) }, '... got the right hash');

    isa_ok($foo->object, 'Foo');
    is($foo->object->number, 2, '... got the right number (in the embedded object)');
}

