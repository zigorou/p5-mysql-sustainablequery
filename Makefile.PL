use inc::Module::Install;
name 'MySQL-SustainableQuery';
all_from 'lib/MySQL/SustainableQuery.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
