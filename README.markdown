[![Gem Version](https://badge.fury.io/rb/event_sourced_accounting.svg)](http://badge.fury.io/rb/event_sourced_accounting)
[![Dependency Status](https://gemnasium.com/lnagel/event-sourced-accounting.svg)](https://gemnasium.com/lnagel/event-sourced-accounting)
[![Build Status](https://api.travis-ci.org/lnagel/event-sourced-accounting.svg)](https://travis-ci.org/lnagel/event-sourced-accounting)
[![Code Climate](https://img.shields.io/codeclimate/github/lnagel/event-sourced-accounting.svg)](https://codeclimate.com/github/lnagel/event-sourced-accounting)
[![Code Climate](https://img.shields.io/codeclimate/coverage/github/lnagel/event-sourced-accounting.svg)](https://codeclimate.com/github/lnagel/event-sourced-accounting)

Event-Sourced Accounting
=================

The Event-Sourced Accounting plugin provides an event-sourced double entry accounting system.
It uses the data models of a Rails application as a data source and automatically 
generates accounting transactions based on defined accounting rules.

This plugin began life as a fork of the [Plutus](https://github.com/mbulat/plutus) plugin with
many added features and refactored compontents. As the aims of the ESA plug-in have completely
changed compared to the original project, it warrants a release under its own name.

The API is not yet declared frozen and may change, as some refactoring is still due.
The documentation and test coverage is expected to be completed within April-May 2014. 


Installation
============

- Add `gem "event-sourced-accounting"` to your Gemfile

- generate migration files with `rails g esa`

- run migrations `rake db:migrate`

- add `include ESA::Traits::Accountable` to relevant models

- implement the corresponding Event, Flag, Ruleset and Transaction classes for relevant models


Development
============

Any comments and contributions are welcome. Will gladly accept patches sent via pull requests.

- run rspec tests simply with `rake`

- update documentation with `yard`
