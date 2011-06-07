use inc::Module::Install;
name 'MySQL-SustainableQuery';
all_from 'lib/MySQL/SustainableQuery.pm';

requires 'Class::Accessor::Lite';
requires 'Class::Load';
requires 'DBI';
requires 'POSIX';
requires 'Time::HiRes';

tests_recursive 't';
author_tests 'xt';

test_requires 'DBD::Mock';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Test::LoadAllModules';
test_requires 'Test::Output';
test_requires 'Test::Requires';

auto_set_repository;
auto_include;
WriteAll;
