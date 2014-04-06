# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "esa/version"
require "date"

Gem::Specification.new do |s|
  s.name = %q{event_sourced_accounting}
  s.version = ESA::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lenno Nagel"]
  s.date = Date.today
  s.description = %q{The Event-Sourced Accounting plugin provides an event-sourced double entry accounting system for use in any Ruby on Rails application.}
  s.email = %q{lenno@nagel.ee}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.add_dependency("rails", "~> 3.2")
  s.add_dependency("enumerize")
  s.add_dependency("multipluck", "~> 0.0.4")
  s.add_development_dependency("sqlite3")
  s.add_development_dependency("rspec", "~> 2.6")
  s.add_development_dependency("rspec-rails", "~> 2.6")
  s.add_development_dependency("factory_girl")
  s.add_development_dependency("factory_girl_rails", "~> 1.1")
  s.add_development_dependency("yard")
  s.add_development_dependency("redcarpet")
  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.markdown"]
  s.homepage = %q{https://github.com/lnagel/event-sourced-accounting}
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.3.6"
  s.summary = %q{A Plugin providing a Event-Sourced Accounting Engine for Rails}
  s.test_files = Dir["{spec}/**/*"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

